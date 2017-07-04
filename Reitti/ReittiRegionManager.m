//
//  ReittiRegionManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiRegionManager.h"
#import "XMLReader.h"
#import "StaticCity.h"
//#import <ArcGIS/ArcGIS.h>

typedef struct {
    CLLocationCoordinate2D topLeftCorner;
    CLLocationCoordinate2D bottomRightCorner;
} RTCoordinateRegion;

@interface ReittiRegionManager ()

//@property (nonatomic, strong)AGSMutablePolygon *hslRegionPolygon;
//@property (nonatomic, strong)AGSMutablePolygon *treRegionPolygon;

@property (nonatomic) RTCoordinateRegion helsinkiRegion;
@property (nonatomic) RTCoordinateRegion tampereRegion;

@end

@implementation ReittiRegionManager

+(id)sharedManager {
    static ReittiRegionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[ReittiRegionManager alloc] init];
    });
    
    return sharedManager;
}

-(id)init {
    self = [super init];
    
    if (self) {
        //do some
        [self initRegions];
    }
    
    return self;
}

-(void)initRegions {
//    NSArray *hslRegionCities = [self regionsFromKmlFileNamed:@"HSLRegion"];
//    self.hslRegionPolygon = [self polygoneFromRegionCities:hslRegionCities];
    
    CLLocationCoordinate2D coord1 = {.latitude = 60.256700 , .longitude = 24.507191 };
    CLLocationCoordinate2D coord2 = {.latitude = 60.017154 , .longitude = 25.332469};
    RTCoordinateRegion helsinkiRegionCoords = { coord1,coord2 };
    self.helsinkiRegion = helsinkiRegionCoords;
    
    CLLocationCoordinate2D coord3 = {.latitude = 61.892057 , .longitude = 22.781625 };
    CLLocationCoordinate2D coord4 = {.latitude = 61.092114 , .longitude = 24.716342};
    RTCoordinateRegion tampereRegionCoords = { coord3,coord4 };
    self.tampereRegion = tampereRegionCoords;
    
//    NSArray *treRegionCities = [self regionsFromKmlFileNamed:@"TRERegion"];
//    self.treRegionPolygon = [self polygoneFromRegionCities:treRegionCities];
}

-(BOOL)isCoordinateInHSLRegion:(CLLocationCoordinate2D)coord {
//    AGSPoint* point1 = [AGSPoint pointWithX:coord.longitude y:coord.latitude spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
//    
//    //Additional area check since the kml file might miss some border cases eg. near zalando office.
//    return [self.hslRegionPolygon containsPoint:point1] ||
    
    return [self isCoordinateInReittiRegion:self.helsinkiRegion coordinate:coord];
}

-(BOOL)isCoordinateInTRERegion:(CLLocationCoordinate2D)coord {
//    AGSPoint* point1 = [AGSPoint pointWithX:coord.longitude y:coord.latitude spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
//    
//    return [self.treRegionPolygon containsPoint:point1];
    
    return [self isCoordinateInReittiRegion:self.tampereRegion coordinate:coord];
}

-(Region)identifyRegionOfCoordinate:(CLLocationCoordinate2D)coords{
    
    if ([self isCoordinateInHSLRegion:coords]) {
        return HSLRegion;
    }
    
    if ([self isCoordinateInTRERegion:coords]) {
        return TRERegion;
    }
    
    return FINRegion;
}

-(NSString *)getNameOfRegion:(Region)region {
    if (region == HSLRegion) {
        return @"Helsinki";
    }else if (region == TRERegion) {
        return @"Tampere";
    }else{
        return @"Whole finland";
    }
}

+(CLLocationCoordinate2D)getCoordinateForRegion:(Region)region{
    if (region == TRERegion) {
        CLLocationCoordinate2D coord = {.latitude = 61.4981508 , .longitude = 23.7610254 };
        return coord;
    }else {
        CLLocationCoordinate2D coord = {.latitude = 60.170263 , .longitude = 24.941797 };
        return coord;
    }
}

-(BOOL)areCoordinatesInTheSameRegion:(CLLocationCoordinate2D)firstcoord andCoordinate:(CLLocationCoordinate2D)secondCoord{
    Region firstRegion = [self identifyRegionOfCoordinate:firstcoord];
    Region secondRegion = [self identifyRegionOfCoordinate:secondCoord];
    
    return firstRegion == secondRegion;
}

