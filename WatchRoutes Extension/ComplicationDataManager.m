//
//  ComplecationDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ComplicationDataManager.h"
#import <ClockKit/ClockKit.h>
#import "AppManager.h"

NSString* ComplicationDepartureDate = @"ComplicationDepartureDate";
NSString* ComplicationImageName = @"ComplicationImageName";
NSString* ComplicationTransportaionName = @"ComplicationTransportaionName";

@implementation ComplicationDataManager

+(instancetype)sharedManager {
    static ComplicationDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [ComplicationDataManager new];
    });
    
    return sharedInstance;
}

-(void)setRoute:(Route *)route {
    self.routeForComplication = route;
    if (route) {
        [self saveObjectToDefaults:route.timeAtTheFirstStop withKey:ComplicationDepartureDate];
        for (RouteLeg *leg in route.routeLegs) {
            if (leg.legType != LegTypeWalk) {
                [self saveObjectToDefaults:[AppManager complicationImageNameForLegTransportType:leg.legType] withKey:ComplicationImageName];
                [self saveObjectToDefaults:leg.lineDisplayName withKey:ComplicationTransportaionName];
                break;
            }
        }
    } else {
        [self saveObjectToDefaults:nil withKey:ComplicationDepartureDate];
        [self saveObjectToDefaults:nil withKey:ComplicationImageName];
        [self saveObjectToDefaults:nil withKey:ComplicationTransportaionName];
    }
    [self refreshComplications];
}

-(NSDictionary *)getComplicationData {
    return [[NSUserDefaults standardUserDefaults] dictionaryWithValuesForKeys:@[ComplicationDepartureDate, ComplicationImageName, ComplicationTransportaionName]];
}

- (void)refreshComplications {
    CLKComplicationServer *server = [CLKComplicationServer sharedInstance];
    for(CLKComplication *complication in server.activeComplications) {
        [server reloadTimelineForComplication:complication];
    }
}

#pragma mark - Helper methods
-(void)saveObjectToDefaults:(id)object withKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id)getObjectFromDefaultsForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

-(NSDictionary *)getDefaultsDictionary {
    return [[NSUserDefaults standardUserDefaults] dictionaryWithValuesForKeys:@[ComplicationDepartureDate, ComplicationImageName]];
}

@end
