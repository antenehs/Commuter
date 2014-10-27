//
//  BusStopShort.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusStopShort : NSObject

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSString * codeShort;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * coords;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * distance;

@end
