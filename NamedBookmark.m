//
//  NamedBookmark.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "NamedBookmark.h"
#import "ReittiStringFormatter.h"
#import "CoreDataManager.h"

@implementation NamedBookmark

@dynamic objectLID;
@dynamic name;
@dynamic streetAddress;
@dynamic city;
@dynamic coords;
@dynamic searchedName;
@dynamic notes;
@dynamic iconPictureName;
@dynamic monochromeIconName;

+ (NSArray *)getAddressTypeList {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"AddressTypeList" ofType:@"plist"];
    return [NSArray arrayWithContentsOfFile:plistPath];
}

+ (NSString *)getMonochromePictureNameForColorPicture:(NSString *)colorPicture{
    NSArray *addressTypes = [NamedBookmark getAddressTypeList];
    for (NSDictionary *dict in addressTypes) {
        if ([[dict objectForKey:@"Picture"] isEqualToString:colorPicture]) {
            return [dict objectForKey:@"MonochromePicture"];
        }
    }
    
    return @"location-black-50.png";
}

-(NSString *)getFullAddress{
    if ([self.streetAddress containsString:self.city])
        return self.streetAddress;
    else
        return [NSString stringWithFormat:@"%@, %@", self.streetAddress, self.city];
}

-(NSString *)getUniqueIdentifier{
    return [NSString stringWithFormat:@"%@ - %@", self.name , [self getFullAddress]];
}

- (CLLocationCoordinate2D)cl2dCoords{
    return [ReittiStringFormatter convertStringTo2DCoord:self.coords];
}

#pragma mark - to and from dictionary methods

-(void)updateValuesFromDictionary:(NSDictionary *)dict {
    self.name = [self objectOrNilForKey:@"name" fromDictionary:dict];
    self.streetAddress = [self objectOrNilForKey:@"streetAddress" fromDictionary:dict];
    self.city = [self objectOrNilForKey:@"city" fromDictionary:dict];
    self.coords = [self objectOrNilForKey:@"coords" fromDictionary:dict];
    self.searchedName = [self objectOrNilForKey:@"searchedName" fromDictionary:dict];
    self.notes = [self objectOrNilForKey:@"notes" fromDictionary:dict];
    self.iconPictureName = [self objectOrNilForKey:@"iconPictureName" fromDictionary:dict];
    self.monochromeIconName = [self objectOrNilForKey:@"monochromeIconName" fromDictionary:dict];
    
    //Base class properties
    self.objectLID = [self objectOrNilForKey:@"objectLID" fromDictionary:dict];
    self.dateModified = [self objectOrNilForKey:@"dateModified" fromDictionary:dict];
}

-(id)initWithDictionary:(NSDictionary *)dict andManagedObjectContext:(NSManagedObjectContext *)context{
    self = (NamedBookmark *)[NSEntityDescription insertNewObjectForEntityForName:@"NamedBookmark" inManagedObjectContext:context];
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        [self updateValuesFromDictionary:dict];
    }
    
    return self;
}

-(NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.name forKey:@"name"];
    [mutableDict setValue:self.streetAddress forKey:@"streetAddress"];
    [mutableDict setValue:self.city forKey:@"city"];
    [mutableDict setValue:self.coords forKey:@"coords"];
    [mutableDict setValue:self.searchedName forKey:@"searchedName"];
    [mutableDict setValue:self.notes forKey:@"notes"];
    [mutableDict setValue:self.iconPictureName forKey:@"iconPictureName"];
    [mutableDict setValue:self.monochromeIconName forKey:@"monochromeIconName"];
    //Base object properties
    [mutableDict setValue:self.objectLID forKey:@"objectLID"];
    [mutableDict setValue:self.dateModified forKey:@"dateModified"];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

-(UIImage *)annotationImage {
    if (!_annotationImage) {
        CGRect outerFrame = CGRectMake(0, 0, 83, 124);
        CGRect topFrame = CGRectMake(3, 0, 77, 77);
        CGRect baseFrame = CGRectMake(10, 76, 63, 48);
        
        UIView *holder = [[UIView alloc] initWithFrame:outerFrame];
        
        UIImageView *topImageView = [[UIImageView alloc] initWithFrame:topFrame];
        [topImageView setImage:[UIImage imageNamed:self.iconPictureName]];
        [holder addSubview:topImageView];
        
        UIImageView *baseImageView = [[UIImageView alloc] initWithFrame:baseFrame];
        [baseImageView setImage:[UIImage imageNamed:@"AnnotationLeg"]];
        [holder addSubview:baseImageView];
        
        UIGraphicsBeginImageContext(holder.bounds.size);
        [holder.layer renderInContext:UIGraphicsGetCurrentContext()];
        _annotationImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return _annotationImage;
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
