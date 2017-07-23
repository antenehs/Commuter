//
//  UIColor+Custom.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "UIColor+Custom.h"

@implementation UIColor (Custom)

//#1CAC7F
+(UIColor *)systemGreenColor{
    return [UIColor colorWithRed:28.0/255.0 green:172.0/255.0 blue:127.0/255.0 alpha:1.0];
    //    return [UIColor colorWithRed:0.318 green:0.718 blue:0.259 alpha:1.00];
    //    return [UIColor colorWithRed:0.306 green:0.698 blue:0.467 alpha:1.00];
    //    return [UIColor colorWithRed:0.275 green:0.635 blue:0.400 alpha:1.00];
}

//#F46B00
//#fa4220
+(UIColor *)systemOrangeColor{
    //    return [UIColor colorWithRed:244.0f/255 green:107.0f/255 blue:0 alpha:1];
    return [UIColor colorWithRed:0.980 green:0.259 blue:0.125 alpha:1.00];
}

//#F44336
+(UIColor *)systemRedColor{
    //    return [UIColor colorWithRed:244.0f/255 green:67.0f/255 blue:54.0f/255 alpha:1];
    //    return [UIColor colorWithRed:0.580 green:0.110 blue:0.075 alpha:1.00];
    //    return [UIColor colorWithRed:0.682 green:0.165 blue:0.129 alpha:1.00];
    return [UIColor colorWithRed:0.741 green:0.180 blue:0.145 alpha:1.00];
}

//#2196F3
+(UIColor *)systemBlueColor{
    //    return [UIColor colorWithRed:33.0/255 green:150.0/255.0 blue:243.0f/255 alpha:1.0];
    //    return [UIColor colorWithRed:0.129 green:0.353 blue:0.667 alpha:1.00];
    return [UIColor colorWithRed:0.157 green:0.435 blue:0.812 alpha:1.00];
}

//#00BCD4
+(UIColor *)systemCyanColor{
    return [UIColor colorWithRed:0.0f/255 green:188.0f/255 blue:212.0f/255 alpha:1];
}

+(UIColor *)systemPurpleColor{
    return [UIColor colorWithRed:0.557 green:0.267 blue:0.678 alpha:1.0];
}

//#fcbc19
+(UIColor *)systemYellowColor{
    return [UIColor colorWithRed:0.988 green:0.737 blue:0.098 alpha:1.00];
}

//#292b35
+(UIColor *)systemBlueBlackColor {
    return [UIColor colorWithRed:0.161 green:0.169 blue:0.208 alpha:1.00];
}

@end
