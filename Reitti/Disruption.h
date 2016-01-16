//
//  Disruption.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 24/10/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisruptionLine.h"
#import "DisruptionText.h"

@interface Disruption : NSObject

-(NSString *)localizedText;
-(BOOL)affectsLineWithShortName:(NSString *)lineShortName;

@property (nonatomic, retain) NSNumber * disruptionId;
@property (nonatomic, retain) NSNumber * disruptionType;
@property (nonatomic, retain) NSNumber * disruptionSource;
//@property (nonatomic, retain) NSString * disruptionInfo;
@property (nonatomic, retain) NSString * disruptionStartTime;
@property (nonatomic, retain) NSString * disruptionEndTime;
//@property (nonatomic, retain) NSString * lineId;
//@property (nonatomic, retain) NSNumber * lineDirection;
//@property (nonatomic, retain) NSNumber * lineType;
//@property (nonatomic, retain) NSString * lineName;
@property (nonatomic, retain) NSArray * disruptionTexts;
@property (nonatomic, retain) NSArray * disruptionLines;

@end
