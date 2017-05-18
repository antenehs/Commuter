//
//  DisruptionText.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 16/1/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DisruptionText.h"

@implementation DisruptionText

@synthesize text, language;

+(instancetype)disruptionTextFromDigiAlertText:(DigiAlertText *)digiAlertText {
    DisruptionText *text = [DisruptionText new];
    
    text.text = digiAlertText.text;
    text.language = digiAlertText.language;
    
    return text;
}
@end
