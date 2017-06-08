//
//  PolylineDecoder.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/5/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PolylineDecoder : NSObject

+(NSArray *)decodePolyline:(NSString *)polylineString;
+(NSArray *)decodePolylineToLocations:(NSString *)polylineString;

@end
