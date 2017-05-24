//
//  ReittiManagedObjectBase.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiManagedObjectBase.h"

@implementation ReittiManagedObjectBase

#if MAIN_APP

@dynamic objectLID;
@dynamic dateModified;

#else

@synthesize objectLID;
@synthesize dateModified;

#endif
@end
