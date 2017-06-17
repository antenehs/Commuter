//
//  RouteLegLocation+MapView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "RouteLegLocation+MapView.h"
#import "AppManager.h"

@implementation RouteLegLocation (MapView)

-(id<MKAnnotation>)mapAnnotation {
    NSString * name = self.name;
    NSString * subtitle = self.shortCode;
    
    BikeStation *station = nil;
    if (self.locationLegType == LegTypeBicycle) {
        station = [BikeStation bikeStationFromLegLocation:self];
        subtitle = [NSString stringWithFormat:@"%@ - %@", station.bikesAvailableString, station.spacesAvailableString];
    }
    
    if (name == nil || name == (id)[NSNull null]) { name = @""; }
    
    if (subtitle == nil || subtitle == (id)[NSNull null]) { subtitle = @""; }
    
    LocationsAnnotation *annotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:subtitle
                                                                      andCoordinate:self.coords andLocationType:TransferStopLocation];
    annotation.code = self.stopCode;
    
    NSString *imageNameForView = @"";
    if (self.locationLegType == LegTypeWalk) {
        imageNameForView = @"";
    }else if (self.locationLegType == LegTypeBicycle && station) {
        imageNameForView = [AppManager stationAnnotionImageNameForBikeStation:station];
        annotation.shrinkedImageColor = [AppManager systemYellowColor];
    }else{
        imageNameForView = [AppManager stopAnnotationImageNameForStopType:[EnumManager stopTypeFromLegType:self.locationLegType]];
        annotation.shrinkedImageColor = [AppManager colorForLegType:self.locationLegType];
    }
    
    annotation.imageNameForView = imageNameForView;
    annotation.annotIdentifier = [NSString stringWithFormat:@"LegLocation-%@", imageNameForView];
    annotation.associatedObject = self;
    
    return annotation;
}

-(id<MKAnnotation>)routeStartLocationAnnotation {
    
    NSString * name = self.name;
    NSString * shortCode = self.shortCode;
    
    if (name == nil || name == (id)[NSNull null]) { name = @""; }
    if (shortCode == nil || shortCode == (id)[NSNull null]) { shortCode = @""; }
    
    LocationsAnnotation *annotation = [[LocationsAnnotation alloc] initWithTitle:self.name andSubtitle:shortCode andCoordinate:self.coords andLocationType:StartLocation];
    annotation.imageNameForView = @"white-dot-16.png";
    annotation.annotIdentifier = @"startLocation";
    annotation.associatedObject = self;
    
    return annotation;
}

-(id<MKAnnotation>)routeEndLocationAnnotation {
    
    NSString * name = self.name;
    NSString * shortCode = self.shortCode;
    
    if (name == nil || name == (id)[NSNull null]) { name = @""; }
    if (shortCode == nil || shortCode == (id)[NSNull null]) { shortCode = @""; }
    
    LocationsAnnotation *annotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:shortCode andCoordinate:self.coords andLocationType:DestinationLocation];
    annotation.imageNameForView = @"finish_flag-50.png";
    annotation.annotIdentifier = @"finnishLocation";
    annotation.associatedObject = self;
    
    return annotation;
}

@end
