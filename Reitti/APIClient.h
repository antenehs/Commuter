//
//  Communication.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 31/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"

#import <RestKit/RestKit.h>

typedef void (^ActionBlock)();

@interface APIClient : NSObject

-(id)init;

-(void)doGraphQlQuery:(NSString *)query mappingDiscriptor:(MappingDescriptor *)mappingDiscriptor andCompletionBlock:(ActionBlock)completionBlock;

-(void)doJsonApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath andCompletionBlock:(ActionBlock)completionBlock;

-(void)doJsonApiFetchWithParams:(NSDictionary *)params mappingDescriptor:(MappingDescriptor *)mappingDescriptor andCompletionBlock:(ActionBlock)completionBlock;
-(void)doJsonApiFetchWithParams:(NSDictionary *)params responseDescriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock;

-(void)doXmlApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath andCompletionBlock:(ActionBlock)completionBlock;
-(void)doXmlApiFetchWithParams:(NSDictionary *)params responseDescriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock;

-(void)doApiFetchWithOutMappingWithParams:(NSDictionary *)params andCompletionBlock:(ActionBlock)completionBlock;

@property (nonatomic, strong) NSString *apiBaseUrl;

@end
