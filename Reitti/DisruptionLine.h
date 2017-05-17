//
//  DisruptionLine.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 16/1/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumManager.h"
#import "DigiRouteShort.h"

@interface DisruptionLine : NSObject

+(instancetype)disruptionLineFromDigiRoute:(DigiRouteShort *)digiRouteShort;

@property (nonatomic, retain) NSString * lineId;
@property (nonatomic, retain) NSNumber * lineDirection;
@property (nonatomic, retain) NSNumber * lineType;
@property (nonatomic, retain) NSString * lineName;
@property (nonatomic, retain) NSString * lineFullCode;

@property (nonatomic) LineType parsedLineType;

@end
