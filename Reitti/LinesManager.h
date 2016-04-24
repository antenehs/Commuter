//
//  LinesManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 30/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RettiDataManager.h"

extern NSString *kStopLineCodesKey;
extern NSString *kStopLinesKey;

@interface LinesManager : NSObject

+(id)sharedManager;
-(id)init;

-(NSArray *)getRecentLineCodes;
-(void)saveRecentLine:(Line *)line;

-(NSDictionary *)getLineCodesAndLinesFromSavedStops;
-(void)getLineCodesFromNearByStopsWithCompletionBlock:(ActionBlock)completionBlock;

@end
