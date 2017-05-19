//
//  DigiPatternShort.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/18/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "DigiPatternShort.h"

@implementation DigiPatternShort

#pragma mark - Conversion
-(LinePattern *)reittiLinePattern {
    LinePattern *linePattern = [LinePattern new];
    linePattern.name = self.name;
    linePattern.code = self.code;
    linePattern.headsign = self.headsign;
    linePattern.directionId = self.directionId;
    
    return linePattern;
}

#pragma mark - Mapping
+(NSDictionary *)mappingDictionary {
    return @{ @"name" : @"name",
              @"code" : @"code",
              @"headsign" : @"headsign",
              @"directionId" : @"directionId",};
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]];
}

@end
