//
//  ReittiSearchManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 22/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SearchableNamedBookmarkType,
    SearchableSavedStopType,
    SearchableSavedRouteType,
    UnknownSearchableType
} SpotlightObjectType;

@interface ReittiSearchManager : NSObject

+(id)sharedManager;
-(id)init;

-(void)updateSearchableIndexes;

+(SpotlightObjectType)spotlightObjectTypeForIdentifier:(NSString *)identifier;
+(NSString *)uniqueObjectNameForIdentifier:(NSString *)identifier;
+(NSString *)domainIdentifierForIdentifier:(NSString *)identifier;


@end
