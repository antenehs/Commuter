//
//  ActivityInterfaceController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 2/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface ActivityInterfaceController : WKInterfaceController

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *activityLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *activityImage;


@end
