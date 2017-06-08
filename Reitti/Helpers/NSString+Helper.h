//
//  NSString+Split.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/2/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NSString (Helper)

- (NSArray *)asa_stringsBySplittingOnString:(NSString *)splitString;
+ (BOOL)isNilOrEmpty:(NSString *)string;

- (CLLocationCoordinate2D)convertTo2DCoord;
+ (NSString *)stringRepresentationOf2DCoord:(CLLocationCoordinate2D)coord;

- (NSNumber *)asa_numberValue;

@end
