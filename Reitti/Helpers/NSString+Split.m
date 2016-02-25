//
//  NSString+Split.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/2/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "NSString+Split.h"

@implementation NSString (Split)

- (NSArray *)asa_stringsBySplittingOnString:(NSString *)splitString
{
    NSRange range = [self rangeOfString:splitString];
    if (range.location == NSNotFound) {
        return nil;
    } else {
        NSLog(@"%li",range.location);
        NSLog(@"%li",range.length);
        NSString *string1 = [self substringToIndex:range.location];
        NSString *string2 = [self substringFromIndex:range.location+range.length];
        NSLog(@"String1 = %@",string1);
        NSLog(@"String2 = %@",string2);
        return @[string1, string2];
    }
}

@end