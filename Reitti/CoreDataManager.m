//
//  CoreDataManager.m
//  
//
//  Created by Anteneh Sahledengel on 15/6/15.
//
//

#import "CoreDataManager.h"
#import "AppDelegate.h"
#import "CookieEntity.h"


NSString * const kBookmarksWithAnnotationUpdated = @"namedBookmarksUpdated";

@interface CoreDataManager ()

@property(nonatomic, strong) CookieEntity *cookieEntity;
@property (nonatomic) BOOL doneInitialTasks;

@end

@implementation CoreDataManager

@synthesize managedObjectContext;
@synthesize cookieEntity;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static CoreDataManager *sharedCoreDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCoreDataManager = [[self alloc] init];
    });
    
    if (!sharedCoreDataManager.doneInitialTasks) {
        sharedCoreDataManager.doneInitialTasks = YES;
        
        [sharedCoreDataManager doInitialTasks];
    }
    
    return sharedCoreDataManager;
}

-(id)init {
    self = [super init];
    [self doInitialTasks];
    self.doneInitialTasks = YES;
    
    return self;
}

//This should be done on the main thread
-(void)doInitialTasks {
    AppDelegate *appDelegate = [[AppDelegate alloc] init];
    self.managedObjectContext = appDelegate.managedObjectContext;
    [self.managedObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType]];
    
    [self fetchSystemCookie];
    nextObjectLID = [self.cookieEntity.objectLID intValue];
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
    if (!object) return;
    
    [self saveReittiManagedObjects:@[object]];
}

- (void)saveReittiManagedObjects:(NSArray *)objects {
    if (!objects || objects.count < 1) return;
    
    for (ReittiManagedObjectBase *object in objects) {
        object.objectLID = [NSNumber numberWithInt:[self getNextObjectLid]];
        object.dateModified = [NSDate date];
    }
    
    [self saveState];
}

#pragma mark - delete managed object
-(void)deleteManagedObject:(NSManagedObject *)object {
    [self.managedObjectContext deleteObject:object];
    [self saveState];
}

-(void)deleteManagedObjects:(NSArray *)objects {
    if (!objects || objects.count < 1) { return; }
    
    for (NSManagedObject *object in objects) {
        [self.managedObjectContext deleteObject:object];
    }
    
    [self saveState];
}

#pragma mark - update order
-(void)updateOrderedManagedObjectOrderTo:(NSArray *)orderedObjects {
    
    for (int i = 0; i < orderedObjects.count; i++) {
        
        OrderedManagedObject *object = orderedObjects[i];
        if (![object isKindOfClass:[OrderedManagedObject class]]) return;
        
        object.order = [NSNumber numberWithInt:i + 1];
    }
    
    [self saveReittiManagedObjects:orderedObjects];
}

#pragma mark - Object LId
-(void)fetchSystemCookie{
    NSArray *systemCookies = [self fetchAllObjectsForEntityNamed:@"CookieEntity"];
    
    if (systemCookies.count > 0) {
        self.cookieEntity = [systemCookies objectAtIndex:0];
    } else {
        [self initializeSystemCookie];
    }
}

-(void)initializeSystemCookie{
    self.cookieEntity = (CookieEntity *)[self createNewObjectForEntityNamed:@"CookieEntity"];
    
    [self.cookieEntity setObjectLID:[NSNumber numberWithInt:100]];
    [self.cookieEntity setAppOpenCount:[NSNumber numberWithInt:0]];
    
    [self saveState];
}

-(void)increamentObjectLID {
//    [self fetchSystemCookie];
    
    [self.cookieEntity setObjectLID:[NSNumber numberWithInt:(nextObjectLID + 1)]];
    //TODO: Go back to this later
    [self saveState];
    
    nextObjectLID++;
}

-(int)getNextObjectLid {
    [self increamentObjectLID];
    
    return nextObjectLID;
}

#pragma mark - Fetch Methods
-(NSArray *)fetchValuesOfProperties:(NSArray *)properties fromEntitiyNamed:(NSString *)entityName {
    return [self fetchObjectsForEntityNamed:entityName predicateString:nil sortWithPropertyNamed:nil assending:NO propertiesToFetch:properties];
}

-(NSArray *)fetchAllOrderedObjectsForEntityNamed:(NSString *)entityName {
    return [self fetchAllObjectsForEntityNamed:entityName sortWithPropertyNamed:@"order" assending:YES];
}

-(NSArray *)fetchAllObjectsForEntityNamed:(NSString *)entityName {
    return [self fetchObjectsForEntityNamed:entityName predicateString:nil sortWithPropertyNamed:nil assending:false];
}

-(NSArray *)fetchAllObjectsForEntityNamed:(NSString *)entityName sortWithPropertyNamed:(NSString *)propertyNamed assending:(BOOL)assending {
    return [self fetchObjectsForEntityNamed:entityName predicateString:nil sortWithPropertyNamed:propertyNamed assending:assending];
}

-(NSArray *)fetchObjectsForEntityNamed:(NSString *)entityName predicateString:(NSString *)predString {
    return [self fetchObjectsForEntityNamed:entityName predicateString:predString sortWithPropertyNamed:nil assending:NO];
}

-(NSArray *)fetchObjectsForEntityNamed:(NSString *)entityName predicateString:(NSString *)predString sortWithPropertyNamed:(NSString *)sortPropertyName assending:(BOOL)assending {
    return [self fetchObjectsForEntityNamed:entityName predicateString:predString sortWithPropertyNamed:sortPropertyName assending:assending propertiesToFetch:nil];
}

-(NSArray *)fetchObjectsForEntityNamed:(NSString *)entityName predicateString:(NSString *)predString sortWithPropertyNamed:(NSString *)sortPropertyName assending:(BOOL)assending propertiesToFetch:(NSArray *)properties {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    if (predString) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
        [request setPredicate:predicate];
    }
    
    if (sortPropertyName) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortPropertyName ascending:assending];
        [request setSortDescriptors:@[sortDescriptor]];
    }
    
    if (properties && properties.count > 0) {
        [request setResultType:NSDictionaryResultType];
        
        [request setReturnsDistinctResults:YES];
        [request setPropertiesToFetch :properties];
    }
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (properties && properties.count == 1) {
        fetchedObjects = [self simplifyCoreDataDictionaryArray:fetchedObjects withKey:properties[0]];
    }
    
    return fetchedObjects.count > 0 ? fetchedObjects : nil;
}

#pragma mark - Helper methods

-(NSMutableArray *)simplifyCoreDataDictionaryArray:(NSArray *)array withKey:(NSString *)key{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (NSDictionary * dict in array) {
        [retArray addObject:[dict objectForKey:key]];
    }
    return retArray;
}



#pragma mark - Migrations

@end
