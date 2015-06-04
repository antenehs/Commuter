//
//  SettingsManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "SettingsManager.h"

@implementation SettingsManager

@synthesize reittiDataManager, settingsEntity;

-(id)initWithDataManager:(RettiDataManager *)dataManager{
    self.reittiDataManager = dataManager;
    
    [self.reittiDataManager fetchSettings];
    
//    [self.reittiDataManager resetSettings];
    
    return self;
}

-(MapMode)getMapMode{
    return (MapMode)[self.reittiDataManager.settingsEntity.mapMode  intValue];
}
-(Region)userLocation{
    return (Region)[self.reittiDataManager.settingsEntity.userLocation intValue];
}
-(BOOL)isClearingHistoryEnabled{
    return [self.reittiDataManager.settingsEntity.clearOldHistory boolValue];
}
-(int)numberOfDaysToKeepHistory{
    return [self.reittiDataManager.settingsEntity.numberOfDaysToKeepHistory intValue];
}

-(void)setMapMode:(MapMode)mapMode{
    [self.reittiDataManager.settingsEntity setMapMode:[NSNumber numberWithInt:mapMode]];
    [self.reittiDataManager saveSettings];
}
-(void)setUserLocation:(Region)userLocation{
    [self.reittiDataManager.settingsEntity setUserLocation:[NSNumber numberWithInt:userLocation]];
    [self.reittiDataManager saveSettings];
    self.reittiDataManager.userLocation = userLocation;
}
-(void)enableClearingOldHistory:(BOOL)clear{
    [self.reittiDataManager.settingsEntity setClearOldHistory:[NSNumber numberWithBool:clear]];
    [self.reittiDataManager saveSettings];
}
-(void)setNumberOfDaysToKeepHistory:(int)days{
    [self.reittiDataManager.settingsEntity setNumberOfDaysToKeepHistory:[NSNumber numberWithInt:days]];
    [self.reittiDataManager saveSettings];
}

@end