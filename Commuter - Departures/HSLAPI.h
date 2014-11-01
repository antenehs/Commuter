//
//  HSLAPI.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 30/10/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BusStopE;

typedef void (^DeparturesSearchCompletionBlock)(NSMutableArray *results, NSError *error);

@interface HSLAPI : NSObject

- (void)searchStopForCodes:(NSArray *)codes completionBlock:(DeparturesSearchCompletionBlock)completionBlock;


@end
