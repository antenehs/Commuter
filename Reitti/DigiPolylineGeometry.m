//
//  DigiPolylineGeometry.m
//
//  Created by Anteneh Sahledengel on 6/5/17
//  Copyright (c) 2017 shaby ltd. All rights reserved.
//

#import "DigiPolylineGeometry.h"
#import "PolylineDecoder.h"
#import "ReittiStringFormatter.h"

NSString *const kDigiPolylineGeometryPoints = @"points";
NSString *const kDigiPolylineGeometryLength = @"length";


@interface DigiPolylineGeometry ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;
@property (nonatomic, strong) NSArray *coordinates;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) NSArray *coordinateStrings;

@end

@implementation DigiPolylineGeometry

@synthesize points = _points;
@synthesize length = _length;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.points = [self objectOrNilForKey:kDigiPolylineGeometryPoints fromDictionary:dict];
            self.length = [[self objectOrNilForKey:kDigiPolylineGeometryLength fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.points forKey:kDigiPolylineGeometryPoints];
    [mutableDict setValue:[NSNumber numberWithDouble:self.length] forKey:kDigiPolylineGeometryLength];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.points = [aDecoder decodeObjectForKey:kDigiPolylineGeometryPoints];
    self.length = [aDecoder decodeDoubleForKey:kDigiPolylineGeometryLength];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_points forKey:kDigiPolylineGeometryPoints];
    [aCoder encodeDouble:_length forKey:kDigiPolylineGeometryLength];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiPolylineGeometry *copy = [[DigiPolylineGeometry alloc] init];
    
    if (copy) {

        copy.points = [self.points copyWithZone:zone];
        copy.length = self.length;
    }
    
    return copy;
}

#pragma mark - Mappable

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:@{
                                                   @"points" : @"points",
                                                   @"length" : @"length"
                                                   }];
}

#pragma mark - Computed Properties

-(NSArray *)coordinates {
    if (!_coordinates) {
        _coordinates = [PolylineDecoder decodePolyline:self.points];
    }
    
    return _coordinates;
}

-(NSArray *)locations {
    if (!_locations) {
        _locations = [PolylineDecoder decodePolylineToLocations:self.points];
    }
    
    return _locations;
}

-(NSArray *)coordinateStrings {
    if (!_coordinateStrings) {
        NSArray *locations = [self locations];
        if (locations && locations.count > 0) {
            NSMutableArray *tempArray = [@[] mutableCopy];
            for (CLLocation *coord in locations) {
                NSString *coordString = [ReittiStringFormatter convert2DCoordToString:coord.coordinate];
                if (coordString) [tempArray addObject:coordString];
                else {
                    tempArray = nil;
                    break;
                }
            }
            
            _coordinateStrings = tempArray;
        }
    }
    
    return _coordinateStrings;
}


@end
