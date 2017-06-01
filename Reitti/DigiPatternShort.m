//
//  DigiPatternShort.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/18/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "DigiPatternShort.h"

@implementation DigiPatternShort

+(instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:dict];
    }
    
    return nil;
}

-(instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    self.name = [dict objectOrNilForKey:@"name"];
    self.code = [dict objectOrNilForKey:@"code"];
    self.headsign = [dict objectOrNilForKey:@"headsign"];
    self.directionId = [dict objectOrNilForKey:@"directionId"];
    
    return self;
}

-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [@{} mutableCopy];
    
    [dict setValue:self.name forKey:@"name"];
    [dict setValue:self.code forKey:@"code"];
    [dict setValue:self.headsign forKey:@"headsign"];
    [dict setValue:self.directionId forKey:@"directionId"];
    
    return dict;
}

#pragma mark - Conversion
-(LinePattern *)reittiLinePattern {
    LinePattern *linePattern = [LinePattern new];
    linePattern.name = self.name;
    linePattern.code = self.code;
    linePattern.headsign = self.headsign;
    linePattern.directionId = self.directionId;
    
    return linePattern;
}

#pragma mark - Mapping
+(NSDictionary *)mappingDictionary {
    return @{ @"name" : @"name",
              @"code" : @"code",
              @"headsign" : @"headsign",
              @"directionId" : @"directionId",};
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]];
}

@end
