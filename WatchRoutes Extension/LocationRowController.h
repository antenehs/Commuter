//
//  LocationRowController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 2/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import "ApiProtocols.h"

@interface LocationRowController : NSObject

-(void)setUpWithNamedBookmark:(NSObject<RoutableLocationProtocol> *)namedBookmark;

@property (strong, nonatomic) IBOutlet WKInterfaceImage *locationImageView;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *nameLabel;

@property (strong, nonatomic) NSObject<RoutableLocationProtocol> *location;

@end
