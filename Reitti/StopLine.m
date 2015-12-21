//
//  StopLine.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "StopLine.h"

@implementation StopLine

@synthesize fullCode, code, name, direction, destination;

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.fullCode = [aDecoder decodeObjectForKey:@"fullCode"];
    self.code = [aDecoder decodeObjectForKey:@"code"];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.direction = [aDecoder decodeObjectForKey:@"direction"];
    self.destination = [aDecoder decodeObjectForKey:@"destination"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:fullCode forKey:@"fullCode"];
    [aCoder encodeObject:code forKey:@"code"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:direction forKey:@"direction"];
    [aCoder encodeObject:destination forKey:@"destination"];
}

@end
