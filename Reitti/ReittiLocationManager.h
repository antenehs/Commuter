//
//  ReittiLocationManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/21/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol ReittiLocationManagerProtocol <NSObject>

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;

@end

@interface ReittiLocationManager : NSObject

+(instancetype)sharedManager;

-(CLLocation *)currentUserLocation;

@property (nonatomic, weak)id<ReittiLocationManagerProtocol> delegate;

@end
