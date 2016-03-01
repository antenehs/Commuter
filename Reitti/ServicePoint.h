//
//  ServicePoint.h
//
//  Created by Anteneh Sahledengel on 31/8/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Attributes;

@interface ServicePoint : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *projection;
@property (nonatomic, strong) NSString *wkt;
@property (nonatomic, strong) Attributes *attributes;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) CLLocationCoordinate2D coordinates;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;



@end
