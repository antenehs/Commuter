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

@property (nonatomic, strong, readonly)NSDate *complicationDepartureDate;
@property (nonatomic, strong, readonly)NSString *complicationTransportName;
@property (nonatomic, strong, readonly)UIImage *complicationImage;

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
    
    handler(self.complicationDepartureDate);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    // Get the current complication data from the extension delegate.
    
    CLKComplicationTimelineEntry* entry = [self timeLineEntryForDate:[NSDate date] andComplicationFamily:complication.family];
    handler(entry);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after to the given date
   
    CLKComplicationTimelineEntry* nowEntry = [self timeLineEntryForDate:date andComplicationFamily:complication.family];
    CLKComplicationTimelineEntry* endEntry = [self timeLineEntryForDate:self.complicationDepartureDate andComplicationFamily:complication.family];
    
    if (nowEntry && endEntry) {
        handler(@[nowEntry, endEntry]);
    } else {
        handler(nil);
    }
}

#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)(NSDate * __nullable updateDate))handler {
    // Call the handler with the date when you would next like to be given the opportunity to update your complication content
    
    NSDate *departureDate = self.complicationDepartureDate;
    if (departureDate) {
        NSDate *nextTime = [departureDate dateByAddingTimeInterval:45];
        handler(nextTime);
    }
    
    handler(nil);
}

-(void)requestedUpdateDidBegin {
    [self refreshComplications];
}

#pragma mark - Placeholder Templates
- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    // This method will be called once per supported complication, and the results will be cached
    
    handler([self templateForDate:[NSDate date] andFamily:complication.family]);
}

#pragma mark - Helpers
-(CLKComplicationTimelineEntry *)timeLineEntryForDate:(NSDate *)date andComplicationFamily:(CLKComplicationFamily)family {
    CLKComplicationTemplate* template = [self templateForDate:(NSDate *)date andFamily:family];
    return [CLKComplicationTimelineEntry entryWithDate:date complicationTemplate:template];
}

-(CLKComplicationTemplate *)templateForDate:(NSDate *)date andFamily:(CLKComplicationFamily)family {
    if (family == CLKComplicationFamilyUtilitarianSmall || family == CLKComplicationFamilyUtilitarianLarge) {
        return [self utilitarianTemplateForDate:date andFamily:family];
    } else if (family == CLKComplicationFamilyModularSmall || family == CLKComplicationFamilyModularLarge)  {
        return [self modularTemplateForDate:date andFamily:family];
    }
    
    return nil;
}

-(CLKComplicationTemplate *)utilitarianTemplateForDate:(NSDate *)date andFamily:(CLKComplicationFamily)family {
    NSDate* departureDate = self.complicationDepartureDate;
    BOOL isValidDate = departureDate && [date timeIntervalSinceDate:departureDate] < 0;
    
    CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:self.complicationImage];
    imageProvider.tintColor = [AppManagerBase systemGreenColor];
    
    CLKTextProvider *textProvider;
    if (family == CLKComplicationFamilyUtilitarianSmall) {
        if (isValidDate) {
            textProvider = [CLKRelativeDateTextProvider textProviderWithDate:departureDate style:CLKRelativeDateStyleNatural units:NSCalendarUnitMinute];
        } else {
            textProvider = [CLKSimpleTextProvider textProviderWithText:@"--"];
        }
        
        CLKComplicationTemplateUtilitarianSmallFlat* template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
        template.textProvider = textProvider;
        template.imageProvider = imageProvider;
        
        return template;
    } else if (family == CLKComplicationFamilyUtilitarianLarge) {
        if (isValidDate) {
            CLKSimpleTextProvider *detailPart;
            if (self.complicationTransportName) {
                detailPart = [CLKSimpleTextProvider textProviderWithText:self.complicationTransportName];
            } else {
                detailPart = [CLKSimpleTextProvider textProviderWithText:@"DEPARTURE"];
            }
            
            CLKRelativeDateTextProvider *datePart = [CLKRelativeDateTextProvider textProviderWithDate:departureDate style:CLKRelativeDateStyleNatural units:NSCalendarUnitMinute];
            
            textProvider = [CLKTextProvider textProviderWithFormat:@"%@ • %@", detailPart, datePart];
        } else {
            textProvider = [CLKSimpleTextProvider textProviderWithText:@"NO DEPARTURE"];
        }
        
        CLKComplicationTemplateUtilitarianLargeFlat* template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init];
        template.textProvider = textProvider;
        template.imageProvider = imageProvider;
        
        return template;
    }
    
    return nil;
}

-(CLKComplicationTemplate *)modularTemplateForDate:(NSDate *)date andFamily:(CLKComplicationFamily)family {
    CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:self.complicationImage];
    imageProvider.tintColor = [AppManagerBase systemGreenColor];
    
    if (family == CLKComplicationFamilyModularLarge) {
        CLKComplicationTemplateModularLargeStandardBody* template = [[CLKComplicationTemplateModularLargeStandardBody alloc] init];
        
//        template.textProvider = [self textProviderForDate:(NSDate *)date andFamily:family];
        template.headerImageProvider = imageProvider;
        
        return template;
    }
    
    return nil;
}

- (void)refreshComplications {
    CLKComplicationServer *server = [CLKComplicationServer sharedInstance];
    for(CLKComplication *complication in server.activeComplications) {
        [server reloadTimelineForComplication:complication];
    }
}

#pragma mark - properties
-(NSDate *)complicationDepartureDate {
    ExtensionDelegate* myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
    NSDictionary* data = [myDelegate complicationData];
    
    return [data objectForKey:ComplicationDepartureDate];
}

-(NSString *)complicationTransportName {
    ExtensionDelegate* myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
    NSDictionary* data = [myDelegate complicationData];
    
    return [data objectForKey:ComplicationTransportaionName];
}

-(UIImage *)complicationImage {
    ExtensionDelegate* myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
    NSDictionary* data = [myDelegate complicationData];
    
    NSString *imageName = [data objectForKey:ComplicationImageName];
    if (imageName) {
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) return image;
        else return [UIImage imageNamed:@"Utilitarian-bus"];
    } else {
        return [UIImage imageNamed:@"Utilitarian-bus"];
    }
}

@end
