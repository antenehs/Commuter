//
//  MatkaStopName.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MatkaName : NSObject

+(instancetype)initFromDictionary:(NSDictionary *)dict;
-(NSDictionary *)dictionaryRepresentation;

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *language;

@end
