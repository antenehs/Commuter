//
//  ReittiSearchManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 22/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiSearchManager.h"
#import "NamedBookmark.h"
#import "StopEntity.h"
#import "RouteEntity.h"
#import "RettiDataManager.h"
#import "CoreDataManager.h"
#import "ASA_Helpers.h"
#import "AppManager.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "CoreDataManagers.h"

NSString *kUniqueIdentifierSeparator = @"|%|";

#pragma mark - NamedBookmark Extension

@interface NamedBookmark ()

@property (nonatomic, strong) CSSearchableItemAttributeSet *attributeSet;
@property (nonatomic, strong) NSString *domainIdentifier;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@end

@implementation NamedBookmark (SearchableNamedBookmark)

-(CSSearchableItemAttributeSet *)attributeSet{
    
    CSSearchableItemAttributeSet *attrSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeText];
    attrSet.title = self.name;
    attrSet.contentDescription = [NSString stringWithFormat:@"%@ \nTap to get transit routes to %@", [self getFullAddress], self.name];
    attrSet.thumbnailData = UIImagePNGRepresentation([self imageForSpotlight]);
    attrSet.keywords = @[self.streetAddress, self.city];
    
    return attrSet;
}

-(NSString *)uniqueIdentifier{
    return [NSString stringWithFormat:@"%@%@%@", [NamedBookmark domainIdentifier], kUniqueIdentifierSeparator, [self name]];
}

+(NSString *)domainIdentifier{
    return @"com.ewketapps.commuter.searchableNamedBookmark";
}

-(UIImage *)imageForSpotlight{

    CGSize finalSize = CGSizeMake(100, 100);
    return [[UIImage imageNamed:self.iconPictureName] asa_addCircleBackgroundWithColor:[UIColor whiteColor] andImageSize:finalSize andInset:CGPointMake(15, 15) andOffset:CGPointZero];
}

@end

#pragma mark - StopEntity Extension

@interface StopEntity ()

@property (nonatomic, strong) CSSearchableItemAttributeSet *attributeSet;
@property (nonatomic, strong) NSString *domainIdentifier;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@end

@implementation StopEntity (SearchableStopEntity)

-(CSSearchableItemAttributeSet *)attributeSet{
    
    CSSearchableItemAttributeSet *attrSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeText];
    attrSet.title = self.busStopName;
    NSString *secondLineDesc = self.lineCodes ? [NSString stringWithFormat:@"Lines: %@", self.linesString] : @"Tap to view timetable";
    attrSet.contentDescription = [NSString stringWithFormat:@"Stop Code: %@ - %@ \n%@", self.busStopShortCode, self.busStopCity, secondLineDesc];
    attrSet.thumbnailData = UIImagePNGRepresentation([self imageForSpotlight]);
    attrSet.keywords = @[self.busStopCity ? self.busStopCity : @""];
    
    return attrSet;
}

-(NSString *)uniqueIdentifier{
    return [NSString stringWithFormat:@"%@%@%@", [StopEntity domainIdentifier], kUniqueIdentifierSeparator, self.stopGtfsId];
}

+(NSString *)domainIdentifier{
    return @"com.ewketapps.commuter.searchableSavedStop";
}

-(UIImage *)imageForSpotlight{
    
    CGSize finalSize = CGSizeMake(100, 100);
    return [[AppManager stopIconForStopType:self.stopType] asa_addCircleBackgroundWithColor:[UIColor whiteColor] andImageSize:finalSize andInset:CGPointMake(15, 15) andOffset:CGPointZero];
}
@end

#pragma mark - RouteEntity Extension

@interface RouteEntity ()

@property (nonatomic, strong) CSSearchableItemAttributeSet *attributeSet;
@property (nonatomic, strong) NSString *domainIdentifier;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@end

@implementation RouteEntity (SearchableRouteEntity)

-(CSSearchableItemAttributeSet *)attributeSet{
    
    CSSearchableItemAttributeSet *attrSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeText];
    attrSet.title = [NSString stringWithFormat:@"Go To: %@", self.toLocationName];
    attrSet.contentDescription = [NSString stringWithFormat:@"From: %@ \nTap to get transit routes", self.fromLocationName];
    attrSet.thumbnailData = UIImagePNGRepresentation([self imageForSpotlight]);
    attrSet.keywords = @[self.toLocationName, self.fromLocationName];
    
    return attrSet;
}

-(NSString *)uniqueIdentifier{
    return [NSString stringWithFormat:@"%@%@%@", [RouteEntity domainIdentifier], kUniqueIdentifierSeparator, [self routeUniqueName]];
}

+(NSString *)domainIdentifier{
    return @"com.ewketapps.commuter.searchableSavedRoute";
}

-(UIImage *)imageForSpotlight{
    
    CGSize finalSize = CGSizeMake(100, 100);
    return [[UIImage imageNamed:@"routeIcon2.png"] asa_addCircleBackgroundWithColor:[UIColor whiteColor] andImageSize:finalSize andInset:CGPointMake(15, 15) andOffset:CGPointZero];
}
@end


#pragma mark - ReittiSearchManager

@interface ReittiSearchManager ()

@property (nonatomic, strong)RettiDataManager *reittiDataManager;

@end

@implementation ReittiSearchManager

+(id)sharedManager{
    static ReittiSearchManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^(){
        sharedManager = [[ReittiSearchManager alloc] init];
    });
    
    return sharedManager;
}

-(id)init{
    self = [super init];
    if (self) {
        self.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:[[CoreDataManager sharedManager] managedObjectContext]];
    }
    
    return self;
}

