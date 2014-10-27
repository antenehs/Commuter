//
//  MyFixedLayoutGuide.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyFixedLayoutGuide : NSObject <UILayoutSupport>

@property (nonatomic) CGFloat pbLength;
- (id)initWithLength:(CGFloat)length;
@end
