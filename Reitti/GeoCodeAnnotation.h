//
//  GeoCodeAnnotation.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GeoCode.h"

@interface GeoCodeAnnotation : NSObject<MKAnnotation> {
    
	NSString *title;
	CLLocationCoordinate2D coordinate;
    
}

@property (nonatomic, copy) NSNumber *code;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) LocationType locationType;

- (id)initWithTitle:(NSString *)ttl andSubtitle:(NSString *)subttl coordinate:(CLLocationCoordinate2D)c2d andLocationType:(LocationType)type;

@end
