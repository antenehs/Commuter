//
//  HSLServicePointManager.m
//  
//
//  Created by Anteneh Sahledengel on 31/8/15.
//
//

#import "HSLServicePointManager.h"

@implementation HSLServicePointManager

+(NSMutableArray *)getServicePoints{
    NSMutableArray *servicePoints = [[NSMutableArray alloc] init];
    
    NSDictionary *parsedObject = [HSLServicePointManager parsedServicePointsJson];
    
    NSArray *results = parsedObject[@"hsl_ticket_sales_points_service_point"][@"features"];
    
    [self loadSErvicePointsFromJsonArray:servicePoints results:results];
    
    return servicePoints;
}

+(NSMutableArray *)getSalesPoints{
    NSMutableArray *servicePoints = [[NSMutableArray alloc] init];
    
    NSDictionary *parsedObject = [HSLServicePointManager parsedServicePointsJson];
    
    NSMutableArray *results = [@[] mutableCopy];
    
    [results addObjectsFromArray:parsedObject[@"hsl_ticket_sales_points_multi_tickets"][@"features"]];
    [results addObjectsFromArray:parsedObject[@"hsl_ticket_sales_points_sales_point"][@"features"]];
    [results addObjectsFromArray:parsedObject[@"hsl_ticket_sales_points_single_tickets"][@"features"]];
    
    [self loadSErvicePointsFromJsonArray:servicePoints results:results];
    
    return servicePoints;
}

+(void)loadSErvicePointsFromJsonArray:(NSMutableArray *)servicePoints results:(NSArray *)results {
    for (NSDictionary *spDict in results) {
        @try {
            ServicePoint *sPoint = [[ServicePoint alloc] initWithDictionary:spDict];
            if (CLLocationCoordinate2DIsValid(sPoint.coordinates) && sPoint.coordinates.latitude != 0) {
                [servicePoints addObject:sPoint];
            }
        }
        @catch (NSException *exception) {
        }
    }
}

+(NSDictionary *)parsedServicePointsJson{
    NSError *localError = nil;
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"HSLCardServicePoints.json"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                                     options:kNilOptions
                                                                       error:&localError];
        
        if (localError != nil)
            return @{};
        
        return parsedObject;

    }
    
    return @{};
}

@end
