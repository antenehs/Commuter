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
#import "AppManager.h"
#import "Route.h"

@interface NSDate (ComplicationHelper)
-(BOOL)isValidDate;
@end

@implementation NSDate (ComplicationHelper)
-(BOOL)isValidDate {
    return [self timeIntervalSinceDate:[NSDate date]] > 0;
}
@end

@interface Route (WatchComplication)
-(RouteLeg *)nextLeg;
@end

@implementation Route (WatchComplication)
-(RouteLeg *)nextLeg {
    NSDate *now = [NSDate date];
    
    for (RouteLeg *leg in self.noneWalkingLegs) {
        if ([now compare:leg.departureTime] == NSOrderedAscending)
            return leg;
    }
    
    return nil;
}
@end

@interface ComplicationController ()

//@property (nonatomic, strong, readonly)NSDate *complicationDepartureDate;
//@property (nonatomic, strong, readonly)NSString *complicationTransportName;
//@property (nonatomic, strong, readonly)UIImage *complicationImage;

@property (nonatomic, strong, readonly)Route *complicationRoute;

@end

@implementation ComplicationController

-(Route *)complicationRoute {
    ExtensionDelegate* myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
    return [myDelegate complicationRoute];
}

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionForward|CLKComplicationTimeTravelDirectionBackward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler(nil);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    Route *route = self.complicationRoute;
    if (route) {
        handler([route endingTimeOfRoute]);
    } else {
        handler(nil);
    }
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    // Get the current complication data from the extension delegate.
    
    RouteLeg *nextLeg = self.complicationRoute.nextLeg;
    if (nextLeg) {
        CLKComplicationTemplate* template = [self templateForLeg:nextLeg andFamily:complication.family];
        handler([CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template]);
    } else {
        handler(nil);
    }
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    NSArray *allLegs = self.complicationRoute.noneWalkingLegs;
    if (allLegs && allLegs.count > 0) {
        NSArray *beforeLegs = [allLegs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            RouteLeg *leg = (RouteLeg *)object;
            return [date compare:leg.departureTime] == NSOrderedDescending;
        }]];
        
        NSArray *entries = [self timeLineEntriesForLegs:beforeLegs startDate:date andComplicationFamily:complication.family];
        handler(entries);
    } else {
        handler(nil);
    }
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after to the given date
    
    NSArray *allLegs = self.complicationRoute.noneWalkingLegs;
    if (allLegs && allLegs.count > 0) {
        NSArray *afterLegs = [allLegs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            RouteLeg *leg = (RouteLeg *)object;
            return [date compare:leg.departureTime] == NSOrderedAscending;
        }]];
        
        NSArray *entries = [self timeLineEntriesForLegs:afterLegs startDate:date andComplicationFamily:complication.family];
        handler(entries);
    } else {
        handler(nil);
    }
   
//    CLKComplicationTimelineEntry* nowEntry = [self timeLineEntryForDate:date andComplicationFamily:complication.family];
//    CLKComplicationTimelineEntry* endEntry = [self timeLineEntryForDate:self.complicationDepartureDate andComplicationFamily:complication.family];
//    
//    if (nowEntry && endEntry) {
//        handler(@[nowEntry, endEntry]);
//    } else {
//        handler(nil);
//    }
}

-(NSArray *)timeLineEntriesForLegs:(NSArray *)legs startDate:(NSDate *)date andComplicationFamily:(CLKComplicationFamily)family {
    NSMutableArray *entries = [@[] mutableCopy];
    int index = 0;
    for (RouteLeg *leg in legs) {
        if (index == 0) {
            CLKComplicationTemplate* template = [self templateForLeg:leg andFamily:family];
            CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:date complicationTemplate:template];
            if (entry) [entries addObject:entry];
        } else {
            RouteLeg *prevLeg = legs[index - 1];
            CLKComplicationTemplate* template = [self templateForLeg:leg andFamily:family];
            CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:prevLeg.departureTime complicationTemplate:template];
            if (entry) [entries addObject:entry];
        }
        
        index++;
    }
    
    return entries;
}

#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)(NSDate * __nullable updateDate))handler {
    // Call the handler with the date when you would next like to be given the opportunity to update your complication content
    
    NSDate *departureDate = self.complicationRoute.endingTimeOfRoute;
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
    
    handler([self templateForLeg:nil andFamily:complication.family]);
}



