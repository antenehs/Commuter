//
//  AnnotationFilterView.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 22/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotationFilter.h"

typedef void (^SizeChangeBlock)(CGSize size);
typedef void (^FilterChangeBlock)(AnnotationFilter *newFilter, AnnotationFilterOption *changedOption);

@interface AnnotationFilterView : UIView {
    
    IBOutlet UIView *view;
    IBOutlet UIButton *showHideFiltersButton;
    IBOutlet UIView *optionsContainerView;
}

-(void)setUpWithFilter:(AnnotationFilter *)filter withFilterChangeBlock:(FilterChangeBlock)filterChangedHandler withSizeChangeHandler:(SizeChangeBlock)sizeChangeHandler;
-(void)setFilterOptionsHidden:(BOOL)hidden;

@property(nonatomic, readonly)BOOL isShowingOptions;

@end
