//
//  MatkaTransportTypeManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 1/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaTransportTypeManager.h"
#import "MatkaTransportType.h"
#import "AppManagerBase.h"
#ifndef WIDGET_APP
#import "MatkaCommunicator.h"
#else
#import "MatkaApiClient.h"
#endif

@interface MatkaTransportTypeManager ()

#ifndef WIDGET_APP
@property(nonatomic, strong)MatkaCommunicator *communicator;
#else
@property(nonatomic, strong)MatkaApiClient *communicator;
#endif

@property(nonatomic, strong)NSArray *transportTypes;

@end

@implementation MatkaTransportTypeManager

+(instancetype)sharedManager {
    static MatkaTransportTypeManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [MatkaTransportTypeManager new];
    });
    
    return sharedInstance;
}

-(id)init {
    self = [super init];
    if (self) {
#ifndef WIDGET_APP
        self.communicator = [MatkaCommunicator sharedManager];
#else
        self.communicator = [[MatkaApiClient alloc] init];
#endif
        [self readTypesFromDefaults];
        [self updateTransportTypes];
        NSLog(@"%d", [self vehicleTypeForTransportId:@"18"]);
        NSLog(@"%d", [self vehicleTypeForTransportId:@"24"]);
        NSLog(@"%d", [self vehicleTypeForTransportId:@"29"]);
        NSLog(@"%d", [self vehicleTypeForTransportId:@"27"]);
    }
    
    return self;
}

-(VehicleType)vehicleTypeForTransportId:(NSString *)typeId {
    NSArray *filtered = [self.transportTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"typeId == %@", typeId]];
    
    if (filtered && filtered.count > 0) {
        MatkaTransportType *transType = (MatkaTransportType *)filtered.firstObject;
        return transType.vehicleType;
    }
    
    return VehicleTypeBus;
}

-(LegTransportType)legTypeForMatkaTrasportType:(NSString *)typeId {
    LineType lineType = [self lineTypeForMatkaTrasportType:typeId];
    return [EnumManager legTrasportTypeForLineType:lineType];
}

-(LineType)lineTypeForMatkaTrasportType:(NSString *)typeId {
    VehicleType vehicleType = [self vehicleTypeForTransportId:typeId];
    return [EnumManager lineTypeForVehicleType:vehicleType];
}

//Transport type maintainance
-(void)updateTransportTypes {
    [self.communicator fetchTransportTypesWithCompletionBlock:^(NSArray *types, NSError *error) {
        if (!error && types.count > 0) {
            [self setTransportTypesIfValid:types];
        }
    }];
}

-(void)setTransportTypesIfValid:(NSArray *)types {
    if (!types || types.count < 1) return;
    self.transportTypes = types;
    [self saveTypesToDefaults];
}

//Save in shared defaults with routes widget.
-(void)saveTypesToDefaults {
    NSMutableArray *arrayOfTypes = [@[] mutableCopy];
    
    for (MatkaTransportType *type in self.transportTypes) {
        [arrayOfTypes addObject:[type dictionaryRepresentation]];
    }
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManagerBase nsUserDefaultsRoutesExtensionSuitName]];
    
    [sharedDefaults setObject:arrayOfTypes forKey:@"kMatkaTransportTypes"];
    [sharedDefaults synchronize];
}

-(void)readTypesFromDefaults {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManagerBase nsUserDefaultsRoutesExtensionSuitName]];
    id savedTypeDicts = [sharedDefaults objectForKey:@"kMatkaTransportTypes"];
    
    if (savedTypeDicts && [savedTypeDicts isKindOfClass:[NSArray class]]) {
        NSMutableArray *arrayOfTypes = [@[] mutableCopy];
    
        for (NSDictionary *dict in savedTypeDicts) {
            [arrayOfTypes addObject:[MatkaTransportType initFromDictionary:dict]];
        }
        
        [self setTransportTypesIfValid:arrayOfTypes];
    }
}

@end
