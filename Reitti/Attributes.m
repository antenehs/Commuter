//
//  Attributes.m
//
//  Created by Anteneh Sahledengel on 31/8/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "Attributes.h"


NSString *const kAttributesDescription = @"description";
NSString *const kAttributesFieldAddressHelp = @"field_address_help";
NSString *const kAttributesFieldAddressHelpRendered = @"field_address_help_rendered";
NSString *const kAttributesBody = @"body";
NSString *const kAttributesUri = @"uri";
NSString *const kAttributesFieldImages = @"field_images";
NSString *const kAttributesFieldCoordinatesRendered = @"field_coordinates_rendered";
NSString *const kAttributesNid = @"nid";
NSString *const kAttributesBodyRendered = @"body_rendered";
NSString *const kAttributesTitleRendered = @"title_rendered";
NSString *const kAttributesNidRendered = @"nid_rendered";
NSString *const kAttributesTitle = @"title";
NSString *const kAttributesFieldAddressRendered = @"field_address_rendered";
NSString *const kAttributesFieldCoordinates = @"field_coordinates";
NSString *const kAttributesFieldImagesRendered = @"field_images_rendered";
NSString *const kAttributesFieldAddress = @"field_address";
NSString *const kAttributesName = @"name";
NSString *const kAttributesUriRendered = @"uri_rendered";


@interface Attributes ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Attributes

//@synthesize attributesDescription = _attributesDescription;
//@synthesize fieldAddressHelp = _fieldAddressHelp;
//@synthesize fieldAddressHelpRendered = _fieldAddressHelpRendered;
//@synthesize body = _body;
//@synthesize uri = _uri;
//@synthesize fieldImages = _fieldImages;
@synthesize fieldCoordinatesRendered = _fieldCoordinatesRendered;
//@synthesize nid = _nid;
//@synthesize bodyRendered = _bodyRendered;
@synthesize titleRendered = _titleRendered;
//@synthesize nidRendered = _nidRendered;
@synthesize title = _title;
@synthesize fieldAddressRendered = _fieldAddressRendered;
//@synthesize fieldCoordinates = _fieldCoordinates;
//@synthesize fieldImagesRendered = _fieldImagesRendered;
//@synthesize fieldAddress = _fieldAddress;
//@synthesize name = _name;
//@synthesize uriRendered = _uriRendered;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
//            self.attributesDescription = [self objectOrNilForKey:kAttributesDescription fromDictionary:dict];
//            self.fieldAddressHelp = [self objectOrNilForKey:kAttributesFieldAddressHelp fromDictionary:dict];
//            self.fieldAddressHelpRendered = [self objectOrNilForKey:kAttributesFieldAddressHelpRendered fromDictionary:dict];
//            self.body = [self objectOrNilForKey:kAttributesBody fromDictionary:dict];
//            self.uri = [self objectOrNilForKey:kAttributesUri fromDictionary:dict];
//            self.fieldImages = [self objectOrNilForKey:kAttributesFieldImages fromDictionary:dict];
            self.fieldCoordinatesRendered = [self objectOrNilForKey:kAttributesFieldCoordinatesRendered fromDictionary:dict];
//            self.nid = [self objectOrNilForKey:kAttributesNid fromDictionary:dict];
//            self.bodyRendered = [self objectOrNilForKey:kAttributesBodyRendered fromDictionary:dict];
            self.titleRendered = [self objectOrNilForKey:kAttributesTitleRendered fromDictionary:dict];
//            self.nidRendered = [self objectOrNilForKey:kAttributesNidRendered fromDictionary:dict];
            self.title = [self objectOrNilForKey:kAttributesTitle fromDictionary:dict];
            self.fieldAddressRendered = [self objectOrNilForKey:kAttributesFieldAddressRendered fromDictionary:dict];
//            self.fieldCoordinates = [self objectOrNilForKey:kAttributesFieldCoordinates fromDictionary:dict];
//            self.fieldImagesRendered = [self objectOrNilForKey:kAttributesFieldImagesRendered fromDictionary:dict];
//            self.fieldAddress = [self objectOrNilForKey:kAttributesFieldAddress fromDictionary:dict];
//            self.name = [self objectOrNilForKey:kAttributesName fromDictionary:dict];
//            self.uriRendered = [self objectOrNilForKey:kAttributesUriRendered fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
//    [mutableDict setValue:self.attributesDescription forKey:kAttributesDescription];
//    [mutableDict setValue:self.fieldAddressHelp forKey:kAttributesFieldAddressHelp];
//    [mutableDict setValue:self.fieldAddressHelpRendered forKey:kAttributesFieldAddressHelpRendered];
//    [mutableDict setValue:self.body forKey:kAttributesBody];
//    [mutableDict setValue:self.uri forKey:kAttributesUri];
//    [mutableDict setValue:self.fieldImages forKey:kAttributesFieldImages];
    [mutableDict setValue:self.fieldCoordinatesRendered forKey:kAttributesFieldCoordinatesRendered];
//    [mutableDict setValue:self.nid forKey:kAttributesNid];
//    [mutableDict setValue:self.bodyRendered forKey:kAttributesBodyRendered];
    [mutableDict setValue:self.titleRendered forKey:kAttributesTitleRendered];
//    [mutableDict setValue:self.nidRendered forKey:kAttributesNidRendered];
    [mutableDict setValue:self.title forKey:kAttributesTitle];
    [mutableDict setValue:self.fieldAddressRendered forKey:kAttributesFieldAddressRendered];
