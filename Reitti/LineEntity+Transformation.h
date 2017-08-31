//
//  LineEntity+Transformation.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/28/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LineEntity.h"

#import "Line.h"

@interface LineEntity (Transformation)

-(Line *)reittiLineFromEntity;
-(void)initFromReittiLine:(Line *)reittiLine;

@end
