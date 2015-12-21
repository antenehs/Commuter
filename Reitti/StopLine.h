//
//  StopLine.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StopLine : NSObject <NSCoding>

@property (nonatomic, strong) NSString *fullCode;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *direction;
@property (nonatomic, strong) NSString *destination;

@end
