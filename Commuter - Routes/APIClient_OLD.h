//
//  APIClient.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import <RestKit/RestKit.h>

typedef void (^ActionBlock)();

@interface APIClient_OLD : NSObject

-(void)doApiFetchWithParams:(NSDictionary *)params andCompletionBlock:(ActionBlock)completionBlock;

@property (nonatomic, strong) NSString *apiBaseUrl;

@end
