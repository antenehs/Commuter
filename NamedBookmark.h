//
//  NamedBookmark.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "OrderedManagedObject.h"
#import "Mapping.h"
#import "ApiProtocols.h"

#if MAIN_APP
@interface NamedBookmark : OrderedManagedObject<DictionaryMappable> {
#else
@interface NamedBookmark : OrderedManagedObject<RoutableLocationProtocol, DictionaryMappable> {
#endif
    
#ifndef APPLE_WATCH
    UIImage *_annotationImage;
#endif
}

#if MAIN_APP
-(id)initWithDictionary:(NSDictionary *)dict andManagedObjectContext:(NSManagedObjectContext *)context;
#endif
    
-(void)updateValuesFromDictionary:(NSDictionary *)dict;

+(instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
-(instancetype)initWithDictionary:(NSDictionary *)dict;
-(NSDictionary *)dictionaryRepresentation;
    
//-(void)updateValuesFromDictionary:(NSDictionary *)dict;

+ (NSArray *)getAddressTypeList;
+ (NSString *)getMonochromePictureNameForColorPicture:(NSString *)colorPicture;

-(NSString *)getFullAddress;
-(NSString *)getUniqueIdentifier;

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

@property (nonatomic, readonly)BOOL isHomeAddress;
@property (nonatomic, readonly)BOOL isWorkAddress;

#ifndef APPLE_WATCH
@property (nonatomic, strong, readonly) UIImage *annotationImage;
#endif

@end
