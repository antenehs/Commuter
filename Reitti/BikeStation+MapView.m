//
//  BikeStation+MapView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "BikeStation+MapView.h"
#import "AppManager.h"

@implementation BikeStation (MapView)

-(id<MKAnnotation>)mapAnnotation {
    NSString * subtitile = [NSString stringWithFormat:@"%@ - %@", self.bikesAvailableString, self.spacesAvailableString];
    
    LocationsAnnotation *newAnnotation = [[LocationsAnnotation alloc] initWithTitle:self.name
                                                                        andSubtitle:subtitile
                                                                      andCoordinate:self.coordinates
                                                                    andLocationType:BikeStationLocation];
    newAnnotation.code = self.stationId;
    
    newAnnotation.annotIdentifier = [AppManager stationAnnotionImageNameForBikeStation:self];
    newAnnotation.imageNameForView = [AppManager stationAnnotionImageNameForBikeStation:self];
    newAnnotation.shrinkedImageColor = [AppManager systemYellowColor];
    
    return newAnnotation;
}

@end
