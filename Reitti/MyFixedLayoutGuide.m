//
//  MyFixedLayoutGuide.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "MyFixedLayoutGuide.h"

@implementation MyFixedLayoutGuide

- (id)initWithLength:(CGFloat)length {
    self = [super init];
    if (self) {
        _pbLength = length;
    }
    return self;
}

- (CGFloat)length {
    return _pbLength;
}

@end
