//
//  AnnotationFilter.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnnotationFilterOption.h"

@interface AnnotationFilter : NSObject

+(instancetype)initWithOptions:(NSArray *)filterOptions;

-(void)setEnabledStateForOptionType:(AnnotationType)type state:(BOOL)enabled;
-(BOOL)isAnnotationTypeEnabled:(AnnotationType)type;
-(BOOL)isAnyNearByStopAnnotationEnabled;
-(BOOL)allOptionsEnabled;

@property(nonatomic, strong)NSArray *filterOptions;

@end
