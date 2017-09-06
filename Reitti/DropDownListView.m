//
//  DropDownListView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/29/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "DropDownListView.h"
#import "UIColor+Custom.h"

@interface DropDownListView ()

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIImageView *chevronImage;

@property (strong, nonatomic) NSArray<NSString *> *options;

@property (strong, nonatomic) IBOutlet UIButton *button;

@end

@implementation DropDownListView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.chevronImage.tintColor = [UIColor systemGreenColor];
}

-(void)setupWithOptions:(NSArray<NSString *> *)options {
    [self setupWithOptions:options preSelectedIndex:0];
}

-(void)setupWithOptions:(NSArray<NSString *> *)options preSelectedIndex:(NSInteger)index {
    if (!options.count || options.count < 1) return;
    
    self.options = options;
    
    self.chevronImage.hidden = options.count < 2;
    self.button.enabled = options.count > 1;
    
    NSString *selectedOption = options[MIN(options.count - 1, index)];
    self.label.text = selectedOption;
}


-(IBAction)changeSelectionButtonTapped:(id)sender {
    NSAssert(_optionPresenterController, @"No presenter view");
    
    if (!self.options.count || self.options.count < 1) return;
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Choose direction"
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {}];
    
    [controller addAction:cancelAction];
    
    for (NSString *optionString in self.options) {
        UIAlertAction *optionAction = [UIAlertAction actionWithTitle:optionString
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                [self selectedOptionString:optionString];
                                                            }];
        
        [controller addAction:optionAction];
    }
    
    
    [_optionPresenterController presentViewController:controller animated:YES completion:nil];
}

-(void)selectedOptionString:(NSString *)optionString {
    self.label.text = optionString;
    if (self.delegate) {
        NSInteger selectedIndex = [self.options indexOfObject:optionString];
        [_delegate dropDownList:self selectedObjectAtIndex:selectedIndex];
    }
}


@end
