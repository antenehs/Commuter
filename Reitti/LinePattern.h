//
//  LinePattern.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/19/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinePattern : NSObject<NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *headsign;
@property (nonatomic, strong) NSNumber *directionId;

//More detail
@property (nonatomic, strong) NSArray *lineStops;
@property (nonatomic, strong) NSArray *shapeCoordinates;

@property (nonatomic, strong) NSString *lineStart;
@property (nonatomic, strong) NSString *lineEnd;

@end
