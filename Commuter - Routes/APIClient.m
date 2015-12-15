//
//  APIClient.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "APIClient.h"
#import "WidgetHelpers.h"

@implementation APIClient

#pragma mark - Rest api helpers
-(NSString *)formatRestQueryFilterForDictionary:(NSDictionary *)paramsDictionary{
    if (paramsDictionary == nil)
        return @"";
    
    NSMutableArray *paramsArray = [@[] mutableCopy];
    for (NSString *key in paramsDictionary.allKeys) {
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",key, paramsDictionary[key]]];
    }
    
    return [WidgetHelpers commaSepStringFromArray:paramsArray withSeparator:@"&"];
}


#pragma mark - Api fetch
-(void)doApiFetchWithParams:(NSDictionary *)params andCompletionBlock:(ActionBlock)completionBlock{
    //Do the API call
    //Construct params query string
    NSString *parameters = [self formatRestQueryFilterForDictionary:params];
    if ([parameters respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        parameters = [parameters stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }else{
        parameters = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?%@",self.apiBaseUrl,parameters];
    
    NSURL *url = [NSURL URLWithString:apiURL];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil, error);
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(data, error);
            });
        }
    }];
}

@end
