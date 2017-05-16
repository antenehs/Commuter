//
//  DynamicHeightTableView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "DynamicHeightTableView.h"

@implementation DynamicHeightTableView

//TODO: Find way for animating change

-(CGSize)intrinsicContentSize {
    [self layoutIfNeeded];
    return CGSizeMake(UIViewNoIntrinsicMetric, self.contentSize.height);
}

-(void)reloadData {
    [super reloadData];
    [self invalidateIntrinsicContentSize];
}

@end
