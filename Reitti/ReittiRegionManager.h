//
//  ReittiRegionManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
//#import <RestKit/RestKit.h>

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

-(NSString *)getNameOfRegion:(Region)region;
-(Region)identifyRegionOfCoordinate:(CLLocationCoordinate2D)coords;
+(CLLocationCoordinate2D)getCoordinateForRegion:(Region)region;
-(BOOL)areCoordinatesInTheSameRegion:(CLLocationCoordinate2D)firstcoord andCoordinate:(CLLocationCoordinate2D)secondCoord;

//For debugging
-(NSArray *)hslRegionCornerLocations;
-(NSArray *)treRegionCornerLocations;

@end
