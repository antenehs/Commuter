//
//  GCThumbnail.h
//  GCThumbnailAnnotation
//
//  Created by Jean-Pierre Simard on 4/22/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearByStop.h"
@import MapKit;

typedef void (^ActionBlock)();

@interface GCThumbnail : NSObject

@property (nonatomic, strong) NSNumber *code;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic) StopType stopType;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) ActionBlock disclosureBlock;
@property (nonatomic, copy) ActionBlock primaryButtonBlock;
@property (nonatomic, copy) ActionBlock secondaryButtonBlock;
@property (nonatomic, copy) ActionBlock middleButtonBlock;

@end
