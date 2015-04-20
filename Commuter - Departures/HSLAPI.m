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
        NSMutableArray *resultArray = [@[] mutableCopy];
        
        for (int i = 0; i < codes.count ; i++) {
            [self searchStopForCode:[codes objectAtIndex:i] index:i completionBlock:^(BusStopE *result, int index, NSError *error) {
                if (!error && result != nil) {
//                    if (index < resultArray.count) {
//                        [resultArray removeObjectAtIndex:index];
//                        [resultArray insertObject:result atIndex:index];
//                    }else
                    [resultArray addObject:result];
                }else{
                    completionBlock(nil, error);
                }
                
                if (resultArray.count == codes.count ) {
                    NSMutableArray *sortedResultArray = [@[] mutableCopy];
                    for (BusStopE *stop in resultArray) {
                        if ([codes indexOfObject:[NSString stringWithFormat:@"%d",[stop.code intValue]]] == 0) {
                            [sortedResultArray addObject:stop];
                            break;
                        }
                    }
                    
                    for (BusStopE *stop in resultArray) {
                        if ([codes indexOfObject:[NSString stringWithFormat:@"%d",[stop.code intValue]]] == 1) {
                            [sortedResultArray addObject:stop];
                            break;
                        }
                    }
                    
                    for (BusStopE *stop in resultArray) {
                        if ([codes indexOfObject:[NSString stringWithFormat:@"%d",[stop.code intValue]]] == 2) {
                            [sortedResultArray addObject:stop];
                            break;
                        }
                    }
                    completionBlock(sortedResultArray, nil);
                    
                }
            }];
        }
    });

}

- (void)searchStopForCode:(NSString *)code index:(int)index completionBlock:(StopSearchCompletionBlock)completionBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *searchURL;
        //TODO: Find a better way for determining this
        //TRE codes have code length 4 and HSL 7
        if (code.length < 5) {
            searchURL = [NSString stringWithFormat:@"http://api.publictransport.tampere.fi/1_0_3/?request=stop&epsg_in=4326&epsg_out=4326&user=asacommuterwidget&pass=rebekah&dep_limit=20&time_limit=360&format=json&code=%@", code];
        }else{
            searchURL = [NSString stringWithFormat:@"http://api.reittiopas.fi/hsl/1_2_0/?request=stop&epsg_in=4326&epsg_out=4326&user=asacommuter&pass=rebekah&dep_limit=20&time_limit=360&format=json&code=%@", code];
        }
        
        NSError *error = nil;
        NSString *searchResultString = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&error];
        if (error != nil) {
            completionBlock(nil,index, error);
        } else {
            // Parse the JSON Response
            NSData *jsonData = [searchResultString dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *searchResultsArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                          options:kNilOptions
                                                                            error:&error];
            if (error != nil) {
                completionBlock(nil,index, error);
            } else {
                if (/* DISABLES CODE */ (NO)) {
                    completionBlock(nil,index, error);
                } else {
                    BusStopE *busStop = [BusStopE new];
                    
                    //                    NSLog(@"%@",[searchResultsArray description]);
                    
                    NSDictionary *busStopDict = [searchResultsArray objectAtIndex:0];
                    
                    busStop.code = [busStopDict[@"code"] isEqual:[NSNull null]] ? nil : busStopDict[@"code"];
                    busStop.code_short = [busStopDict[@"code_short"] isEqual:[NSNull null]] ? nil : busStopDict[@"code_short"];
                    busStop.name_fi = [busStopDict[@"name_fi"] isEqual:[NSNull null]] ? nil : busStopDict[@"name_fi"];
                    busStop.city_fi = [busStopDict[@"city_fi"] isEqual:[NSNull null]] ? nil : busStopDict[@"city_fi"];
                    busStop.lines = [busStopDict[@"lines"] isEqual:[NSNull null]] ? nil : busStopDict[@"lines"];
                    busStop.departures = [busStopDict[@"departures"] isEqual:[NSNull null]] ? nil : busStopDict[@"departures"];
                    busStop.address_fi = [busStopDict[@"address_fi"] isEqual:[NSNull null]] ? nil : busStopDict[@"address_fi"];
                    
                    completionBlock(busStop,index, nil);
                }
            }
        }
        
    });
    
}

@end
