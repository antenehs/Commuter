//
//  MatkaObjectMapping.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface MatkaObjectMapping : NSObject

+ (RKResponseDescriptor *)routeResponseDescriptor;
+ (RKObjectMapping *)matkaStopMapping;
+ (RKResponseDescriptor *)stopResponseDescriptorForPath:(NSString *)keyPath;
+ (RKResponseDescriptor *)lineResponseDescriptorForKeyPath:(NSString *)keyPath detailed:(BOOL)detail;
+ (RKObjectMapping *)matkaLineObjectMapping;
+ (RKObjectMapping *)matkaDetailLineObjectMapping;
+ (RKObjectMapping *)matkaLineStopObjectMapping;
+ (RKObjectMapping *)matkaNameObjectMapping;
+ (RKObjectMapping *)matkaRouteLocationMapping;
+ (RKObjectMapping *)matkaRouteStopMapping;
+ (RKObjectMapping *)matkaRouteLocNameMapping;
+ (RKObjectMapping *)matkaRouteLegMapping;
+ (RKResponseDescriptor *)geocodeResponseDescriptorForPath:(NSString *)keyPath;
+ (RKObjectMapping *)matkaTransportTypeObjectMapping;
+ (RKResponseDescriptor *)matkaTransportTypeResponseDescriptorForPath:(NSString *)keyPath;

@end
