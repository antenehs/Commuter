//
//  GraphQLQuery.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "GraphQLQuery.h"

@implementation GraphQLQuery
@synthesize query;

+(RKObjectMapping*)requestMapping   {
    
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[GraphQLQuery class]];
    
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"query":   @"query",
                                                  }];
    return mapping;
    
}

@end
