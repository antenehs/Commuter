//
//  RouteLeg+MapView.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/16/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteLeg.h"
#import "MapViewHelpers.h"

@interface RouteLeg (MapView) <MapViewPolylineProtocol>

-(ReittiPolyline *)fullLinePolyline;

@end
