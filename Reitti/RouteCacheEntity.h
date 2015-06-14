//
//  RouteCacheEntity.h
//  
//
//  Created by Anteneh Sahledengel on 6/6/15.
//
//1 = Helsinki internal bus lines
//2 = trams
//3 = Espoo internal bus lines
//4 = Vantaa internal bus lines
//5 = regional bus lines
//6 = metro
//7 = ferry
//8 = U-lines
//12 = commuter trains
//21 = Helsinki service lines
//22 = Helsinki night buses
//23 = Espoo service lines
//24 = Vantaa service lines
//25 = region night buses
//36 = Kirkkonummi internal bus lines
//39 = Kerava internal bus lines
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RouteCacheEntity : NSManagedObject

//TODO: This list should be modified
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) NSString * routeOperator;
@property (nonatomic, retain) NSString * routeType;
@property (nonatomic, retain) NSString * routeUrl;

@end
