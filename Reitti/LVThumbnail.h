
#import <Foundation/Foundation.h>
#import "Vehicle.h"
@import MapKit;

typedef void (^ActionBlock)();

typedef enum{
    Tram = 1,
    Metro = 2,
    Train = 3,
    LongDistanceTrain = 4,
    Bus = 5
} VehicleAnnotationType;

@interface LVThumbnail : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *code2;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *lineId;
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic) VehicleType vehicleType;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSNumber * bearing;
@property (nonatomic, strong) id associatedVehicle;

@end
