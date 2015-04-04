//
//  Transport.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteLeg.h"

@interface Transport : UIView

-(id)initWithRouteLeg:(RouteLeg *)routeLeg andWidth:(float)width;

@end
