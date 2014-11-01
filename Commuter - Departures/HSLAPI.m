//
//  HSLAPI.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 30/10/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "HSLAPI.h"
#import "BusStopE.h"

@implementation HSLAPI

- (void)searchStopForCodes:(NSArray *)codes completionBlock:(DeparturesSearchCompletionBlock)completionBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *resultArray = [@[]mutableCopy];
        
        for (int i = 0; i < codes.count ; i++) {
            [self searchStopForCode:[codes objectAtIndex:i] completionBlock:^(BusStopE *result, NSError *error) {
                if (!error && result != nil) {
                    [resultArray addObject:result];
                }else{
                    completionBlock(nil, error);
                }
                
                if (resultArray.count == codes.count ) {
                    completionBlock(resultArray, nil);
                }
            }];
        }
    });

}

- (void)searchStopForCode:(NSString *)code completionBlock:(StopSearchCompletionBlock)completionBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *searchURL = [NSString stringWithFormat:@"http://api.reittiopas.fi/hsl/prod/?request=stop&epsg_in=4326&epsg_out=4326&user=asareitti&pass=rebekah&dep_limit=20&time_limit=360&format=json&code=%@", code];
        NSError *error = nil;
        NSString *searchResultString = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&error];
        if (error != nil) {
            completionBlock(nil, error);
        } else {
            // Parse the JSON Response
            NSData *jsonData = [searchResultString dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *searchResultsArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                          options:kNilOptions
                                                                            error:&error];
            if (error != nil) {
                completionBlock(nil, error);
            } else {
                if (/* DISABLES CODE */ (NO)) {
                    completionBlock(nil, error);
                } else {
                    BusStopE *busStop = [BusStopE new];
                    
                    //                    NSLog(@"%@",[searchResultsArray description]);
                    
                    NSDictionary *busStopDict = [searchResultsArray objectAtIndex:0];
                    
                    busStop.code = busStopDict[@"code"];
                    busStop.code_short = busStopDict[@"code_short"];
                    busStop.name_fi = busStopDict[@"name_fi"];
                    busStop.city_fi = busStopDict[@"city_fi"];
                    busStop.lines = busStopDict[@"lines"];
                    busStop.departures = busStopDict[@"departures"];
                    busStop.address_fi = busStopDict[@"address_fi"];
                    
                    completionBlock(busStop, nil);
                }
            }
        }
        
    });
    
}

@end
