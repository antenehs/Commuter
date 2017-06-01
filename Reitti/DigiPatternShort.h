//
//  DigiPatternShort.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/18/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"
#import "LinePattern.h"

@interface DigiPatternShort : NSObject <Mappable, DictionaryMappable>

-(LinePattern *)reittiLinePattern;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *headsign;
@property (nonatomic, strong) NSNumber *directionId;

+(NSDictionary *)mappingDictionary;

@end
