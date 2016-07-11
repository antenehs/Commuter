//
//  ComplicationController.m
//  WatchRoutes Extension
//
//  Created by Anteneh Sahledengel on 26/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ComplicationController.h"
#import "ComplicationDataManager.h"
#import "ExtensionDelegate.h"
#import "AppManagerBase.h"

@interface NSDate (ComplicationHelper)

-(BOOL)isValidDate;

@end

@implementation NSDate (ComplicationHelper)

-(BOOL)isValidDate {
    return [self timeIntervalSinceDate:[NSDate date]] > 0;
}

@end

@interface ComplicationController ()

@end

@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionForward|CLKComplicationTimeTravelDirectionBackward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler(nil);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    ExtensionDelegate* myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
    NSDate* date = [myDelegate complicationDate];
    
    handler(date);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    // Get the current complication data from the extension delegate.
    ExtensionDelegate* myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
    NSDate* date = [myDelegate complicationDate];

    CLKTextProvider *textProvide;
    if ([date isValidDate]) {
        textProvide = [CLKRelativeDateTextProvider textProviderWithDate:date style:CLKRelativeDateStyleNatural units:NSCalendarUnitMinute];
    } else {
        textProvide = [self placeholderTextProviderForFamily:complication.family];
//        handler(nil);
//        return;
    }
    
    CLKComplicationTimelineEntry* entry = nil;
    NSDate* now = [NSDate date];
    
    // Create the template and timeline entry.
    if (complication.family == CLKComplicationFamilyUtilitarianSmall) {
        CLKComplicationTemplateUtilitarianSmallFlat* textTemplate = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
        
        textTemplate.textProvider = textProvide;
        CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Utilitarian"]];
        imageProvider.tintColor = [AppManagerBase systemGreenColor];
        textTemplate.imageProvider = imageProvider;
        entry = [CLKComplicationTimelineEntry entryWithDate:now complicationTemplate:textTemplate];
    }
    else {
        
    }
    
    handler(entry);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after to the given date
//    ExtensionDelegate* myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
//    NSDate* endDate = [myDelegate complicationDate];
    
    handler(nil);
}

#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)(NSDate * __nullable updateDate))handler {
    // Call the handler with the date when you would next like to be given the opportunity to update your complication content
    
    ExtensionDelegate* myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
    NSDate* date = [myDelegate complicationDate];
    
    handler(date);
}

-(void)requestedUpdateDidBegin {
    [self refreshComplications];
}

#pragma mark - Placeholder Templates
- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    // This method will be called once per supported complication, and the results will be cached
    
    handler([self placeholderTemplateForFamily:complication.family]);
}

#pragma mark - Helpers
-(CLKComplicationTemplate *)placeholderTemplateForFamily:(CLKComplicationFamily)family {
    if (family == CLKComplicationFamilyUtilitarianSmall) {
        CLKComplicationTemplateUtilitarianSmallFlat* textTemplate = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
        
        textTemplate.textProvider = [self placeholderTextProviderForFamily:family];
        CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Complication/Utilitarian"]];
        //        imageProvider.tintColor = [UIColor blueColor];
        textTemplate.imageProvider = imageProvider;
        return textTemplate;
    }
    else {
        // ...configure entries for other complication families.
    }
    
    return nil;
}

-(CLKSimpleTextProvider *)placeholderTextProviderForFamily:(CLKComplicationFamily)family {
    if (family == CLKComplicationFamilyUtilitarianSmall) {
        return [CLKSimpleTextProvider textProviderWithText:@"--"];
    }
    
    return nil;
}

- (void)refreshComplications {
    CLKComplicationServer *server = [CLKComplicationServer sharedInstance];
    for(CLKComplication *complication in server.activeComplications) {
        [server reloadTimelineForComplication:complication];
    }
}

@end
