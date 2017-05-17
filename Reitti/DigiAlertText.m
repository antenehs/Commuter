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

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiAlertText objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[DigiAlertText class] ];
    [mapping addAttributeMappingsFromDictionary:[DigiAlertText mappingDictionary]];
    
    return mapping;
}

+(NSDictionary *)mappingDictionary {
    return @{ @"text" : @"text",
              @"language" : @"language"
              };
}

@end
