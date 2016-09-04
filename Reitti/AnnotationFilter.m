//
//  AnnotationFilter.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "AnnotationFilter.h"
#import "EnumManager.h"

@implementation AnnotationFilter

+(instancetype)initWithOptions:(NSArray *)filterOptions {
    AnnotationFilter *filter = [[AnnotationFilter alloc] init];
    if (filter) {
        filter.filterOptions = filterOptions;
        //TODO: Update enabled status from saved value.
    }
    
    return filter;
}

-(void)setEnabledStateForOptionType:(AnnotationType)type state:(BOOL)enabled {
    AnnotationFilterOption *option = [self optionForType:type];
    if (!option) return;
    
    option.isEnabled = enabled;
}

-(BOOL)isAnnotationTypeEnabled:(AnnotationType)type {
    AnnotationFilterOption *option = [self optionForType:type];
    if (!option) return YES;
    
    return option.isEnabled;
}

-(BOOL)isAnyNearByStopAnnotationEnabled {
    if (!self.filterOptions || self.filterOptions.count < 1) return YES;
    
    for (AnnotationFilterOption *option in self.filterOptions) {
        if ([EnumManager isNearbyStopAnnotationType:option.annotType] && option.isEnabled) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)allOptionsEnabled {
    if (!self.filterOptions || self.filterOptions.count < 1) return YES;
    
    for (AnnotationFilterOption *option in self.filterOptions) {
        if (!option.isEnabled) {
            return NO;
        }
    }
    
    return YES;
}

-(AnnotationFilterOption *)optionForType:(AnnotationType)type {
    if (!self.filterOptions || self.filterOptions.count < 1) return nil;
    
    NSArray *filtered = [self.filterOptions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"annotType == %d", (int)type]];
    if (filtered && filtered.count > 0) return filtered.firstObject;
    else return nil;
}

@end
