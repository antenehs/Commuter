//
//  LocationRowController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 2/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "LocationRowController.h"

@implementation LocationRowController

-(void)setUpWithNamedBookmark:(NamedBookmarkE *)namedBookmark {
    self.bookmark = namedBookmark;
//    UIImage *image = [UIImage imageNamed:namedBookmark.iconPictureName];
//    if (image) {
//        [self.locationImageView setImage:image];
//    }
    
    [self.nameLabel setText:namedBookmark.name];
}

@end
