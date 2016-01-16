//
//  DisruptionLine.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 16/1/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisruptionLine : NSObject

@property (nonatomic, retain) NSString * lineId;
@property (nonatomic, retain) NSNumber * lineDirection;
@property (nonatomic, retain) NSNumber * lineType;
@property (nonatomic, retain) NSString * lineName;

@end
