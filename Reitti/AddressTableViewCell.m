//
//  AddressTableViewCell.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "AddressTableViewCell.h"
#import "ReittiStringFormatter.h"
#import "AppManager.h"

@interface AddressTableViewCell ()

@property (weak, nonatomic)id addressSelectButtonTarget;
@property (nonatomic)SEL addressSelectButtonSelector;

@end

@implementation AddressTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setupFromGeocode:(GeoCode *)geoCode{
    self.geoCode = geoCode;
    
    self.separatorView.hidden = YES;
    self.addressSelectionButton.hidden = YES;
    
    if (geoCode.getLocationType == LocationTypePOI) {
        [self.addressImageView setImage:[UIImage imageNamed:@"location-75.png"]];
        
        self.nameLabel.text = geoCode.name;
        self.addressLabel.text = [NSString stringWithFormat:@"%@", [geoCode fullAddressString]];
    }else if (geoCode.getLocationType  == LocationTypeAddress) {
        self.separatorView.hidden = NO;
        self.addressSelectionButton.hidden = NO;
        
        [self.addressImageView setImage:[UIImage imageNamed:@"search-75.png"]];
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", geoCode.name, geoCode.getHouseNumber];
        self.addressLabel.text = [NSString stringWithFormat:@"%@", geoCode.city];
    }else{
        [self.addressImageView setImage:[UIImage imageNamed:@"dropped-pin-100.png"]];
        
        self.nameLabel.text = @"Dropped pin";
        self.nameLabel.textColor = [AppManager systemGreenColor];
        self.addressLabel.text = [NSString stringWithFormat:@"%@ %@", geoCode.name, geoCode.getHouseNumber];
    }
}

-(void)addTargetForAddressSelection:(id)target selector:(SEL)selector{
    self.addressSelectButtonTarget = target;
    self.addressSelectButtonSelector = selector;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addressSelectionButtonTapped:(id)sender {
    if (self.addressSelectButtonSelector) {
        [self.addressSelectButtonTarget performSelector:self.addressSelectButtonSelector withObject:self afterDelay:0 ];
    }
}


@end
