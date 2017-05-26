//
//  StopInterfaceController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "StopInterfaceController.h"
#import "BusStop.h"
#import "StopEntity.h"
#import "StopRowController.h"
#import "DepartureRowController.h"
#import "NSString+Helper.h"
#import "MapInterfaceController.h"

@interface StopInterfaceController ()

@property (strong, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (strong, nonatomic) BusStop *busStop;
@property (strong, nonatomic) StopEntity *stopEntity;

@end

@implementation StopInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    if (![context isKindOfClass:[NSDictionary class]])
        [self dismissController];
    else {
        self.busStop = context[@"busStop"];
        self.stopEntity = context[@"stopEntity"];
        
        if (!self.busStop) [self dismissController];
        
//        [self setTitle:self.stopEntity.busStopName];
        [self setupTableView];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(void)setupTableView {
    NSMutableArray *rowTypes = [@[] mutableCopy];
    [rowTypes addObject:@"StopRow"];
    
    if (self.busStop.departures.count > 0) {
        for (int i = 0; i < self.busStop.departures.count && i < 10; i++) {
            [rowTypes addObject:@"DepartureRow"];
        }
    } else {
        [rowTypes addObject:@"NoDepartureRow"];
    }
    
    [self.tableView setRowTypes:rowTypes];
    
    for (int i = 0; i < self.tableView.numberOfRows; i++) {
        if (i == 0) {
            StopRowController *controller = (StopRowController *)[self.tableView rowControllerAtIndex:i];
            [controller setUpWithStop:self.stopEntity];
        } else if(self.busStop.departures.count > 0) {
            DepartureRowController *controller = (DepartureRowController *)[self.tableView rowControllerAtIndex:i];
            [controller setupWithDeparture:self.busStop.departures[i - 1] stop:self.busStop isFirstDeparture: i == 1];
        }
    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    if (rowIndex != 0) return;
    
    NSString *locationName = self.stopEntity.busStopName;
    CLLocationCoordinate2D coords = [self.stopEntity.busStopCoords convertTo2DCoord];
    
    [self pushControllerWithName:@"MapView" context:@{LocationNameContextKey: locationName, LocationCoordsContextKey: [[CLLocation alloc] initWithLatitude:coords.latitude longitude:coords.longitude]}];
}

@end



