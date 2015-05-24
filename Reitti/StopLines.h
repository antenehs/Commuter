//
//  StopLines.h
//
//  Created by Anteneh Sahledengel on 23/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface StopLines : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *linesIdentifier;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
