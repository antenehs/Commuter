//
//  LineCoreDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/28/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "LineCoreDataManager.h"
#import "NSArray+Helper.h"

@interface LineCoreDataManager ()

@property (nonatomic) BOOL doneInitialTasks;
@property (strong, nonatomic) NSMutableArray *allLineEntityCodes;

@end

@implementation LineCoreDataManager

+(instancetype)sharedManager {
    static LineCoreDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [LineCoreDataManager new];
    });
    
    //Do this outside the dispatch
    if (!sharedInstance.doneInitialTasks) {
        sharedInstance.doneInitialTasks = YES;
        
        [sharedInstance fetchAllLineEntitiesCodes];
    }
    
    return sharedInstance;
}

-(id)init {
    self = [super init];
    
    if (self) {
        self.doneInitialTasks = NO;
    }
    
    return self;
}

-(LineEntity *)createNewLineEntity {
    return (LineEntity *)[super createNewObjectForEntityNamed:kLineEntityName];
}

#pragma mark -
#pragma mark Saving

-(void)saveLineToCoreData:(Line *)line {
    if (!line) return;

    //Check it doesn't exist already
    if ([self doesLineEntityExistWithCode:line.code]) {
        [self deleteLineEntityForCode:line.code];
    }
    
    //Create new
    LineEntity *newEntity = [self createNewLineEntity];
    [newEntity initFromReittiLine:line];
    
    [super saveReittiManagedObject:newEntity];
}

#pragma mark -
#pragma mark Deleting

-(void)deleteLineEntityForLine:(Line *)reittiLine {
    [self deleteLineEntityForCode:reittiLine.code];
}

-(void)deleteLineEntityForCode:(NSString *)code {
    id existingLine = [self fetchLineEntityForCode:code];
    if (!existingLine) return;
    
    [super deleteManagedObject:(NSManagedObject *)existingLine];
}

#pragma mark -
#pragma mark Fetching

-(NSArray *)fetchAllSavedLines {
    NSArray *lineEntities = [self fetchAllLineEntities];
    return [lineEntities asa_mapWith:^id(LineEntity *lineEntity) {
        return [lineEntity reittiLineFromEntity];
    }];
}

-(NSArray *)fetchAllLineEntities {
    return [super fetchAllObjectsForEntityNamed: kLineEntityName];
}

-(LineEntity *)fetchLineEntityForCode:(NSString *)code {
    NSString *predString = [NSString stringWithFormat:@"code == '%@'", code];
    
    NSArray *lineEntities = [super fetchObjectsForEntityNamed:kLineEntityName predicateString:predString];
    return [lineEntities firstObject];
}

-(void)fetchAllLineEntitiesCodes {
    NSArray *codes = [super fetchObjectsForEntityNamed:kLineEntityName predicateString:nil sortWithPropertyNamed:@"code" assending:NO propertiesToFetch:@[@"code"]];
    
    self.allLineEntityCodes = codes ? codes : [@[] mutableCopy];;
}

-(NSMutableArray *)allLineEntityCodes {
    [self fetchAllLineEntitiesCodes];
    return _allLineEntityCodes;
}

#pragma mark -
#pragma mark Helpers

-(BOOL)doesLineEntityExistWithCode:(NSString *)code{
    [self fetchAllLineEntitiesCodes];
    return [self.allLineEntityCodes containsObject:code];
}


@end
