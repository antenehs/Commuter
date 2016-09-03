//
//  MatkaTransportTypeManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 1/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumManager.h"

@interface MatkaTransportTypeManager : NSObject

+(instancetype)sharedManager;

-(VehicleType)vehicleTypeForTransportId:(NSString *)typeId;
-(LegTransportType)legTypeForMatkaTrasportType:(NSString *)typeId;
-(LineType)lineTypeForMatkaTrasportType:(NSString *)typeId;

@end
