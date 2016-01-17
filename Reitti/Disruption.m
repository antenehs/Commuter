//
//  Disruption.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 24/10/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "Disruption.h"

@implementation Disruption

@synthesize disruptionId;
@synthesize disruptionType;
@synthesize disruptionSource;
@synthesize disruptionTexts;
@synthesize disruptionStartTime;
@synthesize disruptionEndTime;
@synthesize disruptionLines;

-(NSString *)localizedText{
//    NSLog(@"%@", [NSLocale preferredLanguages]);
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    if ([language hasPrefix:@"fi"]) {
        return [self finnishText];
    }else if ([language hasPrefix:@"sv"]) {
        return [self swidishText];
    }else{
        return [self englishText];
    }
}

-(NSString *)finnishText{
    return [self textForLanguage:@"fi"];
}

-(NSString *)swidishText{
    return [self textForLanguage:@"se"] ? [self textForLanguage:@"se"] : [self textForLanguage:@"fi"];
}

-(NSString *)englishText{
    return [self textForLanguage:@"en"] ? [self textForLanguage:@"en"] : [self textForLanguage:@"fi"];
}

-(NSString *)textForLanguage:(NSString *)language{
    if (!self.disruptionTexts || self.disruptionTexts.count < 1)
        return nil;
    
    for (DisruptionText *text in self.disruptionTexts) {
        if ([text.language isEqualToString:language] && text.text && text.text.length > 0) {
            return text.text;
        }
    }
    
    return nil;
}

-(BOOL)affectsLineWithShortName:(NSString *)lineShortName{
    if (!self.disruptionLines || self.disruptionLines.count < 1)
        return NO;
    
    for (DisruptionLine *line in self.disruptionLines) {
        if (!line.lineName)
            continue;
        
        if ([lineShortName isEqualToString:line.lineName])
            return YES;
    }
    
    return NO;
}

@end
