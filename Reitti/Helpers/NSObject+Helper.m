//
//  NSObject+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 24/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "NSObject+Helper.h"

@implementation NSObject (Helper)

-(void)asa_ExecuteBlockInUIThread:(ActionBlock)block{
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

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

-(void)asa_ExecuteBlocks:(NSArray<GroupDispatchBlock> *)blocks withCompletion:(ActionBlock)completion {
    dispatch_group_t processGroup = dispatch_group_create();
    
    for (GroupDispatchBlock block in blocks) {
        dispatch_group_enter(processGroup);
        block(^{
            dispatch_group_leave(processGroup);
        });
    }
    
    dispatch_group_notify(processGroup, dispatch_get_main_queue(),^{
        completion();
    });
}

-(void)asa_ExecuteFetchObjectBlocksWithFetchers:(NSArray<ArrayFetchBlock> *)fetchers withCompletion:(FetchedArrayBlock)completion {
    if (!fetchers || fetchers.count == 0) {
        completion(@[]);
        return;
    };
    
    __block NSMutableArray *allResult = [@[] mutableCopy];
    
    NSMutableArray *dispatchBlocks = [@[] mutableCopy];
    
    for (ArrayFetchBlock fetchBlock in fetchers) {
        [dispatchBlocks addObject:^(ActionBlock completed) {
            fetchBlock(^(NSArray *fetched){
                [allResult addObjectsFromArray:fetched ? fetched : @[]];
                completed();
            });
        }];
    }
    
    [self asa_ExecuteBlocks:dispatchBlocks withCompletion:^{
        completion(allResult);
    }];
}

@end
