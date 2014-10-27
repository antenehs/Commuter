//
//  RouteLegLocation.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RouteLegLocation.h"

@implementation RouteLegLocation

@synthesize isHeaderLocation;
@synthesize locationLegType;
@synthesize locationLegOrder;

@synthesize coordsDictionary;
@synthesize coordsString;
@synthesize arrTime;
@synthesize depTime;
@synthesize name;
@synthesize stopCode;
@synthesize shortCode;
@synthesize stopAddress;

-(id)initFromDictionary:(NSDictionary *)legDict{
    if (self = [super init]) {
        self.coordsDictionary = legDict[@"coord"];
        self.coordsString = [NSString stringWithFormat:@"%@,%@",self.coordsDictionary[@"x"],self.coordsDictionary[@"y"]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmm"];
        
        self.arrTime = [formatter dateFromString:legDict[@"arrTime"]];
        self.depTime = [formatter dateFromString:legDict[@"depTime"]];
        self.name = legDict[@"name"];
        self.stopCode = legDict[@"code"];
        self.shortCode = legDict[@"shortCode"];
        self.stopAddress = legDict[@"stopAddress"];
        
        NSLog(@"leg is %@",self);
    }
    return self;
}

@end
