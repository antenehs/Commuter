//
//  LocationRowController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 2/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import "NamedBookmarkE.h"

@interface LocationRowController : NSObject

-(void)setUpWithNamedBookmark:(NamedBookmarkE *)namedBookmark;

@property (strong, nonatomic) IBOutlet WKInterfaceImage *locationImageView;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *nameLabel;

@property (strong, nonatomic) NamedBookmarkE *bookmark;

@end
