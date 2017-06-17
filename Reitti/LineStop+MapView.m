//
//  LineStop+MapView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "LineStop+MapView.h"
#import "ASA_Helpers.h"
#import "LocationsAnnotation.h"
#import "AppManager.h"

@implementation LineStop (MapView)

-(id<MKAnnotation>)mapAnnotation {
    CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:self.coords];
    
    NSString * name = self.name;
    NSString * shortCode = self.codeShort;
    
    if (name == nil || name == (id)[NSNull null]) {
        name = @"";
    }
    
    if (shortCode == nil || shortCode == (id)[NSNull null]) {
        shortCode = @"";
    }
    
    LocationsAnnotation *newAnnotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:shortCode andCoordinate:coordinate andLocationType:StopLocation];
    newAnnotation.code = self.gtfsId;
    newAnnotation.associatedObject = self;
    
    newAnnotation.annotIdentifier = @"LocationAnnotation";
    
    return newAnnotation;
}

@end
