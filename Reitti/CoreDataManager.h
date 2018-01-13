//
//  CoreDataManager.h
//  
//
//  Created by Anteneh Sahledengel on 15/6/15.
//
//

#import <Foundation/Foundation.h>
#import "ReittiManagedObjectBase.h"
#import "OrderedManagedObject.h"

extern NSString * const kBookmarksWithAnnotationUpdated;

@interface CoreDataManager : NSObject {
    int nextObjectLID;
}

+(id)sharedManager;
//-(id)init;

-(NSManagedObject *)createNewObjectForEntityNamed:(NSString *)entityName;

-(int)getNextObjectLid;

-(void)saveState;
-(void)saveReittiManagedObject:(ReittiManagedObjectBase *)object;

-(void)deleteManagedObject:(NSManagedObject *)object;
-(void)deleteManagedObjects:(NSArray *)objects;

-(void)updateOrderedManagedObjectOrderTo:(NSArray *)orderedObjects;

-(NSArray *)fetchValuesOfProperties:(NSArray *)properties fromEntitiyNamed:(NSString *)entityName;
-(NSArray *)fetchAllOrderedObjectsForEntityNamed:(NSString *)entityName;
-(NSArray *)fetchAllObjectsForEntityNamed:(NSString *)entityName;
-(NSArray *)fetchAllObjectsForEntityNamed:(NSString *)entityName sortWithPropertyNamed:(NSString *)sortPropertyName assending:(BOOL)assending;
-(NSArray *)fetchObjectsForEntityNamed:(NSString *)entityName predicateString:(NSString *)predString;
-(NSArray *)fetchObjectsForEntityNamed:(NSString *)entityName predicateString:(NSString *)predString sortWithPropertyNamed:(NSString *)sortPropertyName assending:(BOOL)assending;
-(NSArray *)fetchObjectsForEntityNamed:(NSString *)entityName predicateString:(NSString *)predString sortWithPropertyNamed:(NSString *)sortPropertyName assending:(BOOL)assending propertiesToFetch:(NSArray *)properties;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
