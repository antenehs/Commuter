//
//  NearbyInfoTableViewCell.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/24/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NearbyListInfoTypeLoading,
    NearbyListInfoTypeNothingNearby,
    NearbyListInfoTypeEverythingFiltered,
    NearbyListInfoTypeZoomedOut,
    NearbyListInfoTypeUnsupportedRegion,
    NearbyListInfoTypeError,
} NearbyListInfoType;

@interface NearbyInfoTableViewCell : UITableViewCell

-(void)setupForInfoType:(NearbyListInfoType)infoType specialErrorMessage:(NSString *)message;

@end
