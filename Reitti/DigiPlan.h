//
//  DigiItineraries.h
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DigiLegs.h"
#import <MapKit/MapKit.h>
#import "Mapping.h"

@interface DigiPlan : NSObject <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) NSNumber *walkDistance;
@property (nonatomic, strong) NSNumber *walkTime;
@property (nonatomic, strong) NSNumber *endTime;
@property (nonatomic, strong) NSArray *legs;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSNumber *waitingTime;
@property (nonatomic, strong) NSNumber *startTime;

//Computed properties
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSNumber *numberOfNoneWalkLegs;
@property (nonatomic, strong) NSDate *parsedStartTime;
@property (nonatomic, strong) NSDate *parsedEndTime;
@property (nonatomic, strong) NSDate *timeAtFirstStop;
@property (nonatomic) CLLocationCoordinate2D startCoords;
@property (nonatomic) CLLocationCoordinate2D destinationCoords;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
