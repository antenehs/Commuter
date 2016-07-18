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

NSString* ComplicationTransportationsDate = @"ComplicationTransportationsDate";
NSString* ComplicationTransportationImageName = @"ComplicationTransportationImageName";
NSString* ComplicationTransportationName = @"ComplicationTransportationName";
NSString* ComplicationTransportationColor = @"ComplicationTransportationColor";
NSString* ComplicationTransportations = @"ComplicationTransportations";
NSString* ComplicationRoute = @"ComplicationRoute";

@implementation ComplicationDataManager

+(instancetype)sharedManager {
    static ComplicationDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [ComplicationDataManager new];
    });
    
    return sharedInstance;
}

-(Route *)getComplicationRoute {
    NSDictionary *data = [self getComplicationRouteDict];
    NSDictionary *routedict = [self objectOrNilForKey:ComplicationRoute fromDictionary:data];
    if (!routedict) return nil;
    
    return [Route initFromDictionary:routedict];
}

-(void)setRoute:(Route *)route {
    if (route)
        [self saveObjectToDefaults:[route dictionaryRepresentation] withKey:ComplicationRoute];
    else
        [self saveObjectToDefaults:nil withKey:ComplicationRoute];
    
    [self refreshComplications];
}

-(NSDictionary *)getComplicationRouteDict {
    return [[NSUserDefaults standardUserDefaults] dictionaryWithValuesForKeys:@[ComplicationRoute]];
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
    return [[NSUserDefaults standardUserDefaults] dictionaryWithValuesForKeys:@[ComplicationRoute]];
}

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict {
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
