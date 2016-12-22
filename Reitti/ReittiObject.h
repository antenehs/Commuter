//
//  ReittiObject.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiProtocols.h"

#ifndef APPLE_WATCH
#import <RestKit/RestKit.h>

@protocol Mappable <NSObject>
+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;
@end
#else
@protocol Mappable <NSObject>
@optional
+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;
@end
#endif

@interface ReittiObject : NSObject

@property (nonatomic)ReittiApi fetchedFromApi;

@end
