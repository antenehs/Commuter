//
//  ExtensionDelegate.h
//  WatchRoutes Extension
//
//  Created by Anteneh Sahledengel on 26/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "Route.h"

@interface ExtensionDelegate : NSObject <WKExtensionDelegate>

-(Route *)complicationRoute;

@end
