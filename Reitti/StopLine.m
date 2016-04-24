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

@end
