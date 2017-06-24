//
//  ReittiObjectProtocols.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol ReittiPlace <NSObject>

@property (nonatomic)CLLocationCoordinate2D coordinates;

@end

@protocol ReittiPlaceAtDistance <ReittiPlace>

@property (nonatomic, strong) NSNumber *distance;

@end
