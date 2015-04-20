//
//  SettingsManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RettiDataManager.h"
#import "SettingsEntity.h"

typedef enum
{
    StandartMapMode = 0,
    HybridMapMode = 1,
    SateliteMapMode = 2
} MapMode;

@interface SettingsManager : NSObject

-(id)initWithDataManager:(RettiDataManager *)dataManager;

-(MapMode)getMapMode;
-(Region)userLocation;
-(BOOL)isClearingHistoryEnabled;
-(int)numberOfDaysToKeepHistory;

-(void)setMapMode:(MapMode)mapMode;
-(void)setUserLocation:(Region)userLocation;
-(void)enableClearingOldHistory:(BOOL)clear;
-(void)setNumberOfDaysToKeepHistory:(int)days;


@property(nonatomic, strong)RettiDataManager *reittiDataManager;

@property(nonatomic, strong)SettingsEntity *settingsEntity;


@end
