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
#import "SettingsManager.h"

@interface AddressTableViewCell ()

@property (weak, nonatomic)id addressSelectButtonTarget;
@property (nonatomic)SEL addressSelectButtonSelector;

@end

@implementation AddressTableViewCell

-(void)setupFromGeocode:(GeoCode *)geoCode{
    self.geoCode = geoCode;
    
    self.separatorView.hidden = YES;
    self.addressSelectionButton.hidden = YES;
    
    [self.addressImageView setImage:[UIImage imageNamed:geoCode.iconPictureName]];
    
    if (geoCode.locationType == LocationTypePOI || geoCode.locationType == LocationTypeContact) {
        self.nameLabel.textColor = [UIColor blackColor];
        
        self.nameLabel.text = geoCode.name;
        self.addressLabel.text = [NSString stringWithFormat:@"%@", [geoCode fullAddressString]];
    }else if (geoCode.locationType  == LocationTypeAddress) {
        self.separatorView.hidden = NO;
        self.addressSelectionButton.hidden = NO;
        self.nameLabel.textColor = [UIColor blackColor];
        
        //Digi API already has the number on the name
        if ([SettingsManager useDigiTransit]) {
            self.nameLabel.text = geoCode.name;
        } else {
            self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", geoCode.name, geoCode.getHouseNumber];
        }
        self.addressLabel.text = [NSString stringWithFormat:@"%@", geoCode.city];
    }else{
        self.nameLabel.text = @"Dropped pin";
        self.nameLabel.textColor = [AppManager systemGreenColor];
        self.addressLabel.text = [NSString stringWithFormat:@"%@", [geoCode fullAddressString]];
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
