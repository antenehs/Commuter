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

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (strong, nonatomic) WatchCommunicationManager *communicationManager;
@property (strong, nonatomic) WatchDataManager *watchDataManager;

@property (strong, nonatomic) IBOutlet WKInterfaceTable *bookmarksTable;

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
    
    //TODO: Read if there are named bookmarks saved
    [self loadSavedBookmarks];
    
    //TODO: Request for new data from phone
    //Setup table view
    [self setUpTableView];
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Table view methods
-(void)setUpTableView {
    NamedBookmarkE *home = [self getHomeBookmark];
    NamedBookmarkE *work = [self getWorkBookmark];
    
    NSMutableArray *otherBookmarks = [self.namedBookmarks mutableCopy];
    if (home) [otherBookmarks removeObject:home];
    if (work) [otherBookmarks removeObject:work];
    
    bool homeOrWorkExist = home || work;
    
    NSMutableArray *rowTypes = [@[] mutableCopy];
    if (homeOrWorkExist)
        [rowTypes addObject:@"HomeAndWorkRow"];
    
    for (int i = 0; i < otherBookmarks.count; i++)
        [rowTypes addObject:@"LocationRow"];
    
    if (rowTypes.count == 0) {
        [rowTypes addObject:@"InfoRow"];
        [self.titleLabel setHidden:YES];
    } else {
        [self.titleLabel setHidden:NO];
    }
    
    [self.bookmarksTable setRowTypes:rowTypes];
    
    //Setup home and work first
    
    for (int i = 0; i < self.bookmarksTable.numberOfRows; i++) {
        if (i == 0 && homeOrWorkExist) {
            HomeAndWorkRowController *controller = (HomeAndWorkRowController *)[self.bookmarksTable rowControllerAtIndex:i];
            [controller setUpWithHomeBookmark:home andWorkBookmark:work];
            controller.delegate = self;
        } else if (otherBookmarks.count > 0) {
            LocationRowController *controller = (LocationRowController *)[self.bookmarksTable rowControllerAtIndex:i];
            [controller setUpWithNamedBookmark:otherBookmarks[i - (homeOrWorkExist ? 1 : 0)]];
        }
    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    LocationRowController *controller = (LocationRowController *)[self.bookmarksTable rowControllerAtIndex:rowIndex];
    [self searchRouteToBookmark:controller.bookmark];
}

#pragma mark - Route methods
-(void)searchRouteToBookmark:(NamedBookmarkE *)bookmark {
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:60.215413888458 longitude:24.866182201828];

    [self presentControllerWithName:@"ActivityView" context:@"Loading Routes..."];
    [self.watchDataManager getRouteForNamedBookmark:bookmark fromLocation:fromLocation routeOptions:nil andCompletionBlock:^(NSArray *routes, NSString *errorString){
        [self dismissController];
        [self presentControllerWithNames:@[@"RouteView", @"RouteView", @"RouteView"] contexts:@[@"RouteView", @"RouteView", @"RouteView"]];
    }];
}

#pragma mark - Bookmarks method
-(void)saveBookmarksToUserDefaults {
    NSMutableArray *bookmarksArray = [@[] mutableCopy];
    if (self.namedBookmarks) {
        for (NamedBookmarkE *bookmark in self.namedBookmarks) {
            [bookmarksArray addObject:[bookmark dictionaryRepresentation]];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:bookmarksArray forKey:@"previousReceivedBookmark"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)loadSavedBookmarks {
    NSArray * savedBookmarks = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousReceivedBookmark"];
    if (savedBookmarks)
        [self initBookmarksFromBookmarksDictionaries:savedBookmarks];
}

-(void)initBookmarksFromBookmarksDictionaries:(NSArray *)bookmarkdictionaries {
    NSMutableArray *readNamedBookmarks = [@[] mutableCopy];
    if (bookmarkdictionaries) {
        for (NSDictionary *bookmarkDict in bookmarkdictionaries) {
            [readNamedBookmarks addObject:[[NamedBookmarkE alloc] initWithDictionary:bookmarkDict]];
        }
        
        self.namedBookmarks = [NSArray arrayWithArray:readNamedBookmarks];
    }
    
    [self setUpTableView];
}

-(NamedBookmarkE *)getHomeBookmark {
    if (self.namedBookmarks.count > 0) {
        NSArray *array = [self.namedBookmarks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name == %@ || self.iconPictureName == %@",@"Home", @"home-100.png" ]];
        if (array != nil && array.count > 0) {
            return array[0];
        }
    }
    
    return nil;
}

-(NamedBookmarkE *)getWorkBookmark {
    if (self.namedBookmarks.count > 0) {
        NSArray *array = [self.namedBookmarks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name == %@ || self.iconPictureName == %@",@"Work", @"work-filled-100.png" ]];
        if (array != nil && array.count > 0) {
            return array[0];
        }
    }
    
    return nil;
}

#pragma mark - HomeAndWork table controller Delegate methods
-(void)selectedBookmark:(NamedBookmarkE * _Nonnull)bookmark {
    [self searchRouteToBookmark:bookmark];
}

#pragma mark - Communication Manager Delegate methods
-(void)receivedNamedBookmarksArray:(NSArray *)bookmarksArray {
    
    NSLog(@"%@", bookmarksArray);
    
    //TODO: Check if anything is modified.
    [self initBookmarksFromBookmarksDictionaries:bookmarksArray];
    [self saveBookmarksToUserDefaults];
    
}

@end



