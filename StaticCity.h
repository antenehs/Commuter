//
//  StaticCity.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StaticCity : NSObject

-(NSArray *)getArrayOfBoundaryArrays;

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSArray *bounderies;

@end
