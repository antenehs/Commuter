//
//  DisruptionText.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 16/1/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "DigiAlertText.h"

@interface DisruptionText : NSObject

+(instancetype)disruptionTextFromDigiAlertText:(DigiAlertText *)digiAlertText;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *language;

//objectMapping
+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;
+(NSDictionary *)mappingDictionary;

@end
