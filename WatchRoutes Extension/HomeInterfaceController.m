//
//  InterfaceController.m
//  WatchRoutes Extension
//
//  Created by Anteneh Sahledengel on 26/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "HomeInterfaceController.h"
#import "AppManagerBase.h"
#import "NamedBookmarkE.h"
#import "WatchDataManager.h"

@interface HomeInterfaceController()

@property (strong, nonatomic) NSUserDefaults *sharedDefaults;
@property (strong, nonatomic) NSArray *namedBookmarks;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *tempLabel;
@property (strong, nonatomic) WatchCommunicationManager *communicationManager;
@property (strong, nonatomic) WatchDataManager *watchDataManager;
@end


@implementation HomeInterfaceController

-(instancetype)init {
    self = [super init];
    if (self) {
//        [WKInterfaceController reloadRootControllersWithNames:@[@"Third", @"Third"] contexts:@[@"Home", @"Second"]];
        self.watchDataManager = [WatchDataManager new];
    }
    
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

//    [self readNamedBookmarksFromUserDefaults];
    
    self.communicationManager = [WatchCommunicationManager sharedManager];
    self.communicationManager.delegate = self;
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

//
-(void)receivedNamedBookmarksArray:(NSArray *)bookmarksArray {
    
    NSLog(@"%@", bookmarksArray);
    
    NSMutableArray *readNamedBookmarks = [@[] mutableCopy];
    if (bookmarksArray) {
        for (NSDictionary *bookmarkDict in bookmarksArray) {
            [readNamedBookmarks addObject:[[NamedBookmarkE alloc] initWithDictionary:bookmarkDict]];
        }
        
        self.namedBookmarks = [NSArray arrayWithArray:readNamedBookmarks];
    }
    
    if (!readNamedBookmarks || readNamedBookmarks.count < 1) return;
    
    [self.tempLabel setText:[self.namedBookmarks[0] name]];
    
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:60.215413888458 longitude:24.866182201828];
    
    [self.watchDataManager getRouteForNamedBookmark:self.namedBookmarks[0] fromLocation:fromLocation routeOptions:nil andCompletionBlock:^(NSArray *routes, NSString *errorString){
        
    }];
}

@end



