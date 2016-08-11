//
//  OrderedManagedObject.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReittiManagedObjectBase.h"

@interface OrderedManagedObject : ReittiManagedObjectBase

@property (nonatomic, retain) NSNumber * order;

@end
