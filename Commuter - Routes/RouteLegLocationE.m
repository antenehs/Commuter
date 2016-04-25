//
//  RouteLegLocation.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RouteLegLocationE.h"

@implementation RouteLegLocationE

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
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
        
        self.arrTime = [formatter dateFromString:legDict[@"arrTime"]];
        self.depTime = [formatter dateFromString:legDict[@"depTime"]];
        self.name = legDict[@"name"];
        self.stopCode = legDict[@"code"];
        self.shortCode = legDict[@"shortCode"];
        self.stopAddress = legDict[@"stopAddress"];
        
//        NSLog(@"leg is %@",self);
    }
    return self;
}

-(id) copy{
    RouteLegLocationE *copy = [[RouteLegLocationE alloc] init];
    
    copy.isHeaderLocation = self.isHeaderLocation;
    copy.locationLegType = self.locationLegType;
    copy.locationLegOrder = self.locationLegOrder;
    copy.coordsDictionary = self.coordsDictionary;
    copy.coordsString = self.coordsString;
    copy.arrTime = self.arrTime;
    copy.depTime = self.depTime;
    copy.name = self.name;
    copy.stopCode = self.stopCode;
    copy.shortCode = self.shortCode;
    copy.stopAddress = self.stopAddress;
    
    return copy;
}

@end
