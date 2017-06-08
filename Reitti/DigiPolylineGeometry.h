//
//  DigiPolylineGeometry.h
//
//  Created by Anteneh Sahledengel on 6/5/17
//  Copyright (c) 2017 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"

@interface DigiPolylineGeometry : NSObject <NSCoding, NSCopying, Mappable, DictionaryMappable>

@property (nonatomic, strong) NSString *points;
@property (nonatomic, assign) double length;

@property (nonatomic, strong, readonly) NSArray *coordinates;
@property (nonatomic, strong, readonly) NSArray *locations;
@property (nonatomic, strong, readonly) NSArray *coordinateStrings;

@end
