//
//  StopRowController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import "StopEntity.h"

@interface StopRowController : NSObject

-(void)setUpWithStop:(StopEntity *)stop;

@property (strong, nonatomic)StopEntity *stop;

@property (strong, nonatomic) IBOutlet WKInterfaceImage *stopimage;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *stopNameLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *stopDetailLabel;


@end
