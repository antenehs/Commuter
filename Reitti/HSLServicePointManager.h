//
//  HSLServicePointManager.h
//  
//
//  Created by Anteneh Sahledengel on 31/8/15.
//
//

#import <Foundation/Foundation.h>
#import "ServicePoint.h"
#import "Attributes.h"

@interface HSLServicePointManager : NSObject

+(NSMutableArray *)getServicePoints;
+(NSMutableArray *)getSalesPoints;

@end
