//
//  AppFeature.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/20/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "AppFeature.h"
#import "UIColor+Custom.h"

@implementation AppFeatureImage

+(instancetype)featureImageWithIconNamed:(NSString *)iconName
                          mainImageNamed:(NSString *)mainImageName
                        imageContentMode:(FeatureImageContentMode)contentMode {
    AppFeatureImage *featureImage = [AppFeatureImage new];
    
    featureImage.iconImage = [UIImage imageNamed:iconName];
    featureImage.mainImage = [UIImage imageNamed:mainImageName];
    featureImage.imageContentMode = contentMode;
    
    return featureImage;
}

@end

@interface AppFeature ()

@property (nonatomic, strong)AppFeatureImage *featureImage;
@property (nonatomic, strong)NSString *iconName;
@property (nonatomic, strong)NSString *imageName;
@property (nonatomic, strong)UIColor  *themeColor;
@property (nonatomic, strong)NSString *displayName;
@property (nonatomic, strong)NSString *featureDescription;

@end

@implementation AppFeature

+(instancetype)featureWithName:(AppFeatureName)name
                   isAvailable:(BOOL)available {
    AppFeature *feature = [AppFeature new];
    
    feature.name = name;
    feature.isAvailable = available;
    
    return feature;
}


#pragma mark - Helpers
-(NSString *)displayName {
    if (!_displayName) {
        switch (self.name) {
            case AppFeatureNearbyDepartures:
                _displayName = @"Nearby Departures";
                break;
            case AppFeatureAppleWatchApp:
                _displayName = @"Apple Watch App";
                break;
            case AppFeatureRealtimeDepartures:
                _displayName = @"Real-time Departures";
                break;
            case AppFeatureRoutesWidget:
                _displayName = @"Routes Widget";
                break;
            case AppFeatureNearbyDepartureWidget:
                _displayName = @"Nearby Departures Widget";
                break;
            case AppFeatureCityBikes:
                _displayName = @"Helsinki City Bikes";
                break;
            case AppFeatureLiveLines:
                _displayName = @"Live Lines";
                break;
            case AppFeatureIcloudBookmarks:
                _displayName = @"iCloud Bookmarks";
                break;
            case AppFeatureRouteDisruptions:
                _displayName = @"Route Disruptions";
                break;
            case AppFeatureStopFilter:
                _displayName = @"Stop Filter";
                break;
            case AppFeatureRichReminders:
                _displayName = @"Rich Reminders";
                break;
            case AppFeatureTicketSales:
                _displayName = @"Ticket Sales Points";
                break;
            case AppFeatureFavouriteLines:
                _displayName = @"Favorite Lines";
                break;
                
            default:
                break;
        }
        
    }
    
    return _displayName;
}

-(NSString *)featureDescription {
    if (!_featureDescription) {
        switch (self.name) {
            case AppFeatureNearbyDepartures:
                _featureDescription = @"See departures from stops and Citybike availability near you without lifting a finger.";
                break;
            case AppFeatureAppleWatchApp:
                _featureDescription = @"Get updates about your routes, and search for routes and stop timetables right on the watch.";
                break;
            case AppFeatureRealtimeDepartures:
                _featureDescription = @"Get real-time departures from stops to see delays or cancelations.";
                break;
            case AppFeatureRoutesWidget:
                _featureDescription = @"The easiest and quickest way to get route suggestion to your saved locations.";
                break;
            case AppFeatureNearbyDepartureWidget:
                _featureDescription = @"The easiest and quickest way to see departures near you without even opening the app.";
                break;
            case AppFeatureCityBikes:
                _featureDescription = @"Get locations of all HSL's City Bikes with a real-time update of availablility.";
                break;
            case AppFeatureLiveLines:
                _featureDescription = @"See where exactly your tram, metro or train is on the line view.";
                break;
            case AppFeatureIcloudBookmarks:
                _featureDescription = @"Your bookmarks are stored on iCloud for easy access on all your devices. ";
                break;
            case AppFeatureRouteDisruptions:
                _featureDescription = @"Get notified of any disruptions that affects your route. (Only in Helsinki region)";
                break;
            case AppFeatureStopFilter:
                _featureDescription = @"Filter away all the stops that doesn't interest you.";
                break;
            case AppFeatureRichReminders:
                _featureDescription = @"Easily configure recurring routes to get rich notifications and automatic route suggestion.";
                break;
            case AppFeatureTicketSales:
                _featureDescription = @"Find the nearest HSL ticket sales point and get walking route suggestion.";
                break;
            case AppFeatureFavouriteLines:
                _featureDescription = @"Favorite Lines to get relevant departures from stops.";
                break;
                
            default:
                break;
        }
    }
    
    return _featureDescription;
}

