//
//  BusStopShort+MapView.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/19/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusStopShort.h"
#import "MapViewProtocols.h"

@interface BusStopShort (MapView) <MapViewAnnotationProtocol>

-(id<MKAnnotation>)basicLocationAnnotation;
-(id<MKAnnotation>)basicLocationAnnotationWithIdentifier:(NSString *)annotationIdentier andAnnotationType:(ReittiAnnotationType)annotType;

@end
