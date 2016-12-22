//
//  DigiStopAtDistance.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/17/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DigiStopAtDistance.h"

@implementation DigiStopAtDistance



+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiStopAtDistance objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* stopAtDistanceMapping = [RKObjectMapping mappingForClass:[DigiStopAtDistance class] ];
    [stopAtDistanceMapping addAttributeMappingsFromDictionary:@{
                                                      @"node.distance" : @"distance"
                                                      }];
    
    [stopAtDistanceMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"node.stop"
                                                                                toKeyPath:@"stop"
                                                                              withMapping:[DigiStop objectMapping]]];
    
    return stopAtDistanceMapping;
}

@end
