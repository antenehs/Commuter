//
//  NamedBookmark.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "NamedBookmark.h"
#import "ReittiStringFormatter.h"

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
        return [NSString stringWithFormat:@"%@,\n%@", self.streetAddress, self.city];
}

- (CLLocationCoordinate2D)cl2dCoords{
    return [ReittiStringFormatter convertStringTo2DCoord:self.coords];
}

@end
