//
//  BusStopShort+MapView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/19/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "BusStopShort+MapView.h"
#import "AppManager.h"

@implementation BusStopShort (MapView)

-(id<MKAnnotation>)mapAnnotation {
    CLLocationCoordinate2D coordinate = self.coordinate;
    if (coordinate.latitude < 30 || coordinate.latitude > 90 || coordinate.longitude < 10 || coordinate.longitude > 90)
        return nil;
    
    NSString *codeShort = self.codeShort ? self.codeShort : @"";
    
    AnnotationThumbnail *annotationThumb = [[AnnotationThumbnail alloc] init];
    annotationThumb.image = [AppManager stopAnnotationImageForStopType:self.stopType];
    annotationThumb.code = self.gtfsId;
    annotationThumb.shortCode = codeShort;
    annotationThumb.title = self.name;
    if (self.linesString) {
        annotationThumb.subtitle = [NSString stringWithFormat:@"Code: %@ · %@", codeShort, self.linesString];
    } else {
        annotationThumb.subtitle = [NSString stringWithFormat:@"Code: %@", codeShort];
    }
    
    annotationThumb.coordinate = coordinate;
    annotationThumb.annotationType = [EnumManager annotTypeForNearbyStopType:self.stopType];
    annotationThumb.reuseIdentifier = [self annotationReuseIdentifier];
    
    DetailedAnnotation *annotation = [DetailedAnnotation annotationWithThumbnail:annotationThumb];
    annotation.associatedObject = self;
    annotation.shrinkedImageColor = [AppManager colorForStopType:self.stopType];
    
    return annotation;
}

-(id<MKAnnotation>)basicLocationAnnotation {
    return [self basicLocationAnnotationWithIdentifier:nil andAnnotationType:StopLocation];
}

-(id<MKAnnotation>)basicLocationAnnotationWithIdentifier:(NSString *)annotationIdentier andAnnotationType:(ReittiAnnotationType)annotType {
    
    NSString * name = self.name;
    NSString * codeShort = self.codeShort;
    NSString * imageName = [AppManager stopAnnotationImageNameForStopType:self.stopType];
    NSString *reuseIdentifier = annotationIdentier ? annotationIdentier : [self annotationReuseIdentifier];
    
    LocationsAnnotation *annotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:codeShort andCoordinate:self.coordinate andLocationType:annotType];
    annotation.code = self.gtfsId;
    annotation.uniqueIdentifier = self.gtfsId;
    annotation.imageNameForView = imageName;
    annotation.annotIdentifier = reuseIdentifier;
    annotation.shrinkedImageColor = [AppManager colorForStopType:self.stopType];
    
    return annotation;
}

#pragma mark - Helpers
-(NSString *)annotationReuseIdentifier {
    NSString * imageName = [AppManager stopAnnotationImageNameForStopType:self.stopType];
    return [NSString stringWithFormat:@"StopLocation-%@", imageName];
}

@end
