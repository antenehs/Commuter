//
//  NamedBookmark.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "ReittiManagedObjectBase.h"


@interface NamedBookmark : ReittiManagedObjectBase

+ (NSArray *)getAddressTypeList;
+ (NSString *)getMonochromePictureNameForColorPicture:(NSString *)colorPicture;

-(NSString *)getFullAddress;
-(NSString *)getUniqueIdentifier;

-(id)initWithDictionary:(NSDictionary *)dict;
-(NSDictionary *)dictionaryRepresentation;

@property (nonatomic, retain) NSNumber * objectLID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * streetAddress;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * coords;
@property (nonatomic, retain) NSString * searchedName;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * iconPictureName;
@property (nonatomic, retain) NSString * monochromeIconName;

@property (nonatomic, readonly) CLLocationCoordinate2D cl2dCoords;

@end
