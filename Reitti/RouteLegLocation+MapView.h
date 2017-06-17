//
//  RouteLegLocation+MapView.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteLegLocation.h"
#import "MapViewHelpers.h"

@interface RouteLegLocation (MapView) <MapViewAnnotationProtocol>

-(id<MKAnnotation>)routeStartLocationAnnotation;
-(id<MKAnnotation>)routeEndLocationAnnotation;

@end