#pragma mark - Helpers
-(CLKComplicationTimelineEntry *)timeLineEntryForLeg:(RouteLeg *)leg andComplicationFamily:(CLKComplicationFamily)family {
    CLKComplicationTemplate* template = [self templateForLeg:leg andFamily:family];
    return [CLKComplicationTimelineEntry entryWithDate:leg.departureTime complicationTemplate:template];
}

-(CLKComplicationTemplate *)templateForLeg:(RouteLeg *)leg andFamily:(CLKComplicationFamily)family {
    if (family == CLKComplicationFamilyUtilitarianSmall || family == CLKComplicationFamilyUtilitarianLarge) {
        return [self utilitarianTemplateForLeg:leg andFamily:family];
    } else if (family == CLKComplicationFamilyModularSmall || family == CLKComplicationFamilyModularLarge)  {
        return [self modularTemplateForLeg:leg andFamily:family];
    }
    
    return nil;
}

-(CLKComplicationTemplate *)utilitarianTemplateForLeg:(RouteLeg *)leg andFamily:(CLKComplicationFamily)family {
    CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[self complicationImageForLeg:leg]];
    imageProvider.tintColor = [AppManagerBase systemGreenColor];
    
    CLKTextProvider *textProvider;
    if (family == CLKComplicationFamilyUtilitarianSmall) {
        if (leg) {
            textProvider = [CLKRelativeDateTextProvider textProviderWithDate:leg.departureTime style:CLKRelativeDateStyleNatural units:NSCalendarUnitMinute];
        } else {
            textProvider = [CLKSimpleTextProvider textProviderWithText:@"--"];
        }
        CLKComplicationTemplateUtilitarianSmallFlat* template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
        template.textProvider = textProvider;
        template.imageProvider = imageProvider;
        
        return template;
    } else if (family == CLKComplicationFamilyUtilitarianLarge) {
        if (leg) {
            CLKSimpleTextProvider *detailPart;
            detailPart = [CLKSimpleTextProvider textProviderWithText:leg.lineDisplayName];
            
            CLKRelativeDateTextProvider *datePart = [CLKRelativeDateTextProvider textProviderWithDate:leg.departureTime style:CLKRelativeDateStyleOffset units:NSCalendarUnitMinute];
            
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

-(CLKComplicationTemplate *)modularTemplateForLeg:(RouteLeg *)leg andFamily:(CLKComplicationFamily)family {
    CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[self complicationImageForLeg:leg]];
    imageProvider.tintColor = [AppManagerBase systemGreenColor];
    
    if (family == CLKComplicationFamilyModularLarge) {
        CLKComplicationTemplateModularLargeStandardBody* template = [[CLKComplicationTemplateModularLargeStandardBody alloc] init];
        
        //        template.textProvider = [self textProviderForDate:(NSDate *)date andFamily:family];
        template.headerImageProvider = imageProvider;
        
        return template;
    }
    
    return nil;
}

-(UIImage *)complicationImageForLeg:(RouteLeg *)leg {
    UIImage *defaultImage = [UIImage imageNamed:@"Utilitarian-bus"];
    if (!leg) return defaultImage;
    
    NSString *imageName = [AppManager complicationImageNameForLegTransportType:leg.legType];
    
    if (imageName) {
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) return image;
        else return defaultImage;
    } else {
        return defaultImage;
    }
}

/*
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
*/
- (void)refreshComplications {
    CLKComplicationServer *server = [CLKComplicationServer sharedInstance];
    for(CLKComplication *complication in server.activeComplications) {
        [server reloadTimelineForComplication:complication];
    }
}

#pragma mark - properties
//-(NSDate *)complicationDepartureDate {
//    ExtensionDelegate* myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
//    NSDictionary* data = [myDelegate complicationData];
//    
//    return [self objectOrNilForKey:ComplicationDepartureDate fromDictionary:data];
//}
//
//-(NSString *)complicationTransportName {
//    ExtensionDelegate* myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
//    NSDictionary* data = [myDelegate complicationData];
//    
//    return [self objectOrNilForKey:ComplicationTransportaionName fromDictionary:data];
//}
//
//-(UIImage *)complicationImage {
//    ExtensionDelegate* myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
//    NSDictionary* data = [myDelegate complicationData];
//    
//    NSString *imageName = [self objectOrNilForKey:ComplicationImageName fromDictionary:data];
//    
//    if (imageName) {
//        UIImage *image = [UIImage imageNamed:imageName];
//        if (image) return image;
//        else return [UIImage imageNamed:@"Utilitarian-bus"];
//    } else {
//        return [UIImage imageNamed:@"Utilitarian-bus"];
//    }
//}

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
