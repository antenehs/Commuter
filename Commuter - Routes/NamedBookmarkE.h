//
//  NamedBookmarkE.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NamedBookmarkE : NSObject

-(NSString *)getFullAddress;
-(NSString *)getUniqueIdentifier;

-(id)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, retain) NSNumber * objectLID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * streetAddress;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * coords;
@property (nonatomic, retain) NSString * searchedName;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * iconPictureName;
@property (nonatomic, retain) NSString * monochromeIconName;

@property (nonatomic, retain) NSDate * dateModified;

@end
