//
//  DroppedPinManager.h
//  
//
//  Created by Anteneh Sahledengel on 23/6/15.
//
//

#import <Foundation/Foundation.h>
#import "GeoCode.h"

@interface DroppedPinManager : NSObject

+ (id)sharedManager;

@property (strong, nonatomic) GeoCode *droppedPin;


@end
