//
//  DigiStopAtDistance.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/17/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DigiStop.h"
#import "Mapping.h"

@interface DigiStopAtDistance : NSObject<Mappable>

@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) DigiStop *stop;

@end
