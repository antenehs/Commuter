//
//  BusStop+MapView.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/16/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusStop.h"
#import "MapViewProtocols.h"

@interface BusStop (MapView) <MapViewAnnotationProtocol>

-(id<MKAnnotation>)basicLocationAnnotation;
-(id<MKAnnotation>)basicLocationAnnotationWithIdentifier:(NSString *)annotationIdentier andAnnotationType:(ReittiAnnotationType)annotType;

@end
