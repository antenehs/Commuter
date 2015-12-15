//
//  WidgetHelpers.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WidgetHelpers : NSObject

//Expected format longitude,latitude
+(CLLocationCoordinate2D)convertStringTo2DCoord:(NSString *)coordString;

+(NSString *)convert2DCoordToString:(CLLocationCoordinate2D)coord;

+(NSString *)commaSepStringFromArray:(NSArray *)array withSeparator:(NSString *)separator;

@end
