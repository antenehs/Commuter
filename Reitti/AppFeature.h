//
//  AppFeature.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/20/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    AppFeatureNearbyDepartures,
    AppFeatureAppleWatchApp,
    AppFeatureRealtimeDepartures,
    AppFeatureRoutesWidget,
    AppFeatureNearbyDepartureWidget,
    AppFeatureCityBikes,
    AppFeatureLiveLines,
    AppFeatureIcloudBookmarks,
    AppFeatureRouteDisruptions,
    AppFeatureStopFilter,
    AppFeatureRemindersManager,
    AppFeatureRichReminders,
    AppFeatureTicketSales,
    AppFeatureFavouriteLines
} AppFeatureName;

typedef enum {
    FeatureImageContentModeCenter,
    FeatureImageContentModeBottom,
    FeatureImageContentModeTop,
    FeatureImageContentModeScaleAspectFit
} FeatureImageContentMode;


//Feature Image
@interface AppFeatureImage : NSObject

+(instancetype)featureImageWithIconNamed:(NSString *)iconName
                          mainImageNamed:(NSString *)mainImageName
                        imageContentMode:(FeatureImageContentMode)contentMode;

@property(nonatomic, strong)UIImage *iconImage;
@property(nonatomic, strong)UIImage *mainImage;
@property(nonatomic)FeatureImageContentMode imageContentMode;

@end

@interface AppFeature : NSObject

+(instancetype)featureWithName:(AppFeatureName)name
                   isAvailable:(BOOL)available;

@property (nonatomic)BOOL isAvailable;
@property (nonatomic)AppFeatureName name;
@property (nonatomic, strong, readonly)AppFeatureImage *featureImage;
//@property (nonatomic, strong, readonly)NSString *iconName;
//@property (nonatomic, strong, readonly)NSString *imageName;
@property (nonatomic, strong, readonly)UIColor  *themeColor;
@property (nonatomic, strong, readonly)NSString *displayName;
@property (nonatomic, strong, readonly)NSString *featureDescription;

@end
