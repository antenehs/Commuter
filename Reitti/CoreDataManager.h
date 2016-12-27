//
//  CoreDataManager.h
//  
//
//  Created by Anteneh Sahledengel on 15/6/15.
//
//

#import <Foundation/Foundation.h>
#import "ReittiManagedObjectBase.h"

@interface CoreDataManager : NSObject

+ (id)sharedManager;
-(id)init;

- (NSManagedObject *)createNewObjectForEntityNamed:(NSString *)entityName;

- (void)saveState;

-(NSArray *)fetchAllObjectsForEntityNamed:(NSString *)entityName;
-(NSArray *)fetchAllObjectsForEntityNamed:(NSString *)entityName sortWithPropertyNamed:(NSString *)sortPropertyName assending:(BOOL)assending;
-(NSArray *)fetchObjectsForEntityNamed:(NSString *)entityName predicateString:(NSString *)predString sortWithPropertyNamed:(NSString *)sortPropertyName assending:(BOOL)assending;



@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
