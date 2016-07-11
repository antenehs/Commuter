//
//  HomeAndWorkRowController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 2/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "HomeAndWorkRowController.h"

@implementation HomeAndWorkRowController

-(void)setUpWithHomeBookmark:(NamedBookmarkE *)home andWorkBookmark:(NamedBookmarkE *)work {
    
//    [self.homeGroup setHidden:!home];
//    [self.workGroup setHidden:!work];
    
    self.homeBookmark = home;
    self.workBookmark = work;
}

#pragma mark - IBActions
- (IBAction)homeButtonTapped {
    if (self.homeBookmark)
        [self.delegate selectedBookmark:self.homeBookmark];
    else
        [self.delegate selectedNoneExistingBookmark:@"Home"];
}

- (IBAction)workButtonTapped {
    if (self.workBookmark)
        [self.delegate selectedBookmark:self.workBookmark];
    else
        [self.delegate selectedNoneExistingBookmark:@"Work"];
}


@end
