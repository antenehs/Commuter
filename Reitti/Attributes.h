//
//  Attributes.h
//
//  Created by Anteneh Sahledengel on 31/8/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Attributes : NSObject <NSCoding, NSCopying>

//@property (nonatomic, strong) NSString *attributesDescription;
//@property (nonatomic, assign) id fieldAddressHelp;
//@property (nonatomic, assign) id fieldAddressHelpRendered;
//@property (nonatomic, assign) id body;
//@property (nonatomic, assign) id uri;
//@property (nonatomic, assign) id fieldImages;
@property (nonatomic, strong) NSString *fieldCoordinatesRendered;
//@property (nonatomic, strong) NSString *nid;
//@property (nonatomic, strong) NSString *bodyRendered;
@property (nonatomic, strong) NSString *titleRendered;
//@property (nonatomic, strong) NSString *nidRendered;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *fieldAddressRendered;
//@property (nonatomic, strong) NSString *fieldCoordinates;
//@property (nonatomic, assign) id fieldImagesRendered;
//@property (nonatomic, strong) NSString *fieldAddress;
//@property (nonatomic, strong) NSString *name;
//@property (nonatomic, strong) NSString *uriRendered;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
