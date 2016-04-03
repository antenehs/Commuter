//
//  RouteSearchParameters.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 1/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteSearchParameters : NSObject

-(id)initWithToLocation:(NSString *)toLocation toCoords:(NSString *)toCoords fromLocation:(NSString *)fromLocation fromCoords:(NSString *)fromCoords;

@property (nonatomic, strong)NSString *toLocation;
@property (nonatomic, strong)NSString *toCoords;
@property (nonatomic, strong)NSString *fromLocation;
@property (nonatomic, strong)NSString *fromCoords;

@end
