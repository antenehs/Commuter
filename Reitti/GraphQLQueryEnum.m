//
//  GraphQLQueryEnum.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "GraphQLQueryEnum.h"

@interface GraphQLQueryEnum ()

@property(strong, nonnull)NSString *stringVal;

@end

@implementation GraphQLQueryEnum

+(instancetype)forStringRepresentation:(NSString *)string {
    GraphQLQueryEnum *gqlEnum = [GraphQLQueryEnum new];
    gqlEnum.stringVal = string;
    
    return gqlEnum;
}

@end
