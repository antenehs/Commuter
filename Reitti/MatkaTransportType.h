//
//  MatkaTransportType.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 1/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumManager.h"
/*
 
 <TRANSPORT typeId="15" companyCode="YTV">
    <name lang="fi">Juna</name>
    <name lang="se">Tåg</name>
    <name lang="en">Train</name>
    <TRIDENT class="21">
        <name lang="fi">long distance train</name>
        <name lang="se">long distance train</name>
    </TRIDENT>
 </TRANSPORT>
 
 */

@interface MatkaTransportType : NSObject

+(instancetype)initFromDictionary:(NSDictionary *)dict;
-(NSDictionary *)dictionaryRepresentation;

@property (nonatomic, strong)NSString *typeId;
@property (nonatomic, strong)NSString *companyCode;
@property (nonatomic, strong)NSArray *names;
@property (nonatomic, strong)NSString *tridentClass;
@property (nonatomic, strong)NSArray *tridentNames;

//Derived
@property (nonatomic, strong, readonly)NSString *displayName;
@property (nonatomic, readonly)VehicleType vehicleType;

@end
