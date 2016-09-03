//
//  MatkaStopName.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaName.h"

@implementation MatkaName

+(instancetype)initFromDictionary:(NSDictionary *)dict {
    MatkaName *nameObject = [[MatkaName alloc] init];
    
    nameObject.name = dict[@"name"];
    nameObject.language = dict[@"language"];
    
    return nameObject;
}

-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [@{} mutableCopy];
    
    [dict setValue:self.name forKey:@"name"];
    [dict setValue:self.language forKey:@"language"];
    
    return dict;
}

@end
