//
//  CacheManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/6/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "CacheManager.h"

@implementation CacheManager

@synthesize managedObjectContext;

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context{
    self.managedObjectContext = context;
    
    return self;
    
}

@end
