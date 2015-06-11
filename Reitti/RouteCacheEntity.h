//
//  RouteCacheEntity.h
//  
//
//  Created by Anteneh Sahledengel on 6/6/15.
//
//0 - Tram, Streetcar, Light rail. Any light rail or street level system within a metropolitan area.
//1 - Subway, Metro. Any underground rail system within a metropolitan area.
//2 - Rail. Used for intercity or long-distance travel.
//3 - Bus. Used for short- and long-distance bus routes.
//4 - Ferry. Used for short- and long-distance boat service.
//5 - Cable car. Used for street-level cable cars where the cable runs beneath the car.
//6 - Gondola, Suspended cable car. Typically used for aerial cable cars where the car is suspended from the cable.
//7 - Funicular. Any rail system designed for steep inclines.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RouteCacheEntity : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) NSString * routeOperator;
@property (nonatomic, retain) NSString * routeType;
@property (nonatomic, retain) NSString * routeUrl;

@end
