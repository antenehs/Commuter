//
//  RouteHeaderRowController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import "Route.h"
@interface RouteHeaderRowController : NSObject

-(void)setupWithRoute:(Route *)route;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *toLabel;

@end
