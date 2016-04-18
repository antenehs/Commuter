//
//  MatkaLine.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

/*
 <LINE id = ‘%Integer’ code = ‘%String’ codeOriginal = ‘%String’
 companyCode = ‘%String’
 transportType = ‘%Integer’
 tridentClass = ‘%Integer’
 arrivalTime = ‘%Real’
 departureTime = ‘%Real’> <name></name> </LINE>
*/

#import <Foundation/Foundation.h>

@interface MatkaLine : NSObject

@property(nonatomic, strong)NSNumber *lineId;
@property(nonatomic, strong)NSString *codeShort;
@property(nonatomic, strong)NSString *codeFull;
@property(nonatomic, strong)NSString *companyCode;
@property(nonatomic, strong)NSNumber *transportType;
@property(nonatomic, strong)NSNumber *tridentClass;
@property(nonatomic, strong)NSString *arrivalTime;
@property(nonatomic, strong)NSString *departureTime;
@property(nonatomic, strong)NSArray *lineNames;

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSDate *parsedDepartureTime;

@end
