//
//  DigiLegs.h
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "EnumManager.h"
#import <MapKit/MapKit.h>

@class DigiPlace, DigiTrip;

@interface DigiLegs : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSNumber *transitLeg;
@property (nonatomic, strong) DigiTrip *trip;
@property (nonatomic, strong) NSNumber *realTime;
@property (nonatomic, strong) DigiPlace *from;
@property (nonatomic, strong) NSArray *intermediateStops;
@property (nonatomic, strong) NSString *mode;
@property (nonatomic, strong) NSNumber *rentedBike;
@property (nonatomic, strong) NSNumber *endTime;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSNumber *startTime;
@property (nonatomic, strong) DigiPlace *to;

@property(nonatomic)int legOrder;
@property(nonatomic)LegTransportType legType;
@property (nonatomic, strong) NSDate *parsedStartTime;
@property (nonatomic, strong) NSDate *parsedEndTime;
@property (nonatomic) CLLocationCoordinate2D startCoords;
@property (nonatomic) CLLocationCoordinate2D destinationCoords;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;

@end
