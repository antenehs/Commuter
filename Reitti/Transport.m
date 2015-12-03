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

-(id)initWithRouteLeg:(RouteLeg *)routeLeg andWidth:(float)width{
    self = [super init];
    if (self) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"Transport" owner:self options:nil];
        UIView* mainView = (UIView*)[nibViews objectAtIndex:0];
        [self addSubview:mainView];
        self.frame = mainView.frame;
        //self.backgroundColor = SYSTEM_GRAY_COLOR;
        [self setUpViewForRoute:routeLeg andWidth:width];
    }
    
    return self;
}

-(void)setUpViewForRoute:(RouteLeg *)routeLeg andWidth:(float)width{
    if (width < 30 && routeLeg.legType != LegTypeWalk) {
        width = 30;
    }
    UILabel *lineNumberLabel = (UILabel *)[self viewWithTag:9003];
    UIImageView *imageView = (UIImageView *)[self viewWithTag:9002];
    
    float minWidthForWalkLeg = 20;
    float acceptableWidthForMetroAndFerry = 70;
    float acceptableWidthForOthers = 70;
    
    if (routeLeg.lineCode != nil) {
        lineNumberLabel.text = [ReittiStringFormatter parseBusNumFromLineCode:routeLeg.lineCode];
        NSDictionary *fontAttr = [NSDictionary dictionaryWithObject:lineNumberLabel.font forKey:NSFontAttributeName];
        
        CGSize size = [lineNumberLabel.text sizeWithAttributes:fontAttr];
        
        if (size.width < lineNumberLabel.bounds.size.width) {
            acceptableWidthForOthers = size.width + 27;
        }
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.width);
    
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
    }else if(routeLeg.legType == LegTypeWalk){
        lineNumberLabel.hidden = YES;
        if (width < minWidthForWalkLeg) {
            imageView.hidden = YES;
        }
    }else if (routeLeg.legType == LegTypeTrain) {
        NSString *formattedTrainNumber = [ReittiStringFormatter parseBusNumFromLineCode:routeLeg.lineCode];
        
        lineNumberLabel.text = formattedTrainNumber;
        if (width < acceptableWidthForOthers) {
            imageView.hidden = YES;
        }
    }else{
        if (routeLeg.lineCode != nil) {
            lineNumberLabel.text = [ReittiStringFormatter parseBusNumFromLineCode:routeLeg.lineCode];
            
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
    
//    switch (routeLeg.legType) {
//        case LegTypeBus:
//            [imageView setImage:[UIImage imageNamed:@"bus-filled-light-100.png"]];
//            break;
//        case LegTypeTrain:
//            [imageView setImage:[UIImage imageNamed:@"train-filled-light-64.png"]];
//            break;
//        case LegTypeMetro:
//            [imageView setImage:[UIImage imageNamed:@"metro-logo-orange.png"]];
//            break;
//        case LegTypeTram:
//            [imageView setImage:[UIImage imageNamed:@"tram-filled-light-64.png"]];
//            break;
//        case LegTypeFerry:
//            [imageView setImage:[UIImage imageNamed:@"boat-filled-light-100.png"]];
//            break;
//        case LegTypeService:
//            [imageView setImage:[UIImage imageNamed:@"service-bus-filled-purple.png"]];
//            break;
//        case LegTypeWalk:
//            [imageView setImage:[UIImage imageNamed:@"walking-gray-64.png"]];
//            break;
//            
//        default:
//            [imageView setImage:[UIImage imageNamed:@"bus-filled-light-100.png"]];
//            break;
//    }
    
    [imageView setImage:[AppManager lightColorImageForLegTransportType:routeLeg.legType]];
    
    if (imageView.hidden && !lineNumberLabel.hidden) {
        lineNumberLabel.frame = CGRectMake(0, lineNumberLabel.frame.origin.y, self.frame.size.width, lineNumberLabel.frame.size.height);
    }
    
    NSDictionary *fontAttr = [NSDictionary dictionaryWithObject:lineNumberLabel.font forKey:NSFontAttributeName];
    
    CGSize size = [lineNumberLabel.text sizeWithAttributes:fontAttr];
    
    if ((width > 15) && (size.width < lineNumberLabel.bounds.size.width) ) {
         lineNumberLabel.frame = CGRectMake(lineNumberLabel.frame.origin.x, lineNumberLabel.frame.origin.y, size.width, lineNumberLabel.frame.size.height);
    }else{
//        lineNumberLabel.hidden = YES;
        
//        switch (routeLeg.legType) {
//            case LegTypeWalk:
//                self.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
//                break;
//            case LegTypeFerry:
//                self.backgroundColor = SYSTEM_CYAN_COLOR;
//                break;
//            case LegTypeTrain:
//                self.backgroundColor = SYSTEM_RED_COLOR;
//                break;
//            case LegTypeBus:
//                self.backgroundColor = SYSTEM_BLUE_COLOR;
//                break;
//            case LegTypeTram:
//                self.backgroundColor = SYSTEM_GREEN_COLOR;
//                break;
//            case LegTypeMetro:
//                self.backgroundColor = SYSTEM_ORANGE_COLOR;
//                break;
//                
//            default:
//                self.backgroundColor = SYSTEM_BLUE_COLOR;
//                break;
//        }
    }
    
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

    
//    //Append waiting view if exists
//    if (routeLeg.waitingTimeInSeconds > 0) {
//        float scale = width /[routeLeg.legDurationInSeconds integerValue];
//        float waitingWidth = scale * routeLeg.waitingTimeInSeconds;
//        
//        UIView *waitingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, waitingWidth, self.frame.size.height)];
//        waitingView.backgroundColor = [UIColor lightTextColor];
//        
//        //Shift all subview
//        self.frame = CGRectMake(0, 0, self.frame.size.width + waitingWidth, self.frame.size.height);
//        for (UIView *view in self.subviews) {
//            self.frame = CGRectMake(view.frame.origin.x + waitingWidth , view.frame.origin.y , view.frame.size.width, self.frame.size.height);
//        }
//        
//        [self addSubview:waitingView];
//    }
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
