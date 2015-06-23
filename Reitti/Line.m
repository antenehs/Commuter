//
//  LineInfo.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "Line.h"
#import "ReittiStringFormatter.h"
#import <MapKit/MapKit.h>

@implementation Line

@synthesize code;
@synthesize codeShort;
@synthesize lineType;
@synthesize lineStart;
@synthesize lineEnd;
@synthesize lineStops;
@synthesize timetableUrl;
@synthesize dateFrom;
@synthesize dateTo;
@synthesize name;
@synthesize shapeCoordinates;

-(id)initFromHSLLine:(HSLLine *)hslLine{
    self = [super init];
    
    if (self && hslLine != nil && [hslLine isKindOfClass:[HSLLine class]]) {
        self.code = hslLine.code;
        self.codeShort = hslLine.codeShort;
        self.lineType = [EnumManager lineTypeForHSLLineTypeId:[NSString stringWithFormat:@"%d", (int)hslLine.transportTypeId]];
        self.lineStart = hslLine.lineStart;
        self.lineEnd = hslLine.lineEnd;
        //TODO: convert stops to Reitti stop
        self.lineStops = hslLine.lineStops;
        self.timetableUrl = hslLine.timetableUrl;
        self.dateFrom = hslLine.dateFrom;
        self.dateTo = hslLine.dateTo;
        self.name = hslLine.name;
        self.shapeCoordinates = [Line parseCoordinatesFromHSLShapeString:hslLine.lineShape];
    }
    
    return self;
}

#pragma mark - static helpers
+(NSArray *)parseCoordinatesFromHSLShapeString:(NSString *)shapeString{
    NSMutableArray *tempArray = [@[] mutableCopy];
    
    NSArray *coordStrings = [shapeString componentsSeparatedByString:@"|"];
    
    for (NSString *coordString in coordStrings) {
        CLLocationCoordinate2D coords = [ReittiStringFormatter convertStringTo2DCoord:coordString];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:coords.latitude longitude:coords.longitude];
        [tempArray addObject:loc];
    }
    
    return tempArray;
}

@end
