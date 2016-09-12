//
//  ContactsManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ContactsManager.h"
#import <AddressBook/AddressBook.h>
#import "ASA_Helpers.h"
#import "SettingsManager.h"
#import "ReittiAnalyticsManager.h"

@interface ContactsManager ()

@property(nonatomic, strong)NSMutableDictionary *streetAddressBookMap;

@end

@implementation ContactsManager

+(instancetype)sharedManager {
    static ContactsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [ContactsManager new];
    });
    
    return sharedInstance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        //Fetch contacts with address
        requestCount = [SettingsManager getSkippedcontactsRequestTrials];
        [SettingsManager setSkippedcontactsRequestTrials:requestCount + 1];
        self.contactsWithAddress = @[];
        self.streetAddressBookMap = [@{} mutableCopy];
        [self asa_ExecuteBlockInBackground:^{
            [self customRequestForAccess];
        }];
        trackedAccessOnce = NO;
    }
    
    return self;
}

-(void)customRequestForAccess {
    if ([SettingsManager askedContactsPermission] || [self isAuthorized]) {
        [self requestAccessAndFilterContacts];
        return;
    }
    
    if (requestCount < 1) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Would you like to search your contacts for addresses?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self requestAccessAndFilterContacts];
        [SettingsManager setAskedContactPermission:YES];
    }];
    
    UIAlertAction* later = [UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [SettingsManager setSkippedcontactsRequestTrials:-30];
    }];
    
    [alertController addAction:later];
    [alertController addAction:ok];
    
    UIViewController *viewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UINavigationController *searchNavBar = (UINavigationController *)viewController.presentedViewController;
    
    if (searchNavBar.childViewControllers.count > 0) {
        [[searchNavBar.childViewControllers lastObject] presentViewController:alertController animated:YES completion:nil];
    }
//    [viewController presentViewController:alertController animated:YES completion:nil];
}

-(void)requestAccessAndFilterContacts {
    // Create a new address book object with data from the Address Book database
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (!addressBook) {
        return;
    } else if (error) {
        CFRelease(addressBook);
        return;
    }
    
    // Requests access to address book data from the user
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted){
            self.contactsWithAddress = [self filterContactsWithAddressFrom:addressBook];
            if (!trackedAccessOnce) {
                [[ReittiAnalyticsManager sharedManager] trackUserProperty:kUserAllowedContactSearching value:@"true"];
                [[ReittiAnalyticsManager sharedManager] trackUserProperty:kUserNumberOfAddressesInContact value:[NSString stringWithFormat:@"%lu", (unsigned long)self.contactsWithAddress.count]];
                trackedAccessOnce = YES;
            }
            return;
        }
        NSLog(@"Not authorized");
    });
}

-(NSArray *)filterContactsWithAddressFrom:(ABAddressBookRef)addressBook {
    NSPredicate *predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
        
        ABMultiValueRef addressRef = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonAddressProperty);
        BOOL result = NO;
        if (ABMultiValueGetCount(addressRef) > 0) {
            result = YES;
        }
        CFRelease(addressRef);
        return result;
    }];
    
    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSArray *filteredContacts = [allPeople filteredArrayUsingPredicate:predicate];
    CFRelease(addressBook);
    
    return filteredContacts.count > 0 ? [self geocodesFromContacts:filteredContacts] : @[] ;
}

-(NSArray *)geocodesFromContacts:(NSArray *)contactRecords {
    NSMutableArray *geoCodes = [@[] mutableCopy];
    for (id record in contactRecords) {
        
        NSMutableString *fullName = nil;
        CFTypeRef firstNameObject = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonFirstNameProperty);
        if (firstNameObject) {
            fullName =  [(__bridge NSString *)firstNameObject mutableCopy];
            CFRelease(firstNameObject);
        }
        
        CFTypeRef lastNameObject = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonLastNameProperty);
        if (lastNameObject) {
            if (fullName) {
                [fullName appendString:@" "];
                [fullName appendString:(__bridge NSString *)lastNameObject];
            } else {
                fullName = [(__bridge NSString *)lastNameObject mutableCopy];
            }
            CFRelease(lastNameObject);
        }
        
        ABMultiValueRef addressRef = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonAddressProperty);
        for (int i = 0; i < ABMultiValueGetCount(addressRef); i++) {
            NSDictionary *addressDict = (__bridge NSDictionary *)ABMultiValueCopyValueAtIndex(addressRef, i);
            if (![[addressDict[@"CountryCode"] lowercaseString] isEqualToString:@"fi"])
                continue;
            
            GeoCode *geoCode = [[GeoCode alloc] init];
            geoCode.city = [addressDict objectForKey:(NSString *)kABPersonAddressCityKey];
            geoCode.locTypeId = [NSNumber numberWithInt:(int)LocationTypeContact];

            GeoCodeDetail *detail = [[GeoCodeDetail alloc] init];
            detail.address = [addressDict objectForKey:(NSString *)kABPersonAddressStreetKey];
            
            geoCode.details = detail;
            geoCode.name = fullName ? fullName : detail.address;
            
            [geoCodes addObject:geoCode];
            if (geoCode.fullAddressString)
                [self.streetAddressBookMap setValue:addressDict forKey:geoCode.fullAddressString];
        }
    }
    
    return geoCodes;
}

-(NSArray *)getContactsForSearchTerm:(NSString *)searchTerm {
    [self customRequestForAccess];
    
    if (!self.contactsWithAddress || self.contactsWithAddress.count == 0)
        return @[];
    
    return [self.contactsWithAddress filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(id record, NSDictionary *bindings) {
        GeoCode *geoCode = (GeoCode *)record;
        if (![geoCode isKindOfClass:[GeoCode class]]) return NO;
        
        BOOL isMatch = [[geoCode.name lowercaseString] containsString:searchTerm] || [[geoCode.fullAddressString lowercaseString] containsString:searchTerm];
        return isMatch;
    }]];
}

-(void)getCoordsForGeoCode:(GeoCode *)geoCode withCompletion:(ActionBlock)completion {
    NSString *address = geoCode.fullAddressString;
    if (!address || !self.streetAddressBookMap[address]) {
        completion(nil, @"Address location could not be determined.");
        return;
    }
    
    CLGeocoder *geocoder = [CLGeocoder new];
    
    [geocoder geocodeAddressDictionary:self.streetAddressBookMap[address] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && placemarks.count > 0) {
            CLPlacemark *geocodedAddress=placemarks[0];
            geoCode.coords = [ReittiStringFormatter convert2DCoordToString:geocodedAddress.location.coordinate];
            completion(geoCode, nil);
        } else {
            completion(nil, @"Address location could not be determined.");
        }
    }];
}

-(BOOL)isAuthorized {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)isAccessRequested {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
        return NO;
    } else {
        return YES;
    }
}

@end
