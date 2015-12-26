//
//  NSObject+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 24/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "NSObject+Helper.h"

@implementation NSObject (Helper)

-(void)asa_ExecuteBlockInBackground:(ActionBlock)block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
    });
}

-(void)asa_ExecuteBlockInBackgroundWithIgnoreExceptions:(ActionBlock)block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            block();
        }
        @catch (NSException *exception) {}
        
    });
}

@end
