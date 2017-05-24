//
//  ReittiManagedObjectBase.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#if MAIN_APP

#import <CoreData/CoreData.h>
@interface ReittiManagedObjectBase : NSManagedObject

#else

#import <Foundation/Foundation.h>
@interface ReittiManagedObjectBase : NSObject

#endif

@property (nonatomic, retain) NSNumber * objectLID;
@property (nonatomic, retain) NSDate * dateModified;

@end
