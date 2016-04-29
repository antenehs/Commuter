//
//  ReittiRegionManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum
{
    HSLRegion = 0,
    TRERegion = 1,
    FINRegion = 4,
    HSLandTRERegion = 2,
    OtherRegion = 3
} Region;

@interface ReittiRegionManager : NSObject

+(id)sharedManager;

-(BOOL)isCoordinateInHSLRegion:(CLLocationCoordinate2D)coord;
-(BOOL)isCoordinateInTRERegion:(CLLocationCoordinate2D)coord;

@end
