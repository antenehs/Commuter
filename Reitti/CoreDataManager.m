//
//  CoreDataManager.m
//  
//
//  Created by Anteneh Sahledengel on 15/6/15.
//
//

#import "CoreDataManager.h"
#import "AppDelegate.h"

@implementation CoreDataManager

@synthesize managedObjectContext;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static CoreDataManager *sharedCoreDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCoreDataManager = [[self alloc] init];
    });
    return sharedCoreDataManager;
}

-(id)init{
    AppDelegate *appDelegate = [[AppDelegate alloc] init];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    return self;
}

@end
