//
//  LocationAnnotationThumbnail.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/17/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

//NOT USED CURRENTLY

@interface LocationAnnotationThumbnail : NSObject

@property(nonatomic) BOOL canShowCallout;
@property(nonatomic) BOOL enabled;

@property(nonatomic, strong)id<MKAnnotation> annotation;
@property(nonatomic, strong) NSString *reuseIdentifer;

@property(nonatomic, strong) NSString *imageNameForView;


@end
