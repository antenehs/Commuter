//
//  HSLAndTRECommon.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "APIClient.h"
#import "StopDeparture.h"
#import "StopLine.h"

typedef void (^ActionBlock)();

@interface HSLAndTRECommon : APIClient

-(void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptionsDictionary:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock;

- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withOptionsDictionary:(NSDictionary *)optionsDict withCompletionBlock:(ActionBlock)completionBlock;

- (void)fetchStopDetailForCode:(NSString *)stopCode  andOptionsDictionary:(NSDictionary *)optionsDict withCompletionBlock:(ActionBlock)completionBlock;

- (void)fetchLineDetailForSearchterm:(NSString *)searchTerm andOptionsDictionary:(NSDictionary *)optionsDict withcompletionBlock:(ActionBlock)completionBlock;

- (void)fetchRevereseGeocodeWithOptionsDictionary:(NSDictionary *)optionsDict withcompletionBlock:(ActionBlock)completionBlock;

//Helpers
- (NSDate *)dateFromDateString:(NSString *)date andHourString:(NSString *)hour;
- (NSString *)readableHoursFromApiHours:(NSString *)apiHours;

+ (NSString *)lineJoreCodeForCode:(NSString *)code andDirection:(NSString *)direction;

@property (nonatomic, strong) NSDateFormatter *hourFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *fullDateFormatter;

@end
