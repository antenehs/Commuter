//
//  MatkaApiClient.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WidgetAPIProtocols.h"

@interface MatkaApiClient : NSObject <WidgetRouteSearchProtocol, WidgetStopSearchProtocol, WidgetTransportTypeFetchProtocol>

@end
