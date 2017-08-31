//
//  LineCoreDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/28/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager.h"
#import "LineEntity.h"
#import "LineEntity+Transformation.h"
#import "Line.h"

@interface LineCoreDataManager : CoreDataManager

+(id)sharedManager;

//Saving
-(void)saveLineToCoreData:(Line *)line;

//Deleting
-(void)deleteLineEntityForLine:(Line *)reittiLine;

//Fetching
-(NSArray *)fetchAllSavedLines;

@property (strong, nonatomic, readonly) NSMutableArray *allLineEntityCodes;

@end
