//
//  DigiStopAtDistance.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/17/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "DigiStop.h"

@interface DigiStopAtDistance : NSObject

@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) DigiStop *stop;

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;

@end
