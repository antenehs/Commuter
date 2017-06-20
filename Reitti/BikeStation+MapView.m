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
    NSString * name = self.name;
    NSString * codeShort = self.stationId;
    
    AnnotationThumbnail *bikeAnT = [[AnnotationThumbnail alloc] init];
    bikeAnT.image = [UIImage imageNamed:[AppManager stationAnnotionImageNameForBikeStation:self]];
    bikeAnT.code = codeShort;
    bikeAnT.shortCode = codeShort;
    bikeAnT.title = name;
    bikeAnT.subtitle = [NSString stringWithFormat:@"%@ - %@", self.bikesAvailableString, self.spacesAvailableString];
    bikeAnT.coordinate = self.coordinates;
    bikeAnT.annotationType = BikeStationLocation;
    bikeAnT.reuseIdentifier = [AppManager stationAnnotionImageNameForBikeStation:self];
    
    DetailedAnnotation *annotation = [DetailedAnnotation annotationWithThumbnail:bikeAnT];
    annotation.associatedObject = self;
    annotation.shrinkedImageColor = [AppManager systemYellowColor];
    
    return annotation;
}

-(id<MKAnnotation>)basicLocationAnnotation {
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
