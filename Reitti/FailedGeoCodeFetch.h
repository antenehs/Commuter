//
//  FailedGeoCodeFetch.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FailedGeoCodeFetch : NSObject

@property(nonatomic)NSInteger errorCode;
@property(nonatomic, strong)NSString *textForError;

@end
