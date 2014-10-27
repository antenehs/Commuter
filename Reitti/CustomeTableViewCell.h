//
//  CustomeTableViewCell.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/4/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWTableViewCell.h"

@interface CustomeTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellStopCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDestinationLabel;
@end
