//
//  TREAPIClient.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WidgetAPIProtocols.h"
#import "HSLandTRECommonApiClient.h"

@interface TREAPIClient : HSLandTRECommonApiClient <WidgetRouteSearchProtocol>

@end
