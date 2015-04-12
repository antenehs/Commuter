//
//  CookieEntity.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "ReittiManagedObjectBase.h"

@interface CookieEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * objectLID;
@property (nonatomic, retain) CLLocation * lastMapPosition;
@property (nonatomic, retain) NSArray * searchHistory;
@property (nonatomic, retain) NSNumber * appOpenCount;

@end
