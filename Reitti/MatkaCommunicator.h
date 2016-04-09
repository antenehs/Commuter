//
//  MatkaCommunicator.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiProtocols.h"
#import "APIClient.h"

@interface MatkaCommunicator : APIClient <StopsInAreaSearchProtocol> {
     NSArray *apiUserNames;
}

@end
