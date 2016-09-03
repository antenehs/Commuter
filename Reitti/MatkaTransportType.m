//
//  MatkaTransportType.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 1/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaTransportType.h"
#import "MatkaName.h"

@interface MatkaTransportType ()

@property (nonatomic, strong)NSString *displayName;
@property (nonatomic)VehicleType vehicleType;

@end

@implementation MatkaTransportType

-(NSString *)displayName {
    if (!_displayName) {
        _displayName = self.name;
    }
    
    return _displayName;
}

-(VehicleType)vehicleType {
    NSString *tridentName = [self tridentName];
    if (!tridentName) return VehicleTypeBus;
    
    if ([tridentName.lowercaseString isEqualToString:@"bus"]) {
        return VehicleTypeBus;
    } else if ([tridentName.lowercaseString isEqualToString:@"tramway"]) {
        return VehicleTypeTram;
    } else if ([tridentName.lowercaseString isEqualToString:@"metro"]) {
        return VehicleTypeMetro;
    } else if ([tridentName.lowercaseString isEqualToString:@"waterborne"]) {
        return VehicleTypeFerry;
    } else if ([tridentName.lowercaseString isEqualToString:@"air"]) {
        return VehicleTypeAirplane;
    } else if ([tridentName.lowercaseString isEqualToString:@"long distance train"] ||
               [tridentName.lowercaseString isEqualToString:@"rapid train"]) {
        return VehicleTypeLongDistanceTrain;
    } else if ([tridentName.lowercaseString isEqualToString:@"local train"] ||
               [tridentName.lowercaseString isEqualToString:@"train"]) {
        return VehicleTypeTrain;
    } else {
        return VehicleTypeOther;
    }
}

-(NSString *)tridentNameFi {
    if (_tridentNames && _tridentNames.count > 0) {
        for (MatkaName *name in _tridentNames) {
            if ([[name.language lowercaseString] isEqualToString:@"fi"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)tridentNameSe {
    if (_tridentNames && _tridentNames.count > 0) {
        for (MatkaName *name in _tridentNames) {
            if ([[name.language lowercaseString] isEqualToString:@"se"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)tridentName {
     return self.tridentNameFi ? self.tridentNameFi : self.tridentNameSe;
}

-(NSString *)nameFi {
    if (_names && _names.count > 0) {
        for (MatkaName *name in _names) {
            if ([[name.language lowercaseString] isEqualToString:@"fi"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)nameSe {
    if (_names && _names.count > 0) {
        for (MatkaName *name in _names) {
            if ([[name.language lowercaseString] isEqualToString:@"se"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)nameEn {
    if (_names && _names.count > 0) {
        for (MatkaName *name in _names) {
            if ([[name.language lowercaseString] isEqualToString:@"en"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)name {
    return self.nameFi ? self.nameFi : self.nameSe;
}


//Init and to Dictionary
+(instancetype)initFromDictionary:(NSDictionary *)dict {
    MatkaTransportType *typeObject = [[MatkaTransportType alloc] init];
    
    typeObject.typeId = dict[@"typeId"];
    typeObject.companyCode = dict[@"companyCode"];
    typeObject.tridentClass = dict[@"tridentClass"];
    
    NSMutableArray *names = [@[] mutableCopy];
    for (NSDictionary *nameDict in dict[@"names"]) {
        [names addObject:[MatkaName initFromDictionary:nameDict]];
    }
    typeObject.names = names;
    
    NSMutableArray *tridentNames = [@[] mutableCopy];
    for (NSDictionary *nameDict in dict[@"tridentNames"]) {
        [tridentNames addObject:[MatkaName initFromDictionary:nameDict]];
    }
    typeObject.tridentNames = tridentNames;
    
    return typeObject;
}

-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [@{} mutableCopy];
    
    [dict setValue:self.typeId forKey:@"typeId"];
    [dict setValue:self.companyCode forKey:@"companyCode"];
    [dict setValue:self.tridentClass forKey:@"tridentClass"];
    
    NSMutableArray *namesDicts = [@[] mutableCopy];
    for (MatkaName *name in self.names) {
        [namesDicts addObject:[name dictionaryRepresentation]];
    }
    [dict setValue:namesDicts forKey:@"names"];
    
    NSMutableArray *tridentNamesDicts = [@[] mutableCopy];
    for (MatkaName *name in self.tridentNames) {
        [tridentNamesDicts addObject:[name dictionaryRepresentation]];
    }
    [dict setValue:tridentNamesDicts forKey:@"tridentNames"];
    
    return dict;
}

@end
