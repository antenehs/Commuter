//
//  SettingsEntity.h
//  
//
//  Created by Anteneh Sahledengel on 18/4/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SettingsEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * mapMode;
@property (nonatomic, retain) NSNumber * userLocation;
@property (nonatomic, retain) NSNumber * clearOldHistory;
@property (nonatomic, retain) NSNumber * numberOfDaysToKeepHistory;
@property (nonatomic, retain) NSDate   * settingsStartDate;

@end
