//
//  GraphQLQuery.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKObjectMapping.h"

@interface GraphQLQuery : NSObject

@property (nonatomic, strong) NSString* query;

+(RKObjectMapping*)requestMapping;

@end
