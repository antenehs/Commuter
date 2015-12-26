//
//  NSObject+Helper.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 24/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ActionBlock)();

@interface NSObject (Helper)

-(void)asa_ExecuteBlockInBackground:(ActionBlock)block;
-(void)asa_ExecuteBlockInBackgroundWithIgnoreExceptions:(ActionBlock)block;

@end
