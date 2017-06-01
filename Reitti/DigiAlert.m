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

+(NSDictionary *)mappingDictionary {
    return @{ @"id"                     : @"alertId",
              @"alertDescriptionText"   : @"alertDescription",
              @"agency"                 : @"agency",
              @"effectiveStartDate"     : @"effectiveStartDate",
              @"effectiveEndDate"       : @"effectiveEndDate"
              };
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    NSArray *relations = @[[MappingRelationShip relationShipFromKeyPath:@"route"
                                                              toKeyPath:@"alertRoute"
                                                       withMappingClass:[DigiRouteShort class]],
                           [MappingRelationShip relationShipFromKeyPath:@"alertDescriptionTextTranslations"
                                                              toKeyPath:@"alertTexts"
                                                       withMappingClass:[DigiAlertText class]]];
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]
                                andRelationShips:relations];
}

@end
