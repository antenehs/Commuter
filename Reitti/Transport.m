//
//  Transport.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//
//1 = Helsinki internal bus lines
//2 = trams
//3 = Espoo internal bus lines
//4 = Vantaa internal bus lines
//5 = regional bus lines
//6 = metro
//7 = ferry
//8 = U-lines
//12 = commuter trains
//21 = Helsinki service lines
//22 = Helsinki night buses
//23 = Espoo service lines
//24 = Vantaa service lines
//25 = region night buses
//36 = Kirkkonummi internal bus lines
//39 = Kerava internal bus lines


#import "Transport.h"
#import "RouteLegLocation.h"
#import "ReittiStringFormatter.h"
#import "AppManager.h"

@implementation Transport

#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];
#define SYSTEM_ORANGE_COLOR [UIColor colorWithRed:230.0/255.0 green:126.0/255.0 blue:34.0/255.0 alpha:1.0];
#define SYSTEM_BLUE_COLOR [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
#define SYSTEM_RED_COLOR [UIColor redColor];
#define SYSTEM_BROWN_COLOR [UIColor brownColor];
#define SYSTEM_CYAN_COLOR [UIColor cyanColor];

//#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]

-(id)initWithRouteLeg:(RouteLeg *)routeLeg andWidth:(float)width alwaysShowVehicle:(BOOL)alwaysShow{
    self = [super init];
    if (self) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"Transport" owner:self options:nil];
        UIView* mainView = (UIView*)[nibViews objectAtIndex:0];
        [self addSubview:mainView];
        self.frame = mainView.frame;
        //self.backgroundColor = SYSTEM_GRAY_COLOR;
        [self setUpViewForRoute:routeLeg andWidth:width alwaysShowVehicle:alwaysShow];
    }
    
    return self;
}

-(void)setUpViewForRoute:(RouteLeg *)routeLeg andWidth:(float)width alwaysShowVehicle:(BOOL)alwaysShow{
    if (isnan(width))
        width = 0;
    
    //If width is < 30, start by setting it to 30
    if (width < 30 && routeLeg.legType != LegTypeWalk) {
        width = 30;
    }
    UILabel *lineNumberLabel = (UILabel *)[self viewWithTag:9003];
    UIImageView *imageView = (UIImageView *)[self viewWithTag:9002];
    
    float minWidthForWalkLeg = 20;
    float acceptableWidthForMetroAndFerry = 70;
    float acceptableWidthForBicycle = 100;
    float acceptableWidthForOthers = 70;
    
    if (routeLeg.lineName != nil) {
        lineNumberLabel.text = routeLeg.lineName;
        NSDictionary *fontAttr = [NSDictionary dictionaryWithObject:lineNumberLabel.font forKey:NSFontAttributeName];
        CGSize size = [lineNumberLabel.text sizeWithAttributes:fontAttr];
        
        if (size.width < lineNumberLabel.bounds.size.width) {
            //Acceptable width is the size of the text plus imageview width
            acceptableWidthForOthers = size.width + 27;
        }
        
        if (alwaysShow && routeLeg.legType != LegTypeWalk && routeLeg.legType != LegTypeFerry && routeLeg.legType != LegTypeMetro) {
            if (width < size.width + 35) {
                width = size.width + 35;
            }
        }
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
    
    if(routeLeg.legType == LegTypeMetro){
        lineNumberLabel.text = @"Metro";
        if (width < acceptableWidthForMetroAndFerry) {
            lineNumberLabel.hidden = YES;
        }
    }else if(routeLeg.legType == LegTypeFerry){
        lineNumberLabel.text = @"Ferry";
        if (width < acceptableWidthForMetroAndFerry) {
            lineNumberLabel.hidden = YES;
        }
    }else if(routeLeg.legType == LegTypeAirplane){
        lineNumberLabel.text = @"AIR";
        if (width < acceptableWidthForMetroAndFerry) {
            lineNumberLabel.hidden = YES;
        }
    }else if(routeLeg.legType == LegTypeBicycle){
        lineNumberLabel.text = @"BIKE";
        if (width < acceptableWidthForBicycle) {
            lineNumberLabel.hidden = YES;
        }
    }else  if(routeLeg.legType == LegTypeWalk){
        lineNumberLabel.hidden = YES;
        if (width < minWidthForWalkLeg) {
            imageView.hidden = YES;
        }
    }else{
        if (routeLeg.lineName != nil) {
            lineNumberLabel.text = routeLeg.lineName;
            
            if ((width < acceptableWidthForOthers) ) {
                imageView.hidden = YES;
            }
        }else {
            lineNumberLabel.text = @"";
            if (width < acceptableWidthForOthers) {
                imageView.hidden = YES;
            }
        }
    }
    
    [imageView setImage:[AppManager lightColorImageForLegTransportType:routeLeg.legType]];
    
    if (imageView.hidden && !lineNumberLabel.hidden) {
        lineNumberLabel.frame = CGRectMake(0, lineNumberLabel.frame.origin.y, self.frame.size.width, lineNumberLabel.frame.size.height);
    }
    
    NSDictionary *fontAttr = [NSDictionary dictionaryWithObject:lineNumberLabel.font forKey:NSFontAttributeName];
    
    CGSize size = [lineNumberLabel.text sizeWithAttributes:fontAttr];
    
    if ((width > 15) && (size.width < lineNumberLabel.bounds.size.width) ) {
         lineNumberLabel.frame = CGRectMake(lineNumberLabel.frame.origin.x, lineNumberLabel.frame.origin.y, size.width, lineNumberLabel.frame.size.height);
    }else{
    }
    
    //Set background color
    if (routeLeg.legType == LegTypeWalk) {
        self.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
    }else{
        self.backgroundColor = [UIColor colorWithWhite:0.28 alpha:1];
    }
    
    //Center views
    if (imageView.hidden && !lineNumberLabel.hidden) {
        lineNumberLabel.frame = CGRectMake(0, lineNumberLabel.frame.origin.y, self.frame.size.width, lineNumberLabel.frame.size.height);
        lineNumberLabel.textAlignment = NSTextAlignmentCenter;
    }else if (!imageView.hidden && lineNumberLabel.hidden) {
        imageView.frame = CGRectMake((width - imageView.frame.size.width)/2, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
    }else if (!imageView.hidden && !lineNumberLabel.hidden){
        float totalWidth = imageView.frame.size.width + lineNumberLabel.frame.size.width + 7;
        float orign = (width - totalWidth)/2;
        
        imageView.frame = CGRectMake(orign, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
        lineNumberLabel.frame = CGRectMake(orign + imageView.frame.size.width + 7, lineNumberLabel.frame.origin.y, lineNumberLabel.frame.size.width, lineNumberLabel.frame.size.height);
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
