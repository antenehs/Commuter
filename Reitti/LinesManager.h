//
//  LinesManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 30/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RettiDataManager.h"

@interface LinesManager : NSObject

+(id)sharedManager;
-(id)init;

-(NSArray *)getLineCodesFromSavedStops;
-(void)getLineCodesFromNearByStopsWithCompletionBlock:(ActionBlock)completionBlock;

@end
