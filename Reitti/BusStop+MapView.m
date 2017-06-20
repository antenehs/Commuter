//
//  BusStop+MapView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/16/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "BusStop+MapView.h"
#import "AppManager.h"
#import "ASA_Helpers.h"
#import "SwiftHeaders.h"
#import "BusStopShort+MapView.h"

@implementation BusStop (MapView)

-(id<MKAnnotation>)mapAnnotation {
//    CLLocationCoordinate2D coordinate = self.coordinate;
//    if (coordinate.latitude < 30 || coordinate.latitude > 90 || coordinate.longitude < 10 || coordinate.longitude > 90)
//        return nil;
//    
//    NSString *codeShort = self.codeShort ? self.codeShort : @"";
//    
//    AnnotationThumbnail *annotationThumb = [[AnnotationThumbnail alloc] init];
//    annotationThumb.image = [AppManager stopAnnotationImageForStopType:self.stopType];
//    annotationThumb.code = self.gtfsId;
//    annotationThumb.shortCode = codeShort;
//    annotationThumb.title = self.name;
//    if (self.linesString) {
//        annotationThumb.subtitle = [NSString stringWithFormat:@"Code: %@ · %@", codeShort, self.linesString];
//    } else {
//        annotationThumb.subtitle = [NSString stringWithFormat:@"Code: %@", codeShort];
//    }
//    
//    annotationThumb.coordinate = coordinate;
//    annotationThumb.annotationType = [EnumManager annotTypeForNearbyStopType:self.stopType];
//    annotationThumb.reuseIdentifier = [self annotationReuseIdentifier];
//    
//    DetailedAnnotation *annotation = [DetailedAnnotation annotationWithThumbnail:annotationThumb];
//    annotation.associatedObject = self;
//    annotation.shrinkedImageColor = [AppManager colorForStopType:self.stopType];
    
    return [super mapAnnotation];
}

-(id<MKAnnotation>)basicLocationAnnotation {
    return [self basicLocationAnnotationWithIdentifier:nil andAnnotationType:StopLocation];
}

-(id<MKAnnotation>)basicLocationAnnotationWithIdentifier:(NSString *)annotationIdentier andAnnotationType:(ReittiAnnotationType)annotType {
    
    return [super basicLocationAnnotationWithIdentifier:annotationIdentier andAnnotationType:annotType];
}

@end
