//
//  InterfaceController.h
//  WatchRoutes Extension
//
//  Created by Anteneh Sahledengel on 26/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "WatchCommunicationManager.h"
#import "HomeAndWorkRowController.h"
#import "LocationRowController.h"

@interface HomeInterfaceController : WKInterfaceController <WCManagerDelegate, HomeAndWorkRowControllerDelegate>

@end
