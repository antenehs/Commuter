//
//  ReittiMapkitHelper.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ReittiMapkitHelper : NSObject

+(BOOL)isValidCoordinate:(CLLocationCoordinate2D)coords;

@end
