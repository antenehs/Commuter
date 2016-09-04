//
//  AnnotationFilterOption.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumManager.h"

@interface AnnotationFilterOption : NSObject

+(instancetype)optionForBusStop;
+(instancetype)optionForTramStop;
+(instancetype)optionForTrainStop;
+(instancetype)optionForMetroStop;
+(instancetype)optionForFerryStop;
+(instancetype)optionForBikeStation;

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)UIImage *image;
@property (nonatomic)AnnotationType annotType;
@property (nonatomic)BOOL isEnabled;

@end
