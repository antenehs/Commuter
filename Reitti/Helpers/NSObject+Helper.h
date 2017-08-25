//
//  NSObject+Helper.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 24/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ActionBlock)();
typedef void (^FetchedArrayBlock)(NSArray *);
typedef void (^GroupDispatchBlock)(ActionBlock);
typedef void (^ArrayFetchBlock)(FetchedArrayBlock);

@interface NSObject (Helper)

-(void)asa_ExecuteBlockInUIThread:(ActionBlock)block;
-(void)asa_ExecuteBlockInBackground:(ActionBlock)block;
-(void)asa_ExecuteBlockInBackgroundWithIgnoreExceptions:(ActionBlock)block;
-(void)asa_ExecuteBlocks:(NSArray<GroupDispatchBlock> *)blocks withCompletion:(ActionBlock)completion;
-(void)asa_ExecuteFetchObjectBlocksWithFetchers:(NSArray<ArrayFetchBlock> *)fetchers withCompletion:(FetchedArrayBlock)completion;


@end
