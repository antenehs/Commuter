//
//  WatchCommunicationManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@protocol WCManagerDelegate <NSObject>

@optional
-(void)receivedNamedBookmarksArray:(NSArray * _Nonnull)bookmarksArray;

@end

@interface WatchCommunicationManager : NSObject<WCSessionDelegate>

+(instancetype _Nonnull)sharedManager;

-(void)sendMessage:(NSDictionary * _Nonnull)message replyHandler:(void (^ _Nullable)(NSDictionary<NSString *,id> * _Nonnull))replyHandler;
-(void)transferUserInfo:(NSDictionary * _Nonnull)userInfo;

@property (nonatomic, weak)NSObject<WCManagerDelegate> * _Nullable delegate;

@end
