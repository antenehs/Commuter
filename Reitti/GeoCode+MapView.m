//
//  GeoCode+MapView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/20/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "GeoCode+MapView.h"

@implementation GeoCode (MapView)

-(id<MKAnnotation>)mapAnnotation {
    NSString * name = self.name;
    NSString * city = self.city;
    
    if (self.locationType == LocationTypeContact) {
        city = self.fullAddressString;
    }
    if (self.locationType  == LocationTypeAddress){
        name = self.getStreetAddressString;
    }
    
    AnnotationThumbnail *geoAnT = [[AnnotationThumbnail alloc] init];
    geoAnT.image = self.annotationImage;
    geoAnT.title = name;
    geoAnT.subtitle = city;
    geoAnT.coordinate = self.coordinates;
    geoAnT.annotationType = GeoCodeType;
    geoAnT.reuseIdentifier = self.iconPictureName;
    
    DetailedAnnotation *annot = [DetailedAnnotation annotationWithThumbnail:geoAnT];
    annot.associatedObject = self;
    
    return annot;
}

@end
