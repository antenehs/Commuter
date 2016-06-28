//
//  WatchApiClient.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ActionBlock)();

@interface WatchApiClient : NSObject

-(void)doApiFetchWithOutMappingWithParams:(NSDictionary *)params andCompletionBlock:(ActionBlock)completionBlock;

@property (nonatomic, strong) NSString *apiBaseUrl;

@end
