//
//  Line+MapView.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapViewProtocols.h"
#import "Line.h"

@interface Line (MapView)<MapViewPolylineProtocol>

-(NSArray *)lineStopAnnotations;

@end
