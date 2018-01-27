//
//  AppFeatureManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/20/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "AppFeatureManager.h"
#import "AppManagerBase.h"
#import "SettingsManager.h"

#if MAIN_APP
#import "MKStoreKit.h"
@import StoreKit;
#endif

NSString *kAllProFeaturesIAPProductId = @"reitti.aikatauluapp.unlockprofeatures.test";
//NSString *kAllProFeaturesIAPProductId = @"reitti.aikatauluapp.unlockprofeatures";

NSString *kProFeaturesPurchasedNotification = @"kProFeaturesPurchasedNotification";

@interface AppFeatureManager ()

@property (nonatomic, strong)NSArray *proOnlyFeatures;
@property (nonatomic)BOOL areProFeaturesAvailable;

@property (nonatomic, strong)NSNumberFormatter *priceFormatter;

@property (nonatomic)PurchaseCompletionBlock purchaseCompletion;
@property (nonatomic)PurchaseCompletionBlock restoreCompletion;

@end

@implementation AppFeatureManager

+(instancetype)sharedManager {
    static AppFeatureManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [AppFeatureManager new];
    });
    
    return sharedInstance;
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
#if MAIN_APP
        [[MKStoreKit sharedKit] startProductRequest];
        [self registerMKStoreNotifications];
#endif
    }
    
    return self;
}

#if MAIN_APP
-(void)registerMKStoreNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Products available: %@", [[MKStoreKit sharedKit] availableProducts]);
                                                      NSLog(@"Price is: %@", [self formattedProFeaturesPrice]);
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [self proFeaturePurchaseSuccessful];
                                                      
                                                      NSLog(@"Purchased/Subscribed to product with id: %@", [note object]);
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [self proFeaturePurchaseFailedWithError:[note object]];
                                                      
                                                      NSLog(@"Purchased/Subscribed to product with id: %@", [note object]);
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoredPurchasesNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [self proFeatureRestoreSuccessful];
                                                      
                                                      NSLog(@"Restored Purchases");
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoringPurchasesFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [self proFeatureRestoreFailedWithError:[note object]];
                                                      
                                                      NSLog(@"Failed restoring purchases with error: %@", [note object]);
                                                  }];
    
}

#pragma mark - 
#pragma mark Product Properties

-(NSString *)formattedProFeaturesPrice {
    NSArray *products = [[MKStoreKit sharedKit] availableProducts];
    
    if (products && [products count] > 0) {
        for (SKProduct *product in products) {
            if (![product.productIdentifier isEqualToString:kAllProFeaturesIAPProductId]) continue;
            

            if (!_priceFormatter) {
                _priceFormatter = [[NSNumberFormatter alloc] init];
                [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [_priceFormatter setLocale:product.priceLocale];
            }
            
            return [_priceFormatter stringFromNumber:product.price];
        }
    }
    
    return nil;
}

#pragma mark - 
#pragma mark Purchase methods

-(void)purchaseProFeaturesWithCompletionBlock:(PurchaseCompletionBlock)completion {
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:kAllProFeaturesIAPProductId];
    
    self.purchaseCompletion = completion;
}

-(void)proFeaturePurchaseSuccessful {
    
    if (self.purchaseCompletion) self.purchaseCompletion(nil);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProFeaturesPurchasedNotification object:nil];
}

-(void)proFeaturePurchaseFailedWithError:(NSError *)error {
    if (self.purchaseCompletion) self.purchaseCompletion([error localizedDescription]);
}

#pragma mark -
#pragma mark restore methods

-(void)restorePurchasesWithCompletionBlock:(PurchaseCompletionBlock)completion {
    [[MKStoreKit sharedKit] restorePurchases];
    
    self.restoreCompletion = completion;
}

-(void)proFeatureRestoreSuccessful {
    
    if (self.restoreCompletion) self.restoreCompletion(nil);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProFeaturesPurchasedNotification object:nil];
}

-(void)proFeatureRestoreFailedWithError:(NSError *)error {
    if (self.restoreCompletion) self.restoreCompletion([error localizedDescription]);
}

#endif

+(BOOL)proFeaturesAvailable {
#if MAIN_APP
    return [AppManagerBase isProBinary] ||
           [[MKStoreKit sharedKit] isProductPurchased:kAllProFeaturesIAPProductId] ||
           [SettingsManager proFeaturesEnabled] ;
#else
    //TODO: Read from NSUserDefaults for status of purchase.
    return [AppManagerBase isProBinary];
#endif
}

-(NSArray *)proOnlyFeatures {
    
    BOOL proFeaturesAvailable = self.areProFeaturesAvailable;
    
    return @[[AppFeature featureWithName:AppFeatureNearbyDepartures isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureAppleWatchApp isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureRealtimeDepartures isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureRoutesWidget isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureNearbyDepartureWidget isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureCityBikes isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureLiveLines isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureIcloudBookmarks isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureRouteDisruptions isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureStopFilter isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureRichReminders isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureTicketSales isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureFavouriteLines isAvailable:proFeaturesAvailable],];

}

-(BOOL)areProFeaturesAvailable {
    return [AppFeatureManager proFeaturesAvailable];
}

@end
