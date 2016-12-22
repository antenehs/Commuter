//
//  NSString+Split.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/2/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

- (NSArray *)asa_stringsBySplittingOnString:(NSString *)splitString
{
    NSRange range = [self rangeOfString:splitString];
    if (range.location == NSNotFound) {
        return nil;
    } else {
//        NSLog(@"%li",range.location);
//        NSLog(@"%li",range.length);
        NSString *string1 = [self substringToIndex:range.location];
        NSString *string2 = [self substringFromIndex:range.location+range.length];
//        NSLog(@"String1 = %@",string1);
//        NSLog(@"String2 = %@",string2);
        return @[string1, string2];
    }
}

//Expected format longitude,latitude
- (CLLocationCoordinate2D)convertTo2DCoord {
    NSArray *coords = [self componentsSeparatedByString:@","];
    if (!coords || coords.count < 2)
        return kCLLocationCoordinate2DInvalid;
    
    CLLocationCoordinate2D coord = {.latitude =  [[coords objectAtIndex:1] floatValue], .longitude =  [[coords objectAtIndex:0] floatValue]};
    
    return coord;
}

+(NSString *)stringRepresentationOf2DCoord:(CLLocationCoordinate2D)coord{
    return [NSString stringWithFormat:@"%f,%f", coord.longitude, coord.latitude];
}

-(NSNumber *)asa_numberValue {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString:self];
    
    return myNumber;
}

@end
