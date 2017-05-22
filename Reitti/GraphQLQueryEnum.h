//
//  GraphQLQueryEnum.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphQLQueryEnum : NSObject

+(instancetype _Nonnull )forStringRepresentation:(NSString *_Nonnull)string;

@property(strong, nonnull, readonly)NSString *stringVal;

@end