-(void)updateSearchableIndexes{
    //Do this in a background thread
    @try {
        [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:nil];
        [self indexNamedBookmarks];
        [self indexSavedStops];
        [self indexSavedRoutes];
    } @catch (NSException *exception) {
        NSLog(@"Some exception occured while indexing. %@", exception);
    }
}

#pragma mark - Indexing methods
-(void)indexNamedBookmarks{
    [self deleteSearchableItemsWithDomainIdentifiers:@[[NamedBookmark domainIdentifier]] completionHandler:^(NSError *error){
        @try {
            if (!error) {
                NSMutableArray *searchableItems = [@[] mutableCopy];
                
                NSArray *namedBookmarks = [[NamedBookmarkCoreDataManager sharedManager] fetchAllSavedNamedBookmarks];
                
                if (namedBookmarks != nil && namedBookmarks.count > 0) {
                    for (NamedBookmark *namedBookmark in namedBookmarks) {
                        CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:[namedBookmark uniqueIdentifier] domainIdentifier:[NamedBookmark domainIdentifier] attributeSet:namedBookmark.attributeSet];
                        [searchableItems addObject:item];
                    }
                }
                
                if (searchableItems == nil)
                    return;
                
                [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:searchableItems completionHandler:^(NSError *error){
                    if (error) NSLog(@"Error occured when indexing named bookmarks: %@", error);
                }];
            }
        } @catch (NSException *exception) {
            NSLog(@"Some exception occured while indexing. %@", exception);
        }
    }];
}

-(void)indexSavedStops {
    NSArray *savedStops = [[StopCoreDataManager sharedManager] fetchAllSavedStopsFromCoreData];
    
    [self deleteSearchableItemsWithDomainIdentifiers:@[[StopEntity domainIdentifier]] completionHandler:^(NSError *error){
        @try {
            if (!error) {
                NSMutableArray *searchableItems = [@[] mutableCopy];
                
                if (savedStops != nil && savedStops.count > 0) {
                    for (StopEntity *savedStop in savedStops) {
                        if (!savedStop.busStopName)
                            continue;
                        CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:[savedStop uniqueIdentifier] domainIdentifier:[StopEntity domainIdentifier] attributeSet:savedStop.attributeSet];
                        [searchableItems addObject:item];
                    }
                }
                
                if (searchableItems == nil)
                    return;
                
                [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:searchableItems completionHandler:^(NSError *error){
                    if (error) NSLog(@"Error occured when indexing saved stops: %@", error);
                }];
            }
        } @catch (NSException *exception) {
            NSLog(@"Some exception occured while indexing. %@", exception);
        }
    }];
}

-(void)indexSavedRoutes{
    [self deleteSearchableItemsWithDomainIdentifiers:@[[RouteEntity domainIdentifier]] completionHandler:^(NSError *error){
        @try {
            if (!error) {
                NSMutableArray *searchableItems = [@[] mutableCopy];
                
                NSArray *savedRoutes = [self.reittiDataManager fetchAllSavedRoutesFromCoreData];
                
                if (savedRoutes != nil && savedRoutes.count > 0) {
                    for (RouteEntity *savedRoute in savedRoutes) {
                        CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:[savedRoute uniqueIdentifier] domainIdentifier:[RouteEntity domainIdentifier] attributeSet:savedRoute.attributeSet];
                        [searchableItems addObject:item];
                    }
                }
                
                if (searchableItems == nil)
                    return;
                
                [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:searchableItems completionHandler:^(NSError *error){
                    if (error) NSLog(@"Error occured when indexing saved routes: %@", error);
                }];
            }
        } @catch (NSException *exception) {
            NSLog(@"Some exception occured while indexing. %@", exception);
        }
    }];
}

#pragma mark - Helpers

//Do deletion and return to main thread
-(void)deleteSearchableItemsWithDomainIdentifiers:(NSArray *)identifiers completionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler {
    
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithDomainIdentifiers:identifiers completionHandler:^(NSError *error){
        [self asa_ExecuteBlockInUIThread:^{
            completionHandler(error);
        }];
    }];
}

+(SpotlightObjectType)spotlightObjectTypeForIdentifier:(NSString *)identifier{
    if (!identifier)
        return UnknownSearchableType;
    
    NSString *domainIdentifier = [ReittiSearchManager domainIdentifierForIdentifier:identifier];
    
    if (!domainIdentifier)
        return UnknownSearchableType;
    
    if ([domainIdentifier isEqualToString:[NamedBookmark domainIdentifier]]) {
        return SearchableNamedBookmarkType;
    }else if ([domainIdentifier isEqualToString:[StopEntity domainIdentifier]]) {
        return SearchableSavedStopType;
    }else if ([domainIdentifier isEqualToString:[RouteEntity domainIdentifier]]) {
        return SearchableSavedRouteType;
    }else{
        return UnknownSearchableType;
    }
}
+(NSString *)uniqueObjectNameForIdentifier:(NSString *)identifier{
    if (!identifier)
        return nil;
    
    NSArray *components = [identifier componentsSeparatedByString:kUniqueIdentifierSeparator];
    if (components.count < 2)
        return nil;
    else
        return components[1];
    
}
+(NSString *)domainIdentifierForIdentifier:(NSString *)identifier{
    if (!identifier)
        return nil;
    
    if (!identifier)
        return nil;
    
    NSArray *components = [identifier componentsSeparatedByString:kUniqueIdentifierSeparator];
    if (components.count < 2)
        return nil;
    else
        return components[0];
}


@end
