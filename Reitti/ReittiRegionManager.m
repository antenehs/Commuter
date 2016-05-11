//
//  ReittiRegionManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiRegionManager.h"
#import <RestKit/RestKit.h>
#import "XMLReader.h"
#import "StaticCity.h"
#import <ArcGIS/ArcGIS.h>

typedef struct {
    CLLocationCoordinate2D topLeftCorner;
    CLLocationCoordinate2D bottomRightCorner;
} RTCoordinateRegion;

@interface ReittiRegionManager ()

@property (nonatomic, strong)AGSMutablePolygon *hslRegionPolygon;
@property (nonatomic, strong)AGSMutablePolygon *treRegionPolygon;

@property (nonatomic) RTCoordinateRegion additionalHelsinkiRegion;

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
    NSArray *hslRegionCities = [self regionsFromKmlFileNamed:@"HSLRegion"];
    self.hslRegionPolygon = [self polygoneFromRegionCities:hslRegionCities];
    
    CLLocationCoordinate2D coord1 = {.latitude = 60.256700 , .longitude = 24.507191 };
    CLLocationCoordinate2D coord2 = {.latitude = 60.017154 , .longitude = 25.332469};
    RTCoordinateRegion helsinkiRegionCoords = { coord1,coord2 };
    self.additionalHelsinkiRegion = helsinkiRegionCoords;
    
    NSArray *treRegionCities = [self regionsFromKmlFileNamed:@"TRERegion"];
    self.treRegionPolygon = [self polygoneFromRegionCities:treRegionCities];
}

-(BOOL)isCoordinateInHSLRegion:(CLLocationCoordinate2D)coord {
    AGSPoint* point1 = [AGSPoint pointWithX:coord.longitude y:coord.latitude spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
    
    //Additional area check since the kml file might miss some border cases eg. near zalando office.
    return [self.hslRegionPolygon containsPoint:point1] || [self isCoordinateInReittiRegion:self.additionalHelsinkiRegion coordinate:coord];
}

-(BOOL)isCoordinateInTRERegion:(CLLocationCoordinate2D)coord {
    AGSPoint* point1 = [AGSPoint pointWithX:coord.longitude y:coord.latitude spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
    
    return [self.treRegionPolygon containsPoint:point1];
}

#pragma mark - Helpers
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

-(BOOL)isCoordinateInReittiRegion:(RTCoordinateRegion)region coordinate:(CLLocationCoordinate2D)coords{
    if (coords.latitude < region.topLeftCorner.latitude &&
        coords.latitude > region.bottomRightCorner.latitude &&
        coords.longitude > region.topLeftCorner.longitude &&
        coords.longitude < region.bottomRightCorner.longitude) {
        return YES;
    }else
        return NO;
}

@end