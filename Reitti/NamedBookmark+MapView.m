//
//  NamedBookmark+MapView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/20/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "NamedBookmark+MapView.h"

@implementation NamedBookmark (MapView)

-(id<MKAnnotation>)mapAnnotation {
    
    AnnotationThumbnail *bookmrkAnT = [[AnnotationThumbnail alloc] init];
    bookmrkAnT.shortCode = self.getUniqueIdentifier;
    bookmrkAnT.image = self.annotationImage;
    bookmrkAnT.title = self.name;
    bookmrkAnT.subtitle = self.getFullAddress;
    bookmrkAnT.coordinate = self.coordinates;
    bookmrkAnT.annotationType = FavouriteType;
    bookmrkAnT.reuseIdentifier = self.iconPictureName;
    
    DetailedAnnotation *annot = [DetailedAnnotation annotationWithThumbnail:bookmrkAnT];
    annot.associatedObject = self;
    annot.uniqueIdentifier = self.getUniqueIdentifier;
    
    return annot;
}

@end
