//
//  StopLine.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "StopLine.h"

@implementation StopLine

@synthesize fullCode, code, name, direction, destination, lineStart, lineEnd, lineType;

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.fullCode = [aDecoder decodeObjectForKey:@"fullCode"];
    self.code = [aDecoder decodeObjectForKey:@"code"];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.direction = [aDecoder decodeObjectForKey:@"direction"];
    self.destination = [aDecoder decodeObjectForKey:@"destination"];
    self.lineType = (LineType)[[aDecoder decodeObjectForKey:@"lineType"] intValue];
    self.lineStart = [aDecoder decodeObjectForKey:@"lineStart"];
    self.lineEnd = [aDecoder decodeObjectForKey:@"lineEnd"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:fullCode forKey:@"fullCode"];
    [aCoder encodeObject:code forKey:@"code"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:direction forKey:@"direction"];
    [aCoder encodeObject:destination forKey:@"destination"];
    [aCoder encodeObject:[NSNumber numberWithInt:(int)lineType] forKey:@"lineType"];
    [aCoder encodeObject:lineStart forKey:@"lineStart"];
    [aCoder encodeObject:lineEnd forKey:@"lineEnd"];
}

+ (instancetype)initFromDictionary:(NSDictionary *)dictionary {
    StopLine *line = [StopLine new];
    
    line.fullCode = [line objectOrNilForKey:@"fullCode" fromDictionary:dictionary];
    line.code = [line objectOrNilForKey:@"code" fromDictionary:dictionary];
    line.name = [line objectOrNilForKey:@"name" fromDictionary:dictionary];
    line.direction = [line objectOrNilForKey:@"direction" fromDictionary:dictionary];
    line.destination = [line objectOrNilForKey:@"destination" fromDictionary:dictionary];
    line.lineType = (LineType)[[line objectOrNilForKey:@"lineType" fromDictionary:dictionary] intValue];
    line.lineStart = [line objectOrNilForKey:@"lineStart" fromDictionary:dictionary];
    line.lineEnd = [line objectOrNilForKey:@"lineEnd" fromDictionary:dictionary];
    
    return line;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [@{} mutableCopy];
    
    [dict setValue:fullCode forKey:@"fullCode"];
    [dict setValue:code forKey:@"code"];
    [dict setValue:name forKey:@"name"];
    [dict setValue:direction forKey:@"direction"];
    [dict setValue:destination forKey:@"destination"];
    [dict setValue:[NSNumber numberWithInt:(int)lineType] forKey:@"lineType"];
    [dict setValue:lineStart forKey:@"lineStart"];
    [dict setValue:lineEnd forKey:@"lineEnd"];
    
    return dict;
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
