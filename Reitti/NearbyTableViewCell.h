//
//  NearbyTableViewCell.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupedDepartures.h"
#import "BikeStation.h"

@interface NearbyTableViewCell : UITableViewCell

- (void)setupFromNearByRowObject:(id)nearByRow;

@property (nonatomic, strong) GroupedDepartures *groupedDepartures;
@property (nonatomic, strong) BikeStation *bikeStation;

@end
