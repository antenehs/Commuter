//
//  ReittiConfigManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemoteMessage : NSObject

+(instancetype)messageWithMessage:(NSString *)message
                       actionName:(NSString *)actionName
                   actionDeepLink:(NSString *)actionDeepLink;

@property(nonatomic, strong)NSString *message;
@property(nonatomic, strong)NSString *actionName;
@property(nonatomic, strong)NSString *actionDeeplink;

@property(nonatomic, readonly) BOOL isActionable;


@end

@interface ReittiConfigManager : NSObject

+(instancetype)sharedManager;

@property(nonatomic, strong, readonly)NSString *appTranslationLink;
@property(nonatomic, readonly)NSInteger intervalBetweenGoProShowsInStopView;
@property(nonatomic, strong, readonly)RemoteMessage *moreTabMessage;


@end
