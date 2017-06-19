//
//  AnnotationThumbnail.h
//  DetailedAnnotation
//
//  Created by Jean-Pierre Simard on 4/22/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearByStop.h"
#import "EnumManager.h"
#import "AnnotationProtocols.h"

@import MapKit;

@interface AnnotationThumbnail : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *shortCode;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *shrinkedImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic) ReittiAnnotationType annotationType;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) AnnotationActionBlock disclosureBlock;
@property (nonatomic, copy) AnnotationActionBlock primaryButtonBlock;
@property (nonatomic, copy) AnnotationActionBlock secondaryButtonBlock;

@end
