//
//  AddressTableViewCell.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReittiModels.h"

@interface AddressTableViewCell : UITableViewCell

-(void)setupFromGeocode:(GeoCode *)geoCode;

-(void)addTargetForAddressSelection:(id)target selector:(SEL)selector;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *addressImageView;
@property (strong, nonatomic) IBOutlet UIView *separatorView;
@property (strong, nonatomic) IBOutlet UIButton *addressSelectionButton;

//Data sources
@property (strong, nonatomic)GeoCode *geoCode;

@end
