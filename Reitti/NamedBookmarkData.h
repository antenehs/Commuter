//
//  NamedBookmarkData.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/13/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NamedBookmarkData : NSObject

@property (nonatomic, retain) NSNumber * objectLid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * streetAddress;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * coords;
@property (nonatomic, retain) NSString * searchedName;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * iconPictureName;
@property (nonatomic, retain) NSString * monochromeIconName;

@end
