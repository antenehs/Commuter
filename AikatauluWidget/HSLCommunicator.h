//
//  HSLCommunicator.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSLCommunicator : NSObject

-(int)fetchDeparturesForStop:(NSString *)code;

@end
