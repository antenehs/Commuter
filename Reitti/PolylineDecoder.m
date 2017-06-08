//
//  PolylineDecoder.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/5/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "PolylineDecoder.h"

#import "SwiftHeaders.h"

@implementation PolylineDecoder

+(NSArray *)decodePolyline:(NSString *)polylineString {
    if (!polylineString) return nil;
    
    Polyline *polyline = [[Polyline alloc] initWithEncodedPolyline:polylineString encodedLevels:nil precision: 1e5];
    
    
    return polyline ? polyline.coordinates : nil;
}

+(NSArray *)decodePolylineToLocations:(NSString *)polylineString {
    if (!polylineString) return nil;
    
    Polyline *polyline = [[Polyline alloc] initWithEncodedPolyline:polylineString encodedLevels:nil precision: 1e5];
    
    
    return polyline ? polyline.locations : nil;
}

@end
