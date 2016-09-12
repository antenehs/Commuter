//
//  MatkaApiClient.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WidgetAPIProtocols.h"

//No route search protocol for departure widgets. No need to include arcGIS
#if DEPARTURES_WIDGET
@interface MatkaApiClient : NSObject <WidgetStopSearchProtocol, WidgetTransportTypeFetchProtocol>
#else
@interface MatkaApiClient : NSObject <WidgetRouteSearchProtocol, WidgetStopSearchProtocol, WidgetTransportTypeFetchProtocol>
#endif
@end
