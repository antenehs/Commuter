//
//  RouteSummaryRowController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import "Route.h"

@interface RouteSummaryRowController : NSObject

-(void)setupWithRoute:(Route *)route;

@property (nonatomic, strong)Route *route;

@property (strong, nonatomic) IBOutlet WKInterfaceSeparator *rowSeparator;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *transportsGroup;

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *detailGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *detailLabel;

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *firstLegGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *firstLegImage;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *firstLegLabel;

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *firstArrowGroup;

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *secondLegGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *secondLegImage;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *secondLegLabel;

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *secondArrowGroup;

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *thirdLegGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *thirdLegImage;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *thirdLegLabel;

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *thirdArrowGroup;

@end
