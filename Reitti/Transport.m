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

@implementation Transport

//#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]

-(id)initWithRouteLeg:(RouteLeg *)routeLeg{
    self = [super init];
    if (self) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"Transport" owner:self options:nil];
        UIView* mainView = (UIView*)[nibViews objectAtIndex:0];
        [self addSubview:mainView];
        self.frame = mainView.frame;
        //self.backgroundColor = SYSTEM_GRAY_COLOR;
        [self setUpViewForRoute:routeLeg];
    }
    
    return self;
}

-(void)setUpViewForRoute:(RouteLeg *)routeLeg{
    UILabel *departureTimeLabel = (UILabel *)[self viewWithTag:9001];
    RouteLegLocation *firstLocation = [routeLeg.legLocations firstObject];
    NSDate *startTime = firstLocation.depTime;
    departureTimeLabel.text = [ReittiStringFormatter formatHourStringFromDate:startTime];
    
    UILabel *lineNumberLabel = (UILabel *)[self viewWithTag:9003];
    
    if(routeLeg.legType == LegTypeMetro){
        lineNumberLabel.text = @"Metro";
    }else if(routeLeg.legType == LegTypeFerry){
        lineNumberLabel.text = @"Ferry";
    }else if (routeLeg.legType == LegTypeTrain) {
        NSString *unformattedTrainNumber = [ReittiStringFormatter parseBusNumFromLineCode:routeLeg.lineCode];
        NSString *filteredOnce = [unformattedTrainNumber
                                  stringByReplacingOccurrencesOfString:@"01" withString:@""];
        lineNumberLabel.text = [filteredOnce
                                stringByReplacingOccurrencesOfString:@"02" withString:@""];
    }else if (routeLeg.lineCode != nil) {
        lineNumberLabel.text = [ReittiStringFormatter parseBusNumFromLineCode:routeLeg.lineCode];
    }else {
        lineNumberLabel.text = @"";
    }
    
    UIImageView *imageView = (UIImageView *)[self viewWithTag:9002];
    
    switch (routeLeg.legType) {
        case LegTypeBus:
            [imageView setImage:[UIImage imageNamed:@"bus-colored-75.png"]];
            break;
        case LegTypeTrain:
            [imageView setImage:[UIImage imageNamed:@"train-colored-75.png"]];
            break;
        case LegTypeMetro:
            [imageView setImage:[UIImage imageNamed:@"metro-colored-75.png"]];
            break;
        case LegTypeTram:
            [imageView setImage:[UIImage imageNamed:@"tram-colored-75.png"]];
            break;
        case LegTypeFerry:
            [imageView setImage:[UIImage imageNamed:@"ferry-colored-75.png"]];
            break;
        case LegTypeService:
            [imageView setImage:[UIImage imageNamed:@"bus-colored-75.png"]];
            break;
            
        default:
            [imageView setImage:[UIImage imageNamed:@"bus-colored-75.png"]];
            break;
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
