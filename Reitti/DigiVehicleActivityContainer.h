//
//  DigiVehicleActivityContainer.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/21/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"

@interface DigiVehicleActivityContainer : NSObject<Mappable>

@property (nonatomic, strong) NSString *version;
@property (nonatomic) double responseTimestamp;
@property (nonatomic, strong) NSArray *vehicles;

@end