//    [mutableDict setValue:self.fieldCoordinates forKey:kAttributesFieldCoordinates];
//    [mutableDict setValue:self.fieldImagesRendered forKey:kAttributesFieldImagesRendered];
//    [mutableDict setValue:self.fieldAddress forKey:kAttributesFieldAddress];
//    [mutableDict setValue:self.name forKey:kAttributesName];
//    [mutableDict setValue:self.uriRendered forKey:kAttributesUriRendered];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

//    self.attributesDescription = [aDecoder decodeObjectForKey:kAttributesDescription];
//    self.fieldAddressHelp = [aDecoder decodeObjectForKey:kAttributesFieldAddressHelp];
//    self.fieldAddressHelpRendered = [aDecoder decodeObjectForKey:kAttributesFieldAddressHelpRendered];
//    self.body = [aDecoder decodeObjectForKey:kAttributesBody];
//    self.uri = [aDecoder decodeObjectForKey:kAttributesUri];
//    self.fieldImages = [aDecoder decodeObjectForKey:kAttributesFieldImages];
    self.fieldCoordinatesRendered = [aDecoder decodeObjectForKey:kAttributesFieldCoordinatesRendered];
//    self.nid = [aDecoder decodeObjectForKey:kAttributesNid];
//    self.bodyRendered = [aDecoder decodeObjectForKey:kAttributesBodyRendered];
    self.titleRendered = [aDecoder decodeObjectForKey:kAttributesTitleRendered];
//    self.nidRendered = [aDecoder decodeObjectForKey:kAttributesNidRendered];
    self.title = [aDecoder decodeObjectForKey:kAttributesTitle];
    self.fieldAddressRendered = [aDecoder decodeObjectForKey:kAttributesFieldAddressRendered];
//    self.fieldCoordinates = [aDecoder decodeObjectForKey:kAttributesFieldCoordinates];
//    self.fieldImagesRendered = [aDecoder decodeObjectForKey:kAttributesFieldImagesRendered];
//    self.fieldAddress = [aDecoder decodeObjectForKey:kAttributesFieldAddress];
//    self.name = [aDecoder decodeObjectForKey:kAttributesName];
//    self.uriRendered = [aDecoder decodeObjectForKey:kAttributesUriRendered];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

//    [aCoder encodeObject:_attributesDescription forKey:kAttributesDescription];
//    [aCoder encodeObject:_fieldAddressHelp forKey:kAttributesFieldAddressHelp];
//    [aCoder encodeObject:_fieldAddressHelpRendered forKey:kAttributesFieldAddressHelpRendered];
//    [aCoder encodeObject:_body forKey:kAttributesBody];
//    [aCoder encodeObject:_uri forKey:kAttributesUri];
//    [aCoder encodeObject:_fieldImages forKey:kAttributesFieldImages];
    [aCoder encodeObject:_fieldCoordinatesRendered forKey:kAttributesFieldCoordinatesRendered];
//    [aCoder encodeObject:_nid forKey:kAttributesNid];
//    [aCoder encodeObject:_bodyRendered forKey:kAttributesBodyRendered];
    [aCoder encodeObject:_titleRendered forKey:kAttributesTitleRendered];
//    [aCoder encodeObject:_nidRendered forKey:kAttributesNidRendered];
    [aCoder encodeObject:_title forKey:kAttributesTitle];
    [aCoder encodeObject:_fieldAddressRendered forKey:kAttributesFieldAddressRendered];
//    [aCoder encodeObject:_fieldCoordinates forKey:kAttributesFieldCoordinates];
//    [aCoder encodeObject:_fieldImagesRendered forKey:kAttributesFieldImagesRendered];
//    [aCoder encodeObject:_fieldAddress forKey:kAttributesFieldAddress];
//    [aCoder encodeObject:_name forKey:kAttributesName];
//    [aCoder encodeObject:_uriRendered forKey:kAttributesUriRendered];
}

- (id)copyWithZone:(NSZone *)zone
{
    Attributes *copy = [[Attributes alloc] init];
    
    if (copy) {

//        copy.attributesDescription = [self.attributesDescription copyWithZone:zone];
//        copy.fieldAddressHelp = [self.fieldAddressHelp copyWithZone:zone];
//        copy.fieldAddressHelpRendered = [self.fieldAddressHelpRendered copyWithZone:zone];
//        copy.body = [self.body copyWithZone:zone];
//        copy.uri = [self.uri copyWithZone:zone];
//        copy.fieldImages = [self.fieldImages copyWithZone:zone];
        copy.fieldCoordinatesRendered = [self.fieldCoordinatesRendered copyWithZone:zone];
//        copy.nid = [self.nid copyWithZone:zone];
//        copy.bodyRendered = [self.bodyRendered copyWithZone:zone];
        copy.titleRendered = [self.titleRendered copyWithZone:zone];
//        copy.nidRendered = [self.nidRendered copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.fieldAddressRendered = [self.fieldAddressRendered copyWithZone:zone];
//        copy.fieldCoordinates = [self.fieldCoordinates copyWithZone:zone];
//        copy.fieldImagesRendered = [self.fieldImagesRendered copyWithZone:zone];
//        copy.fieldAddress = [self.fieldAddress copyWithZone:zone];
//        copy.name = [self.name copyWithZone:zone];
//        copy.uriRendered = [self.uriRendered copyWithZone:zone];
    }
    
    return copy;
}


@end
