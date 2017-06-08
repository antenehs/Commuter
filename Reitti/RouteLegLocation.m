//
//  RouteLegLocation.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RouteLegLocation.h"
#import "ASA_Helpers.h"

#ifndef APPLE_WATCH
#import "DigiDataModels.h"
#endif

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

-(id)initFromHSLandTREDictionary:(NSDictionary *)legDict{
    if (self = [super init]) {
        self.coordsDictionary = legDict[@"coord"];
        self.coordsString = [NSString stringWithFormat:@"%@,%@",self.coordsDictionary[@"x"],self.coordsDictionary[@"y"]];
        
        self.arrTime = [[ReittiDateHelper sharedFormatter] dateFromFullApiDateString:[self objectOrNilForKey:@"arrTime" fromDictionary:legDict]];
        self.depTime = [[ReittiDateHelper sharedFormatter] dateFromFullApiDateString:[self objectOrNilForKey:@"depTime" fromDictionary:legDict]];
        self.name = [self objectOrNilForKey:@"name" fromDictionary:legDict];
        self.stopCode = [self objectOrNilForKey:@"code" fromDictionary:legDict];
        self.shortCode = [self objectOrNilForKey:@"shortCode" fromDictionary:legDict];
        self.stopAddress = [self objectOrNilForKey:@"stopAddress" fromDictionary:legDict];
        
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

-(CLLocation *)coordLocation {
    if (!_coordLocation) {
        _coordLocation = [[CLLocation alloc] initWithLatitude:self.coords.latitude longitude:self.coords.longitude];
    }
    
    return _coordLocation;
}

#pragma mark - Dictionary representation
+(instancetype)initFromDictionary: (NSDictionary *)dictionary {
    if (!dictionary) return nil;
    
    RouteLegLocation *location = [RouteLegLocation new];
    location.coordsDictionary = [location objectOrNilForKey:@"coordsDictionary" fromDictionary:dictionary];
    location.arrTime = [location objectOrNilForKey:@"arrTime" fromDictionary:dictionary];
    location.depTime = [location objectOrNilForKey:@"depTime" fromDictionary:dictionary];
    location.name = [location objectOrNilForKey:@"locName" fromDictionary:dictionary];
    location.stopCode = [location objectOrNilForKey:@"stopCode" fromDictionary:dictionary];
    location.shortCode = [location objectOrNilForKey:@"shortCode" fromDictionary:dictionary];
    location.stopAddress = [location objectOrNilForKey:@"stopAddress" fromDictionary:dictionary];
    location.bikeStationId = [location objectOrNilForKey:@"bikeStationId" fromDictionary:dictionary];
    location.bikesAvailable = [location objectOrNilForKey:@"bikesAvailable" fromDictionary:dictionary];
    location.spacesAvailable = [location objectOrNilForKey:@"spacesAvailable" fromDictionary:dictionary];
    
    location.locationLegType = [[location objectOrNilForKey:@"locationLegType" fromDictionary:dictionary] intValue];
    location.isHeaderLocation = [[location objectOrNilForKey:@"isHeaderLocation" fromDictionary:dictionary] boolValue];
    location.locationLegOrder = [[location objectOrNilForKey:@"locationLegOrder" fromDictionary:dictionary] intValue];
    
    return location;
}

-(NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.coordsDictionary forKey:@"coordsDictionary"];
    [mutableDict setValue:self.arrTime forKey:@"arrTime"];
    [mutableDict setValue:self.depTime forKey:@"depTime"];
    [mutableDict setValue:self.name forKey:@"locName"];
    [mutableDict setValue:self.stopCode forKey:@"stopCode"];
    [mutableDict setValue:self.shortCode forKey:@"shortCode"];
    [mutableDict setValue:self.stopAddress forKey:@"stopAddress"];
    [mutableDict setValue:self.bikeStationId forKey:@"bikeStationId"];
    [mutableDict setValue:self.bikesAvailable forKey:@"bikesAvailable"];
    [mutableDict setValue:self.spacesAvailable forKey:@"spacesAvailable"];
    
    [mutableDict setValue:[NSNumber numberWithInt:(int)self.locationLegType] forKey:@"locationLegType"];
    [mutableDict setValue:[NSNumber numberWithBool:self.isHeaderLocation] forKey:@"isHeaderLocation"];
    [mutableDict setValue:[NSNumber numberWithInt:self.locationLegOrder] forKey:@"locationLegOrder"];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

#pragma mark - Init from other objects
+(RouteLegLocation *)routeLocationFromDigiPlace:(DigiPlace *)digiPlace {
    RouteLegLocation *loc = [[RouteLegLocation alloc] init];
    
    //TODO: Parse date from trip
    loc.arrTime = nil;
    loc.depTime = nil;
    loc.name = digiPlace.name;
    loc.coords = digiPlace.coords;
    loc.coordsString = [NSString stringWithFormat:@"%f,%f", digiPlace.coords.longitude, digiPlace.coords.latitude];
    
    if (digiPlace.intermediateStop) {
        loc.stopCode = digiPlace.intermediateStop.gtfsId;
        loc.shortCode = digiPlace.intermediateStop.code;
        loc.stopAddress = digiPlace.intermediateStop.name;
    }
    
    if (digiPlace.bikeRentalStation) {
        loc.bikeStationId = digiPlace.bikeRentalStation.stationId;
        loc.bikesAvailable = digiPlace.bikeRentalStation.bikesAvailable;
        loc.spacesAvailable = digiPlace.bikeRentalStation.spacesAvailable;
    }
    
    return loc;
}

+(RouteLegLocation *)routeLocationFromDigiIntermidiateStop:(DigiIntermediateStops *)digiStop {
    RouteLegLocation *loc = [[RouteLegLocation alloc] init];
    
    loc.arrTime = nil;
    loc.depTime = nil;
    loc.name = digiStop.name;
    loc.coords = digiStop.coords;
    loc.coordsString = [NSString stringWithFormat:@"%f,%f", digiStop.coords.longitude, digiStop.coords.latitude];
    loc.stopCode = digiStop.gtfsId;
    loc.shortCode = digiStop.code;
    loc.stopAddress = digiStop.name;
    
    return loc;
}

#ifndef APPLE_WATCH
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
#endif

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [self objectOrNil:object];
}

- (id)objectOrNil:(id)object {
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
