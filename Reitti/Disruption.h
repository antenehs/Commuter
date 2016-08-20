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
-(NSAttributedString *)formattedLocalizedTextWithFont:(UIFont *)font;
-(BOOL)affectsLineWithShortName:(NSString *)lineShortName;
-(BOOL)affectsLineWithFullCode:(NSString *)lineFullCode;

@property (nonatomic, retain) NSNumber * disruptionId;
@property (nonatomic, retain) NSNumber * disruptionType;
@property (nonatomic, retain) NSNumber * disruptionSource;
@property (nonatomic, retain) NSString * disruptionStartTime;
@property (nonatomic, retain) NSString * disruptionEndTime;
@property (nonatomic, retain) NSArray * disruptionTexts;
@property (nonatomic, retain) NSArray * disruptionLines;

@property (nonatomic, retain) NSArray * disruptionLineNames;

@end
