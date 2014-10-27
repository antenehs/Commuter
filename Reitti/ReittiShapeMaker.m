//
//  ReittiShapeMaker.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiShapeMaker.h"

@implementation ReittiShapeMaker

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]

@synthesize borderColor, fillColor, edgeRadius, borderWidth;

-(id)init{
    self.borderColor = SYSTEM_GRAY_COLOR;
    self.fillColor = SYSTEM_GRAY_COLOR;
    self.edgeRadius = 2.0;
    self.borderWidth = 0.5;
    
    return self;
}

-(UIView *)createACircleWithRadius:(int)radius borderColor:(UIColor *)borderColor{
    
    return nil;
}
-(UIView *)createACircleWithRadiusFilled:(int)radius borderColor:(UIColor *)borderColor fillColor:(UIColor *)fillColor{
    
    return nil;
}
-(UIView *)createALineCurvedEdgeWithOrentation:(Orentation)orentation length:(float)length borderColor:(UIColor *)brdrColor cornerRadius:(float)cornerRad fillColor:(UIColor *)fColor{
    
    CGRect frame;
    if (orentation == OrentationHorizontal)
        frame = CGRectMake(0, 0, length, self.edgeRadius * 2);
    else
        frame = CGRectMake(0, 0, self.edgeRadius * 2, length);
    
    UIView *line = [[UIView alloc] initWithFrame:frame];
    
    if (brdrColor == nil) {
        line.layer.borderColor = [self.borderColor CGColor];
    }else{
        line.layer.borderColor = [brdrColor CGColor];
    }
    
    if (fColor == nil){
        line.backgroundColor = self.fillColor;
    }else{
        line.backgroundColor = fColor;
    }
    
    if (cornerRad < 0) {
        line.layer.cornerRadius = self.edgeRadius;
    }else{
        line.layer.cornerRadius = cornerRad;
    }
    
    line.layer.borderWidth = self.borderWidth;
    
    
    return line;
}
-(UIView *)createALineCurvedEdgeDottedFilledWithOrentation:(Orentation)orentation length:(float)length borderColor:(UIColor *)bColor cornerRadius:(float)cornerRad fillColor:(UIColor *)fColor{
    
    CGRect frame;
    if (orentation == OrentationHorizontal)
        frame = CGRectMake(0, 0, length, self.edgeRadius * 2);
    else
        frame = CGRectMake(0, 0, self.edgeRadius * 2, length);
    
    UIView *dotLine = [[UIView alloc] initWithFrame:frame];
    
    float corRad;
    if (cornerRad < 0) {
        corRad = self.edgeRadius;
    }else{
        corRad = cornerRad;
    }
    
    UIColor *bCol;
    if (bColor == nil){
        bCol = self.borderColor;
    }else{
        bCol = bColor;
    }
    
    UIColor *fCol;
    if (fColor == nil){
        fCol = self.fillColor;
    }else{
        fCol = fColor;
    }
    
    float diameter = corRad * 2;
    
    int rep = (length/diameter)/2;
    float space = (length - (rep * diameter))/(rep - 1);
    
    int pos = 0;
    
    for (int i = 0; i < rep; i++) {
        UIView *circle = [self createALineCurvedEdgeWithOrentation:OrentationHorizontal length:diameter borderColor:fCol cornerRadius:corRad fillColor:fCol];
        CGRect cFrame = circle.frame;
        circle.frame = CGRectMake(pos, 0, cFrame.size.width, cFrame.size.height);
        pos += space + diameter;
        
        [dotLine addSubview:circle];
    }
    
    return dotLine;
}



@end
