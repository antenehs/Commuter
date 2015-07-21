//
//  TicketNames.h
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface TicketNames : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *fi;
@property (nonatomic, strong) NSString *sv;
@property (nonatomic, strong) NSString *en;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
