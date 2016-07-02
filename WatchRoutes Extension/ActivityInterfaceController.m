//
//  ActivityInterfaceController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 2/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ActivityInterfaceController.h"

@interface ActivityInterfaceController ()

@end

@implementation ActivityInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSString *labelText = (NSString *)context;
    if (labelText) [self.activityLabel setText:labelText];
    
    [self.activityImage setImageNamed:@"ai"];
    [self.activityImage startAnimatingWithImagesInRange:NSMakeRange(0, 40) duration:1.0 repeatCount:0];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



