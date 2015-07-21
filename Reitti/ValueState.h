//
//  ValueState.h
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ValueState : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double state;
@property (nonatomic, assign) id stateExplanationUIField;
@property (nonatomic, assign) id stateImageFilenameUIField;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
