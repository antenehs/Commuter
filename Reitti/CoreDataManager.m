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

#pragma mark - Create methods
- (NSManagedObject *)createNewObjectForEntityNamed:(NSString *)entityName {
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
}

#pragma mark - Save methods
- (void)saveState {
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

- (void)saveReittiManagedObject:(ReittiManagedObjectBase *)object {
    //Think about this later.. Might have to move the cookie object to be owned by this class.
    
    
//    object.objectLID = [NSNumber numberWithInt:nextObjectLID];
//    object.dateModified = [NSDate date];
//    
//    NSError *error = nil;
//    
//    if (![object.managedObjectContext save:&error]) {
//        // Handle error
//        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
//        exit(-1);  // Fail
//    }
//    
//    [self increamentObjectLID];
}

#pragma mark - Fetch Methods
-(NSArray *)fetchAllObjectsForEntityNamed:(NSString *)entityName {
    return [self fetchObjectsForEntityNamed:entityName predicateString:nil sortWithPropertyNamed:nil assending:false];
}

-(NSArray *)fetchAllObjectsForEntityNamed:(NSString *)entityName sortWithPropertyNamed:(NSString *)propertyNamed assending:(BOOL)assending {
    return [self fetchObjectsForEntityNamed:entityName predicateString:nil sortWithPropertyNamed:propertyNamed assending:assending];
}

-(NSArray *)fetchObjectsForEntityNamed:(NSString *)entityName predicateString:(NSString *)predString sortWithPropertyNamed:(NSString *)sortPropertyName assending:(BOOL)assending {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    if (predString) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
        [request setPredicate:predicate];
    }
    
    if (sortPropertyName) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortPropertyName ascending:assending];
        [request setSortDescriptors:@[sortDescriptor]];
    }
    
    NSError *error = nil;
    
    NSArray *recentRoutes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    return recentRoutes;
}



#pragma mark - NOT REFACTORED METHODS. Works for now. Don't fix it.

@end
