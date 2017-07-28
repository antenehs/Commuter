//
//  GoProCarouselTableViewCell.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatingCarousel.h"

typedef void(^ButtonAction)();

@interface GoProCarouselTableViewCell : UITableViewCell

@property (nonatomic, strong)ButtonAction buttonAction;

@end
