//
//  BikeStation+MapView.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BikeStation.h"
#import "MapViewProtocols.h"

@interface BikeStation(MapView) <MapViewAnnotationProtocol>

-(id<MKAnnotation>)basicLocationAnnotation;

@end
