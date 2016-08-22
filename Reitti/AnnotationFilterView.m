//
//  AnnotationFilterView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 22/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "AnnotationFilterView.h"
#import "AppManager.h"

@implementation AnnotationFilterView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        
        view.layer.borderWidth = 1;
        view.layer.borderColor = [AppManager systemGreenColor].CGColor;
        view.layer.cornerRadius = 4;
        view.frame = self.bounds;
        showHideFiltersButton.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:view];
    }
    
    return self;
}

//-(instancetype)initializeViews {
//    id view =   [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
//    
//    return view;
//}

- (IBAction)showFiltersButtonTapped:(id)sender {
    CGRect frame = self.frame;
    frame.size.width += 30;
    
    self.frame = frame;
}


@end
