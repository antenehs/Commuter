//
//  DisruptionText.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 16/1/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DigiAlertText.h"

@implementation DigiAlertText

@synthesize text, language;

+(NSDictionary *)mappingDictionary {
    return @{ @"text"       : @"text",
              @"language"   : @"language"
              };
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]];
}

@end