#pragma mark - Helpers
/*
-(AGSMutablePolygon *)polygoneFromRegionCities:(NSArray *)regionCities {
    if (!regionCities) return nil;
    
    AGSMutablePolygon* poly = [[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
    
    for (StaticCity *city in regionCities) {
        NSArray *boundaryArrays = [city getArrayOfBoundaryArrays];
        
        for (NSArray *border in boundaryArrays) {
            [poly addRingToPolygon];
            for (NSString *coord in border) {
                NSArray *comps = [coord componentsSeparatedByString:@","];
                if (comps.count != 2) continue;
                double x = [comps[0] doubleValue];
                double y = [comps[1] doubleValue];
                
                if (x == 0 || y == 0) continue;
                [poly addPointToRing:[AGSPoint pointWithX:x y:y spatialReference:nil]];
            }
        }
        
//        AGSPoint* point1 = [AGSPoint pointWithX:24.7921104431152 y:60.2465400695801 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
//        AGSPoint* point2 = [AGSPoint pointWithX:10 y:40 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
//        
//        BOOL one = [poly containsPoint:point1];
//        BOOL two = [poly containsPoint:point2];
    }
    
    
    return poly;
}
 */

/*
-(NSArray *)regionsFromKmlFileNamed:(NSString *)kmlFileName {
    NSString *pathToDataFile = [[NSBundle mainBundle] pathForResource:kmlFileName ofType:@"kml"];
    NSError *error;
    NSString* contents = [NSString stringWithContentsOfFile:pathToDataFile
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    
    NSData* xmlData = [contents dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *parseError = nil;
    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:xmlData
                                                            error:&parseError];
    
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[StaticCity class]];
    [mapping addAttributeMappingsFromDictionary:@{@"name.text": @"name",
                                                  @"MultiGeometry.Polygon.outerBoundaryIs.LinearRing.coordinates.text": @"bounderies",}];
    
    NSDictionary *mappingsDictionary = @{ @"kml.Document.Placemark": mapping };
    
    RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:xmlDictionary
                                                               mappingsDictionary:mappingsDictionary];
    
    NSError *mappingError = nil;
    
    BOOL isMapped = [mapper execute:&mappingError];
    
    if (isMapped && !mappingError) {
        NSLog(@"SUCCESS : %@",[[mapper mappingResult] array]);
        return [[mapper mappingResult] array];
    } else {
        NSLog(@"FAIL : %@",mappingError);
        return  nil;
    }
}
 */

-(BOOL)isCoordinateInReittiRegion:(RTCoordinateRegion)region coordinate:(CLLocationCoordinate2D)coords{
    if (coords.latitude < region.topLeftCorner.latitude &&
        coords.latitude > region.bottomRightCorner.latitude &&
        coords.longitude > region.topLeftCorner.longitude &&
        coords.longitude < region.bottomRightCorner.longitude) {
        return YES;
    }else
        return NO;
}

-(NSArray *)hslRegionCornerLocations {
    return @[[[CLLocation alloc] initWithLatitude:self.helsinkiRegion.topLeftCorner.latitude longitude:self.helsinkiRegion.topLeftCorner.longitude],
             [[CLLocation alloc] initWithLatitude:self.helsinkiRegion.topLeftCorner.latitude longitude:self.helsinkiRegion.bottomRightCorner.longitude],
             [[CLLocation alloc] initWithLatitude:self.helsinkiRegion.bottomRightCorner.latitude longitude:self.helsinkiRegion.bottomRightCorner.longitude],
             [[CLLocation alloc] initWithLatitude:self.helsinkiRegion.bottomRightCorner.latitude longitude:self.helsinkiRegion.topLeftCorner.longitude]];
}

-(NSArray *)treRegionCornerLocations {
    return @[[[CLLocation alloc] initWithLatitude:self.tampereRegion.topLeftCorner.latitude longitude:self.tampereRegion.topLeftCorner.longitude],
             [[CLLocation alloc] initWithLatitude:self.tampereRegion.topLeftCorner.latitude longitude:self.tampereRegion.bottomRightCorner.longitude],
             [[CLLocation alloc] initWithLatitude:self.tampereRegion.bottomRightCorner.latitude longitude:self.tampereRegion.bottomRightCorner.longitude],
             [[CLLocation alloc] initWithLatitude:self.tampereRegion.bottomRightCorner.latitude longitude:self.tampereRegion.topLeftCorner.longitude]];
}

@end
