//
//  DefaultAnnotationCallout.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/19/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotationThumbnail.h"
#import "DetailAnnotationSettings.h"
#import "AnnotationProtocols.h"

@interface DefaultAnnotationCallout : UIView <AnnotationCalloutProtocol>

+(instancetype)calloutForThumbnail:(AnnotationThumbnail *)thumbnail andSettings:(DetailAnnotationSettings *)settings;

- (void)setGoToHereDurationString:(MKMapView *)mapView duration:(NSString *)durationString withIconImage:(UIImage *)image;

@end
