//
//  DroppedPinManager.m
//  
//
//  Created by Anteneh Sahledengel on 23/6/15.
//
//

#import "DroppedPinManager.h"

@implementation DroppedPinManager

@synthesize droppedPin;

+ (id)sharedManager {
    static DroppedPinManager *sharedDroppedPinManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDroppedPinManager = [[self alloc] init];
    });
    return sharedDroppedPinManager;
}

@end
