//
//  ReittiShapeMaker.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    Rectangel,
    RectangelFilled,
    Circle,
    CircleFilled,
    LineCorneredEdge,
    LineCorneredEdgeFilled,
    LineCurvedEdge,
    LineCurvedEdgeFilled,
    LineCurvedEdgeDotted,
    LineCurvedEdgeDottedFilled
} ShapeType;

typedef enum
{
    OrentationVertical,
    OrentationHorizontal,
} Orentation;

@interface ReittiShapeMaker : NSObject

-(id)init;
-(UIView *)createACircleWithRadius:(int)radius borderColor:(UIColor *)borderColor;
-(UIView *)createACircleWithRadiusFilled:(int)radius borderColor:(UIColor *)borderColor fillColor:(UIColor *)fillColor;
-(UIView *)createALineCurvedEdgeWithOrentation:(Orentation)orentation length:(float)length borderColor:(UIColor *)borderColor cornerRadius:(float)cornerRad fillColor:(UIColor *)fillColor;
-(UIView *)createALineCurvedEdgeDottedFilledWithOrentation:(Orentation)orentation length:(float)length borderColor:(UIColor *)borderColor cornerRadius:(float)cornerRad fillColor:(UIColor *)fillColor;

@property (nonatomic, strong) UIColor * borderColor;
@property (nonatomic) float borderWidth;
@property (nonatomic, strong) UIColor * fillColor;
@property (nonatomic) float edgeRadius;



@end
