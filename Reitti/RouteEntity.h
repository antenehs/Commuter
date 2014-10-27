//
//  RouteEntity.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 16/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RouteEntity : NSManagedObject

@property (nonatomic, retain) NSString * routeUniqueName;
@property (nonatomic, retain) NSString * fromLocationName;
@property (nonatomic, retain) NSString * fromLocationCoordsString;
@property (nonatomic, retain) NSString * toLocationName;
@property (nonatomic, retain) NSString * toLocationCoordsString;

@end