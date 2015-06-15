//
//  CoreDataManager.h
//  
//
//  Created by Anteneh Sahledengel on 15/6/15.
//
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

+ (id)sharedManager;

-(id)init;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
