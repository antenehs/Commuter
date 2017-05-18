//
//  Disruption.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 24/10/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DigiAlertText.h"
#import "DigiRouteShort.h"
#import "Mapping.h"

@interface DigiAlert : NSObject <Mappable>

@property (nonatomic, retain) NSNumber * alertId;
@property (nonatomic, retain) NSNumber * agency;
@property (nonatomic, retain) NSString * alertDescription;
@property (nonatomic, retain) NSNumber * effectiveStartDate;
@property (nonatomic, retain) NSNumber * effectiveEndDate;
@property (nonatomic, retain) NSArray * alertTexts;
@property (nonatomic, retain) DigiRouteShort * alertRoute;

//Computed
@property (nonatomic, strong) NSDate *parsedEndDate;

////objectMapping
//+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
//+(RKObjectMapping *)objectMapping;
//+(NSDictionary *)mappingDictionary;

@end
