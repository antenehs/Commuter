//
//  HSLCommunication.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 31/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "APIClient.h"
#import "RKXMLReaderSerialization.h"
#import "ReittiStringFormatter.h"
#import "GraphQLQuery.h"

@implementation APIClient

@synthesize apiBaseUrl;

-(id)init{
    self = [super init];
    
    if (self) {
        RKLogConfigureByName("RestKit", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/Network", RKLogLevelCritical);
         
        /* Debug
        RKLogConfigureByName("RestKit", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
        */
    }
    
    return self;
}

#pragma mark - Rest api helpers
+(NSString *)formatRestQueryFilterForDictionary:(NSDictionary *)paramsDictionary{
    if (paramsDictionary == nil)
        return @"";
    
    NSMutableArray *paramsArray = [@[] mutableCopy];
    for (NSString *key in paramsDictionary.allKeys) {
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",key, paramsDictionary[key]]];
    }
    
    return [ReittiStringFormatter commaSepStringFromArray:paramsArray withSeparator:@"&"];
}

#pragma mark - Generic fetch method

-(void)doGraphQlQuery:(NSString *)query mappingDiscriptor:(MappingDescriptor *)mappingDiscriptor andCompletionBlock:(ActionBlock)completionBlock {
    RKResponseDescriptor *responseDesc = [APIClient rkResponseDiscriptorForMappingDescriptor:mappingDiscriptor];
    
    [self doGraphQlQuery:query responseDiscriptor:responseDesc andCompletionBlock:completionBlock];
}

-(void)doGraphQlQuery:(NSString *)query responseDiscriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock {
    
    GraphQLQuery *dataObject = [[GraphQLQuery alloc] init];
    dataObject.query = query;
    
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *requestMapping =  [[GraphQLQuery requestMapping] inverseMapping];
    
    [objectManager addRequestDescriptor: [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[GraphQLQuery class] rootKeyPath:nil method:RKRequestMethodPOST]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager setRequestSerializationMIMEType: RKMIMETypeJSON];
    
    [objectManager postObject:dataObject
                        path:@""
                        parameters:nil
                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//                            NSLog(@"It Worked: %@", [mappingResult array]);
                            completionBlock(mappingResult.array, nil);
                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//                            NSLog(@"It Failed: %@", error);
                            completionBlock(nil, error);
                        }];
}

-(void)doApiFetchWithParams:(NSDictionary *)params responseDiscriptor:(RKResponseDescriptor *)responseDescriptor isJsonResponse:(BOOL)isJson andCompletionBlock:(ActionBlock)completionBlock{
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:isJson ? RKMIMETypeJSON : RKMIMETypeXML];
    [RKMIMETypeSerialization registerClass:isJson ? [RKNSJSONSerialization class] : [RKXMLReaderSerialization class] forMIMEType:isJson ? @"text/plain" : @"text/xml"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    //Construct params query string
    NSString *parameters = [APIClient formatRestQueryFilterForDictionary:params];
    if ([parameters respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        parameters = [parameters stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?%@",apiBaseUrl,parameters];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        completionBlock(mappingResult.array, nil);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

-(void)doJsonApiFetchWithParams:(NSDictionary *)params mappingDescriptor:(MappingDescriptor *)mappingDescriptor andCompletionBlock:(ActionBlock)completionBlock {
    RKResponseDescriptor *responseDesc = [APIClient rkResponseDiscriptorForMappingDescriptor:mappingDescriptor];
    
    [self doApiFetchWithParams:params responseDiscriptor:responseDesc isJsonResponse:YES andCompletionBlock:completionBlock];
}

-(void)doJsonApiFetchWithParams:(NSDictionary *)params responseDescriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock{
    
    [self doApiFetchWithParams:params responseDiscriptor:responseDescriptor isJsonResponse:YES andCompletionBlock:completionBlock];
}

-(void)doXmlApiFetchWithParams:(NSDictionary *)params responseDescriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock{
    
    [self doApiFetchWithParams:params responseDiscriptor:responseDescriptor isJsonResponse:NO andCompletionBlock:completionBlock];
}

-(void)doApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath isJsonResponse:(BOOL)isJson andCompletionBlock:(ActionBlock)completionBlock{
    RKObjectMapping *responseMApping = [RKObjectMapping mappingForClass:mapToClass];
    [responseMApping addAttributeMappingsFromDictionary:mapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMApping method:RKRequestMethodGET pathPattern:nil keyPath:keyPath statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [self doApiFetchWithParams:params responseDiscriptor:responseDescriptor isJsonResponse:isJson andCompletionBlock:completionBlock];
}

-(void)doJsonApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath andCompletionBlock:(ActionBlock)completionBlock{
    
    [self doApiFetchWithParams:params mappingDictionary:mapping mapToClass:mapToClass mapKeyPath:keyPath isJsonResponse:YES andCompletionBlock:completionBlock];
}

-(void)doXmlApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath andCompletionBlock:(ActionBlock)completionBlock{
    [self doApiFetchWithParams:params mappingDictionary:mapping mapToClass:mapToClass mapKeyPath:keyPath isJsonResponse:NO andCompletionBlock:completionBlock];
}

-(void)doApiFetchWithOutMappingWithParams:(NSDictionary *)params andCompletionBlock:(ActionBlock)completionBlock{
    
    //Construct params query string
    NSString *parameters = [APIClient formatRestQueryFilterForDictionary:params];
    if ([parameters respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        parameters = [parameters stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?%@",apiBaseUrl,parameters];
    
    NSURL *url = [NSURL URLWithString:apiURL];
    //    NSLog(@"%@", urlAsString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(data, error);
        });
    }];
}


#pragma mark - Mapping helpers
#ifndef APPLE_WATCH
+(RKResponseDescriptor *)rkResponseDiscriptorForMappingDescriptor:(MappingDescriptor *)mappingDescriptor {
    
    return [RKResponseDescriptor responseDescriptorWithMapping:[APIClient rKobjectMappingFromMappingDescriptor:mappingDescriptor]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:mappingDescriptor.path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)rKobjectMappingFromMappingDescriptor:(MappingDescriptor *)mappingDescriptor {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:mappingDescriptor.classType];
    [mapping addAttributeMappingsFromDictionary:mappingDescriptor.mappingDictionary];
    
    for (MappingRelationShip *relation in mappingDescriptor.relationShips) {
        MappingDescriptor *mappindDesc = [relation.mappableClass mappingDescriptorForPath:nil];
        
        [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:relation.fromKeyPath
                                                                                toKeyPath:relation.toKeypath
                                                                              withMapping:[APIClient rKobjectMappingFromMappingDescriptor:mappindDesc]]];
    }
    
    return mapping;
}
#endif

@end
