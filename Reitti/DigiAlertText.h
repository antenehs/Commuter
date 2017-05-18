//
//  DisruptionText.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 16/1/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"

@interface DigiAlertText : NSObject<Mappable>

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *language;

@end
