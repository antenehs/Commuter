//
//  RouteLegLocation.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RouteLegLocation.h"
#import "ASA_Helpers.h"


@implementation RouteLegLocation

@synthesize isHeaderLocation;
@synthesize locationLegType;
@synthesize locationLegOrder;

@synthesize coordsDictionary;
@synthesize arrTime;
@synthesize depTime;
@synthesize name;
@synthesize stopCode;
@synthesize shortCode;
@synthesize stopAddress;

-(id)initFromDictionary:(NSDictionary *)legDict{
    if (self = [super init]) {
        self.coordsDictionary = legDict[@"coord"];
        self.coordsString = [NSString stringWithFormat:@"%@,%@",self.coordsDictionary[@"x"],self.coordsDictionary[@"y"]];
        
        self.arrTime = [[ReittiDateFormatter sharedFormatter] dateFromFullApiDateString:legDict[@"arrTime"]];
        self.depTime = [[ReittiDateFormatter sharedFormatter] dateFromFullApiDateString:legDict[@"depTime"]];
        self.name = legDict[@"name"];
        self.stopCode = legDict[@"code"];
        self.shortCode = legDict[@"shortCode"];
        self.stopAddress = legDict[@"stopAddress"];
        
//        NSLog(@"leg is %@",self);
    }
    return self;
}

-(id) copy{
    RouteLegLocation *copy = [[RouteLegLocation alloc] init];
    
    copy.isHeaderLocation = self.isHeaderLocation;
    copy.locationLegType = self.locationLegType;
    copy.locationLegOrder = self.locationLegOrder;
    copy.coordsDictionary = self.coordsDictionary;
    copy.coordsString = self.coordsString;
    copy.arrTime = self.arrTime;
    copy.depTime = self.depTime;
    copy.name = self.name;
    copy.stopCode = self.stopCode;
    copy.shortCode = self.shortCode;
    copy.stopAddress = self.stopAddress;
    
    return copy;
}

-(NSString *)coordsString {
    if (!_coordsString) {
        _coordsString = [NSString stringWithFormat:@"%@,%@",self.coordsDictionary[@"x"],self.coordsDictionary[@"y"]];
    }
    
    return _coordsString;
}

-(CLLocationCoordinate2D)coords {
    if (![ReittiMapkitHelper isValidCoordinate:_coords]) {
        _coords = CLLocationCoordinate2DMake([[self.coordsDictionary objectForKey:@"y"] floatValue],[[self.coordsDictionary objectForKey:@"x"] floatValue]);
    }
    return _coords;
}

+(RouteLegLocation *)routeLocationFromMatkaRouteLocation:(MatkaRouteLocation *)matkaLocation {
    RouteLegLocation *loc = [[RouteLegLocation alloc] init];
    
    loc.arrTime = matkaLocation.parsedArrivalTime;
    loc.depTime = matkaLocation.parsedDepartureTime;
    loc.name = matkaLocation.name;
    loc.coords = matkaLocation.coords;
    loc.coordsString = matkaLocation.coordString;
    
    return loc;
}

+(RouteLegLocation *)routeLocationFromMatkaRouteStop:(MatkaRouteStop *)matkaStop {
    RouteLegLocation *loc = [[RouteLegLocation alloc] init];
    
    loc.arrTime = matkaStop.parsedArrivalTime;
    loc.depTime = matkaStop.parsedDepartureTime;
    loc.name = matkaStop.name;
    loc.coords = matkaStop.coords;
    loc.coordsString = matkaStop.coordString;
    loc.stopCode = matkaStop.stopId;
    loc.shortCode = matkaStop.stopCode;
    loc.stopAddress = matkaStop.name;
    
    return loc;
}

@end