-(AppFeatureImage *)featureImage {
    if (!_featureImage) {
        switch (self.name) {
            case AppFeatureNearbyDepartures:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"departures-feature" mainImageNamed:@"nearbyDepartures" imageContentMode:FeatureImageContentModeBottom];
                break;
            case AppFeatureAppleWatchApp:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"apple-watch-feature" mainImageNamed:@"appleWatch" imageContentMode:FeatureImageContentModeCenter];
                break;
            case AppFeatureRealtimeDepartures:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"realtime-feature" mainImageNamed:@"realtimeDeparture" imageContentMode:FeatureImageContentModeBottom];
                break;
            case AppFeatureRoutesWidget:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"route-widget-feature" mainImageNamed:@"widgetsPro" imageContentMode:FeatureImageContentModeTop];
                break;
            case AppFeatureNearbyDepartureWidget:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"nearby-widget-feature" mainImageNamed:@"" imageContentMode:FeatureImageContentModeBottom];
                break;
            case AppFeatureCityBikes:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"bike-feature" mainImageNamed:@"cityBikes" imageContentMode:FeatureImageContentModeBottom];
                break;
            case AppFeatureLiveLines:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"realtime-feature" mainImageNamed:@"liveLines" imageContentMode:FeatureImageContentModeBottom];
                break;
            case AppFeatureIcloudBookmarks:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"icloud-feature" mainImageNamed:@"iCloudSynchPic" imageContentMode:FeatureImageContentModeScaleAspectFit];
                break;
            case AppFeatureRouteDisruptions:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"disruption-feature" mainImageNamed:@"" imageContentMode:FeatureImageContentModeBottom];
                break;
            case AppFeatureStopFilter:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"stop-filter-feature" mainImageNamed:@"stopFilter" imageContentMode:FeatureImageContentModeBottom];
                break;
            case AppFeatureRichReminders:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"reminder-feature" mainImageNamed:@"richReminders" imageContentMode:FeatureImageContentModeTop];
                break;
            case AppFeatureTicketSales:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"ticket-feature" mainImageNamed:@"ticketSalesPoint" imageContentMode:FeatureImageContentModeTop];
                break;
            case AppFeatureFavouriteLines:
                _featureImage = [AppFeatureImage featureImageWithIconNamed:@"star-feature" mainImageNamed:@"" imageContentMode:FeatureImageContentModeBottom];
                break;
                
            default:
                break;
        }
    }
    
    return _featureImage;
}

-(UIColor *)themeColor {
    if (!_themeColor) {
        switch (self.name) {
            case AppFeatureNearbyDepartures:
                _themeColor = [UIColor systemBlueColor];
                break;
            case AppFeatureAppleWatchApp:
                _themeColor = [UIColor systemBlueBlackColor];
                break;
            case AppFeatureRealtimeDepartures:
                _themeColor = [UIColor systemGreenColor];
                break;
            case AppFeatureRoutesWidget:
                _themeColor = [UIColor systemYellowColor];
                break;
            case AppFeatureNearbyDepartureWidget:
                _themeColor = [UIColor systemBlueColor];
                break;
            case AppFeatureCityBikes:
                _themeColor = [UIColor systemYellowColor];
                break;
            case AppFeatureLiveLines:
                _themeColor = [UIColor systemCyanColor];
                break;
            case AppFeatureIcloudBookmarks:
                _themeColor = [UIColor systemGreenColor];
                break;
            case AppFeatureRouteDisruptions:
                _themeColor = [UIColor systemRedColor];
                break;
            case AppFeatureStopFilter:
                _themeColor = [UIColor systemGreenColor];
                break;
            case AppFeatureRichReminders:
                _themeColor = [UIColor systemPurpleColor];
                break;
            case AppFeatureTicketSales:
                _themeColor = [UIColor systemBlueColor];
                break;
            case AppFeatureFavouriteLines:
                _themeColor = [UIColor systemGreenColor];
                break;
                
            default:
                break;
        }
    }
    
    return _themeColor;
}

@end
