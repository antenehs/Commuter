//
//  RoutableLocation.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiProtocols.h"

@interface RoutableLocation : NSObject <RoutableLocationProtocol>

+(nonnull instancetype)initFromDictionary:(nonnull NSDictionary *)dictionary;
-(nonnull NSDictionary *)dictionaryRepresentation;

@property (nonatomic, retain, nonnull) NSString *name;
@property (nonatomic, retain, nonnull) NSString * coords;

@end
