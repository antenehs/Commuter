//
//  LinePattern.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/19/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "LinePattern.h"

@implementation LinePattern

@synthesize name, code, headsign, directionId;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.code = [aDecoder decodeObjectForKey:@"code"];
    self.headsign = [aDecoder decodeObjectForKey:@"headsign"];
    self.directionId = [aDecoder decodeObjectForKey:@"directionId"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:code forKey:@"code"];
    [aCoder encodeObject:headsign forKey:@"headsign"];
    [aCoder encodeObject:directionId forKey:@"directionId"];
}

@end
