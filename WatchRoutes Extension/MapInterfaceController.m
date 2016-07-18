//
//  MapInterfaceController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MapInterfaceController.h"

NSString *LocationNameContextKey = @"LocationNameContextKey";
NSString *LocationCoordsContextKey = @"LocationCoordsContextKey";

@interface MapInterfaceController ()
@property (strong, nonatomic) IBOutlet WKInterfaceMap *mapView;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *locationNameLabel;

@end

@implementation MapInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    //Expected: {name: bookmarkName, location: ClLocation}
    if ([context isKindOfClass:[NSDictionary class]]) {
        NSDictionary *contextDictionary = (NSDictionary *)context;
        NSString *name = contextDictionary[LocationNameContextKey];
        CLLocation *location = contextDictionary[LocationCoordsContextKey];
        
        if (name) {
            [self.locationNameLabel setText:name];
            [self.locationNameLabel setHidden:NO];
        } else {
            [self.locationNameLabel setHidden:YES];
        }
        
        if (location) {
            MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.005, 0.005);
            [self.mapView addAnnotation:location.coordinate withPinColor: WKInterfaceMapPinColorRed];
            
            [self.mapView setRegion:(MKCoordinateRegionMake(location.coordinate, coordinateSpan))];
        } else {
            return;
        }
    }
    
    
    // Configure interface objects here.
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



