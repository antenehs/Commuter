//
//  DigiAlert.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 24/10/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "DigiAlert.h"

@implementation DigiAlert

-(NSDate *)parsedEndDate {
    if (!_parsedEndDate) {
        double endDate = [self.effectiveEndDate doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:endDate];
        if (date) _parsedEndDate = date;
    }
    
    return _parsedEndDate;
}

#pragma mark - object mapping

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiAlert objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[DigiAlert class] ];
    [mapping addAttributeMappingsFromDictionary:[DigiAlert mappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"route"
                                                                                toKeyPath:@"alertRoute"
                                                                              withMapping:[DigiRouteShort objectMapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"alertDescriptionTextTranslations"
                                                                                toKeyPath:@"alertTexts"
                                                                          withMapping:[DigiAlertText objectMapping]]];
    
    return mapping;
}

+(NSDictionary *)mappingDictionary {
    return @{ @"id"                     : @"alertId",
              @"alertDescriptionText"   : @"alertDescription",
              @"agency"                 : @"agency",
              @"effectiveStartDate"     : @"effectiveStartDate",
              @"effectiveEndDate"       : @"effectiveEndDate"
              };
}

@end
