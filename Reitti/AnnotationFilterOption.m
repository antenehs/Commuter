//
//  AnnotationFilterOption.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "AnnotationFilterOption.h"
#import "AppManager.h"

@implementation AnnotationFilterOption

+(instancetype)optionForBusStop {
    AnnotationFilterOption *option = [[AnnotationFilterOption alloc] init];
    option.name = @"Bus Stop";
    option.image = [AppManager stopIconForStopType:StopTypeBus];
    option.annotType = NearByBusStopType;
    option.isEnabled = YES;
    
    return option;
}

+(instancetype)optionForTramStop {
    AnnotationFilterOption *option = [[AnnotationFilterOption alloc] init];
    option.name = @"Tram Stop";
    option.image = [AppManager stopIconForStopType:StopTypeTram];
    option.annotType = NearByTramStopType;
    option.isEnabled = YES;
    
    return option;
}

+(instancetype)optionForTrainStop {
    AnnotationFilterOption *option = [[AnnotationFilterOption alloc] init];
    option.name = @"Train Stop";
    option.image = [AppManager stopIconForStopType:StopTypeTrain];
    option.annotType = NearByTrainStopType;
    option.isEnabled = YES;
    
    return option;
}

+(instancetype)optionForMetroStop {
    
    AnnotationFilterOption *option = [[AnnotationFilterOption alloc] init];
    option.name = @"Metro Stop";
    option.image = [AppManager stopIconForStopType:StopTypeMetro];
    option.annotType = NearByMetroStopType;
    option.isEnabled = YES;
    
    return option;
}

+(instancetype)optionForFerryStop {
    AnnotationFilterOption *option = [[AnnotationFilterOption alloc] init];
    option.name = @"Ferry Stop";
    option.image = [AppManager stopIconForStopType:StopTypeFerry];
    option.annotType = NearByFerryStopType;
    option.isEnabled = YES;
    
    return option;
}

+(instancetype)optionForBikeStation {
    AnnotationFilterOption *option = [[AnnotationFilterOption alloc] init];
    option.name = @"Bike Station";
    option.image = [AppManager stopIconForStopType:StopTypeBikeStation];
    option.annotType = BikeStationLocation;
    option.isEnabled = YES;
    
    return option;
}

@end
