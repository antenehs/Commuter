//
//  NamedBookmarkE.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "NamedBookmarkE.h"

@implementation NamedBookmarkE

-(BOOL)isHomeAddress {
    return [self.name isEqualToString:@"Home"] || [self.iconPictureName isEqualToString:@"home-100.png"];
}

-(BOOL)isWorkAddress {
    return [self.name isEqualToString:@"Work"] || [self.iconPictureName isEqualToString:@"work-filled-100.png"];
}

#pragma mark - to and from dictionary methods

-(id)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
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

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

-(NSString *)getFullAddress{
    if ([self.streetAddress containsString:self.city])
        return self.streetAddress;
    else
        return [NSString stringWithFormat:@"%@,%@", self.streetAddress, self.city];
}

-(NSString *)getUniqueIdentifier{
    return [NSString stringWithFormat:@"%@ - %@", self.name , [self getFullAddress]];
}

@end
