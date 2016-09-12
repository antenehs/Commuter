//
//  ContactsManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeoCode.h"

typedef void (^ActionBlock)();

@interface ContactsManager : NSObject {
    NSInteger requestCount;
    BOOL trackedAccessOnce;
}

+(instancetype)sharedManager;
-(void)customRequestForAccess;

-(BOOL)isAuthorized;
-(BOOL)isAccessRequested;

-(NSArray *)getContactsForSearchTerm:(NSString *)searchTerm;
-(void)getCoordsForGeoCode:(GeoCode *)geoCode withCompletion:(ActionBlock)completion;

@property(nonatomic, strong)NSArray *contactsWithAddress;

@end
