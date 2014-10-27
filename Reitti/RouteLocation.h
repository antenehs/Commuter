//
//  RouteLocation.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteLeg.h"

@interface RouteLocation : NSObject

@property(nonatomic) bool isHeaderLocation;
@property (nonatomic) LegTransportType locationLegType;

@property (nonatomic, retain) NSDictionary * coordsDictionary;
@property (nonatomic, retain) NSDate * arrTime;
@property (nonatomic, retain) NSDate * depTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * stopCode;
@property (nonatomic, retain) NSString * shortCode;
@property (nonatomic, retain) NSString * stopAddress;

@end
