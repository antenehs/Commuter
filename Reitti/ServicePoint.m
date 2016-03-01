//
//  ServicePoint.m
//
//  Created by Anteneh Sahledengel on 31/8/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "ServicePoint.h"
#import "Attributes.h"

NSString *const kServicePointProjection = @"projection";
NSString *const kServicePointWkt = @"wkt";
NSString *const kServicePointAttributes = @"attributes";


@interface ServicePoint ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ServicePoint

@synthesize projection = _projection;
@synthesize wkt = _wkt;
@synthesize attributes = _attributes;


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
            self.projection = [self objectOrNilForKey:kServicePointProjection fromDictionary:dict];
            self.wkt = [self objectOrNilForKey:kServicePointWkt fromDictionary:dict];
            self.attributes = [Attributes modelObjectWithDictionary:[dict objectForKey:kServicePointAttributes]];

    }
    
    return self;
    
}

//Public members
-(NSString *)title{
    if (!_title) {
        NSString *ttl = self.attributes.title;
        if (ttl)
            _title = [ttl stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n\f\r"]];
        else
            _title = @"Sales point";
    }
    
    return _title;
}

-(NSString *)address{
    if (!_address) {
        NSString *addrs = self.attributes.fieldAddressRendered;
        if (addrs)
            _address = [addrs stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n\f\r"]];
        else
            _address = @"";
    }
    
    return _address;
}

-(CLLocationCoordinate2D)coordinates{
    if (CLLocationCoordinate2DIsValid(_coordinates)) {
        NSString *searchedString = self.attributes.fieldCoordinatesRendered;
        
        if ([self.attributes.title isEqualToString:@"Tikkurilan asema "]) {
            NSLog(@"%@", searchedString);
        }
        
        if (searchedString != nil && [[searchedString lowercaseString] containsString:@"point ("]) {
            NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
            NSString *pattern = @".*?POINT \\((.*)\\).*";
            NSError  *error = nil;
            
            NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
            NSArray* matches = [regex matchesInString:searchedString options:0 range:searchedRange];
            for (NSTextCheckingResult* match in matches) {
//                NSString* matchText = [searchedString substringWithRange:[match range]];
//                NSLog(@"match: %@", matchText);
                NSRange group1 = [match rangeAtIndex:1];
//                NSLog(@"group1: %@", [searchedString substringWithRange:group1]);
                
                NSString *coordString = [searchedString substringWithRange:group1];
                if (coordString == nil)
                    return _coordinates;
                
                NSArray *coords = [coordString componentsSeparatedByString:@" "];
                
                if (coords.count != 2)
                    return _coordinates;
                
                CLLocationCoordinate2D coord = {.latitude =  [[coords objectAtIndex:1] floatValue], .longitude =  [[coords objectAtIndex:0] floatValue]};
                
                _coordinates = coord;
            }
        }
    }
    
    return _coordinates;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.projection forKey:kServicePointProjection];
    [mutableDict setValue:self.wkt forKey:kServicePointWkt];
    [mutableDict setValue:[self.attributes dictionaryRepresentation] forKey:kServicePointAttributes];

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

    self.projection = [aDecoder decodeObjectForKey:kServicePointProjection];
    self.wkt = [aDecoder decodeObjectForKey:kServicePointWkt];
    self.attributes = [aDecoder decodeObjectForKey:kServicePointAttributes];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_projection forKey:kServicePointProjection];
    [aCoder encodeObject:_wkt forKey:kServicePointWkt];
    [aCoder encodeObject:_attributes forKey:kServicePointAttributes];
}

- (id)copyWithZone:(NSZone *)zone
{
    ServicePoint *copy = [[ServicePoint alloc] init];
    
    if (copy) {

        copy.projection = [self.projection copyWithZone:zone];
        copy.wkt = [self.wkt copyWithZone:zone];
        copy.attributes = [self.attributes copyWithZone:zone];
    }
    
    return copy;
}


@end
