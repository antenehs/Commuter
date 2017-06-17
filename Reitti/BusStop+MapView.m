//
//  BusStop+MapView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/16/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "BusStop+MapView.h"
#import "AppManager.h"

@implementation BusStop (MapView)



-(id<MKAnnotation>)basicLocationAnnotation {
    return [self basicLocationAnnotationWithIdentifier:nil andAnnotationType:StopLocation];
}

-(id<MKAnnotation>)basicLocationAnnotationWithIdentifier:(NSString *)annotationIdentier andAnnotationType:(ReittiAnnotationType)annotType {

    NSString * name = self.name;
    NSString * codeShort = self.codeShort;
    NSString * imageName = [AppManager stopAnnotationImageNameForStopType:self.stopType];
    NSString *reuseIdentifier = annotationIdentier ? annotationIdentier : [NSString stringWithFormat:@"StopLocation-%@", imageName];
    
    LocationsAnnotation *annotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:codeShort andCoordinate:self.coordinate andLocationType:annotType];
    annotation.code = self.gtfsId;
    annotation.uniqueIdentifier = self.gtfsId;
    annotation.imageNameForView = imageName;
    annotation.annotIdentifier = reuseIdentifier;
    annotation.shrinkedImageColor = [AppManager colorForStopType:self.stopType];
    
    return annotation;
}

@end
