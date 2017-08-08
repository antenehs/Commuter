//
//  AppFeatureManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/20/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppFeature.h"

extern NSString *kProFeaturesPurchasedNotification;

typedef void(^PurchaseCompletionBlock)(NSString *errorMessage);

@interface AppFeatureManager : NSObject

+(instancetype)sharedManager;

#if MAIN_APP
-(void)purchaseProFeaturesWithCompletionBlock:(PurchaseCompletionBlock)completion;
-(void)restorePurchasesWithCompletionBlock:(PurchaseCompletionBlock)completion;
#endif

+(BOOL)proFeaturesAvailable;

@property (nonatomic, strong, readonly)NSArray *proOnlyFeatures;

@end
