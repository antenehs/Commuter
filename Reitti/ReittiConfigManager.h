//
//  ReittiConfigManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReittiConfigManager : NSObject

+(instancetype)sharedManager;

-(NSString *)appTranslationLink;
-(NSInteger)intervalBetweenGoProShowsInStopView;

@end
