//
//  Disruption.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 24/10/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "Disruption.h"
#import "ASA_Helpers.h"

NSString *kFinnishCauseText = @"Syy:";
NSString *kFinnishEstimatedTimeText = @"Arvioitu kesto:";
NSString *kSwidishCauseText = @"Orsak:";
NSString *kSwidishEstimatedTimeText = @"Beräknad tid:";
NSString *kEnglishCauseText = @"Cause:";
NSString *kEnglishEstimatedTimeText = @"Estimated time:";

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

-(NSAttributedString *)formattedLocalizedTextWithFont:(UIFont *)font {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    return [self formattedLocalizedTextForLanguage:language withFont:font];
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

-(NSString *)textForLanguage:(NSString *)language {
    if (!self.disruptionTexts || self.disruptionTexts.count < 1)
        return nil;
    
    for (DisruptionText *text in self.disruptionTexts) {
        if ([text.language isEqualToString:language] && text.text && text.text.length > 0) {
            return text.text;
        }
    }
    
    return nil;
}

-(NSAttributedString *)formattedLocalizedTextForLanguage:(NSString *)language withFont:(UIFont *)font {
    NSString *causeString, *timeString, *text;
    if ([language hasPrefix:@"fi"]) {
        causeString = kFinnishCauseText;
        timeString = kFinnishEstimatedTimeText;
        text = [self finnishText];
    }else if ([language hasPrefix:@"sv"]) {
        causeString = kSwidishCauseText;
        timeString = kSwidishEstimatedTimeText;
        text = [self swidishText];
    }else{
        causeString = kEnglishCauseText;
        timeString = kEnglishEstimatedTimeText;
        text = [self englishText];
    }
    
    NSString *formattedText = [text stringByReplacingOccurrencesOfString:causeString withString:[NSString stringWithFormat:@"\n\n%@", causeString]];
    BOOL containsCause = [text containsString:causeString];
    formattedText = [formattedText stringByReplacingOccurrencesOfString:timeString withString:[NSString stringWithFormat:@"%@%@", containsCause ? @"\n" :  @"\n\n", timeString]];
    
    UIFont *highlightedFont = [UIFont systemFontOfSize:font.pointSize weight:UIFontWeightMedium];
    
    return [ReittiStringFormatter highlightSubstringInString:formattedText substrings:@[causeString, timeString] withNormalFont:font highlightedFont:highlightedFont andHighlightColor:[UIColor darkTextColor]];
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

-(BOOL)affectsLineWithFullCode:(NSString *)lineFullCode{
    if (!self.disruptionLines || self.disruptionLines.count < 1)
        return NO;
    
    for (DisruptionLine *line in self.disruptionLines) {
        if (!line.lineFullCode)
            continue;
        
        if ([lineFullCode isEqualToString:line.lineFullCode])
            return YES;
    }
    
    return NO;
}

-(NSArray *)disruptionLineNames {
    if (!_disruptionLineNames) {
        if (!self.disruptionLines || self.disruptionLines.count == 0) return @[];
        
        NSMutableArray *lineCodes = [@[] mutableCopy];
        for (DisruptionLine *line in self.disruptionLines) {
            [lineCodes addObject:line.lineName ? line.lineName : @""];
        }
        
        _disruptionLineNames = lineCodes;
    }
    
    return _disruptionLineNames;
}

@end
