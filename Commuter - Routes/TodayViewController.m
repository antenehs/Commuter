//
//  TodayViewController.m
//  Commuter - Routes
//
//  Created by Anteneh Sahledengel on 8/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <MapKit/MapKit.h>
#import "AppManagerBase.h"
#import "ASABubbleView.h"
#import "WidgetDataManager.h"
#import "ReittiStringFormatterE.h"
#import "Route.h"
#import "Transport.h"
#import "UIView+Helper.h"
#import "MatkaTransportTypeManager.h"
#import "NSArray+Helper.h"

#import "NamedBookmark.h"

@interface TodayViewController () <NCWidgetProviding, CLLocationManagerDelegate>

@property (strong, nonatomic) NSUserDefaults *sharedDefaults;
@property (strong, nonatomic) NSArray *namedBookmarks;
@property (strong, nonatomic) RouteSearchOptions *routeSearchOptions;

@property (strong, nonatomic) NSMutableArray *bookmarkButtons;

//@property (strong, nonatomic) ASABubbleView *bubleView;
@property (nonatomic, strong) KBPopupBubbleView   * bubleView;

@property (nonatomic, strong) UIButton *activeBookmarkButton;
@property (nonatomic, strong) UIButton *bookmarksButton;
@property (nonatomic, strong) UIButton *openRouteButton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation * currentUserLocation;
@property (nonatomic) BOOL userLocationIsAvailable;
@property (nonatomic) BOOL fetchRouteWhenLocationIsKnow;

@property (nonatomic, strong) NSMutableDictionary *bookmarkRouteMap;

@property (nonatomic, strong)WidgetDataManager *widgetDataManager;

@end

@implementation TodayViewController

@synthesize userLocationIsAvailable, fetchRouteWhenLocationIsKnow;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bookmarksScrollView.delegate = self;
    
    isCompactMode = NO;
    firstViewModeChange = YES;
    
    isIOS10 = [self.extensionContext respondsToSelector:@selector(setWidgetLargestAvailableDisplayMode:)];
    if (isIOS10) {
        [self.extensionContext setWidgetLargestAvailableDisplayMode:NCWidgetDisplayModeExpanded];
        isCompactMode = [self.extensionContext widgetActiveDisplayMode] == NCWidgetDisplayModeCompact;
    } else {
        self.preferredContentSize = CGSizeMake(320, 235);
    }
    
    [self readNamedBookmarksFromUserDefaults];
    [self readRouteSearchOptionsFromUserDefaults];
    [self initBookmarkRouteMap];
    
    activityIndicator.circleLayer.lineWidth = 1;
    activityIndicator.circleLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    activityIndicator.hidden = YES;
    
    userLocationIsAvailable = fetchRouteWhenLocationIsKnow = NO;
    
    [self initLocationManager];
    self.widgetDataManager = [[WidgetDataManager alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self readNamedBookmarksFromUserDefaults];
    [self readRouteSearchOptionsFromUserDefaults];
    [self setUpView];
}

-(void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if (activeDisplayMode == NCWidgetDisplayModeCompact)
        self.preferredContentSize = maxSize;
    else
        self.preferredContentSize = CGSizeMake(0, 235);
    
    isCompactMode = activeDisplayMode == NCWidgetDisplayModeCompact;
    [UIView animateWithDuration:firstViewModeChange ? 0 : 0.3 animations:^{
        [self setUpView];
    }];
    
    firstViewModeChange = NO;
}

-(void) dealloc {
    self.locationManager.delegate = nil;
}


- (void)readNamedBookmarksFromUserDefaults {
    self.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManagerBase nsUserDefaultsRoutesExtensionSuitName]];
    NSArray *namedBookmarkDictionaries = [self.sharedDefaults objectForKey:kUserDefaultsNamedBookmarksKey];
    
    NSMutableArray *readNamedBookmarks = [@[] mutableCopy];
    if (namedBookmarkDictionaries) {
        for (NSDictionary *bookmarkDict in namedBookmarkDictionaries) {
            [readNamedBookmarks addObject:[NamedBookmark modelWithDictionary:bookmarkDict]];
        }
        
        self.namedBookmarks = [NSArray arrayWithArray:readNamedBookmarks];
    }
}

- (void)readRouteSearchOptionsFromUserDefaults {
    self.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManagerBase nsUserDefaultsRoutesExtensionSuitName]];
    NSDictionary *routeSearchOptionsDictionary = [self.sharedDefaults objectForKey:kUserDefaultsRouteSearchOptionsKey];
    RouteSearchOptions *options = [RouteSearchOptions modelObjectFromDictionary:routeSearchOptionsDictionary];
    self.routeSearchOptions = options ? options : [RouteSearchOptions defaultOptions];
}

- (void)initBookmarkRouteMap{
    if (!self.bookmarkRouteMap) {
        self.bookmarkRouteMap = [@{} mutableCopy];
    }
}


-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets{
    return UIEdgeInsetsZero;
}

- (UIButton *)bookmarkButtonWithFrame:(CGRect)buttonFrame image:(NSString *)imageName {
    UIButton *bookmarkButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [bookmarkButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [bookmarkButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateDisabled];
    bookmarkButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    bookmarkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    bookmarkButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [bookmarkButton addTarget:self action:@selector(bookmarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bookmarkButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    bookmarkButton.tag = 3131;
    return bookmarkButton;
}

- (UIButton *)openBookmarkButtonWithFrame:(CGRect)buttonFrame {
    UIButton *bookmarkButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [bookmarkButton setImage:[UIImage imageNamed:@"bookmarks-colored-100.png"] forState:UIControlStateNormal];
    [bookmarkButton setImage:[UIImage imageNamed:@"bookmarks-colored-100.png"] forState:UIControlStateDisabled];
    bookmarkButton.tag = 3131;
    [bookmarkButton addTarget:self action:@selector(openBookmarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bookmarkButton setImageEdgeInsets:UIEdgeInsetsMake(13, 13, 13, 13)];
    bookmarkButton.layer.borderColor = [UIColor whiteColor].CGColor;
    bookmarkButton.layer.borderWidth = 1.0f;
    bookmarkButton.layer.cornerRadius = buttonFrame.size.width/2.0;
    return bookmarkButton;
}

- (UILabel *)nameLabelWithFrame:(CGRect)labelFrame andText:(NSString *)labelText {
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.minimumScaleFactor = 0.9;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    nameLabel.text = labelText;
    nameLabel.textColor = isIOS10 ? [UIColor darkTextColor] : [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.tag = 3131;
    return nameLabel;
}

- (void)setUpView{
    //This should be setup in both mode to know the active bookmark button
    [self setupBookmarksScrollView];
    
    NamedBookmark *namedBookmark = [self namedBookmarkForTheCurrentButton];
    if (!namedBookmark) {
        [self showNoBookmarks];
    }
    
    compactModeBookmarkButtonView.hidden = !isCompactMode || !namedBookmark;
    compactModeBookmarkButtonView.backgroundColor = [UIColor clearColor];
    compactModeBookmarkButtonView.clipsToBounds = YES;
    bookmarksScrollView.hidden = isCompactMode;
    if (isCompactMode && self.activeBookmarkButton) {
        detailContainerLeadingConstraint.constant = !namedBookmark ? 15 : 55;
        [self.view layoutIfNeeded];
        
        for (UIView *view in compactModeBookmarkButtonView.subviews) {
            [view removeFromSuperview];
        }
        
        CGRect frame = compactModeBookmarkButtonView.frame;
        self.activeBookmarkButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.width);
        self.activeBookmarkButton.enabled = NO;
        [compactModeBookmarkButtonView addSubview:self.activeBookmarkButton];
        
        CGRect labelFrame = CGRectMake(0, frame.size.width + 5, frame.size.width, 10);
        UILabel *nameLabel = [self nameLabelWithFrame:labelFrame andText:namedBookmark.name];
        [compactModeBookmarkButtonView addSubview:nameLabel];
        self.bubleView.hidden = YES;
    } else {
        detailContainerLeadingConstraint.constant = 15;
        [self.view layoutIfNeeded];
        
        self.activeBookmarkButton.enabled = YES;
    }
    if (namedBookmark) {
        [self updateDetailViewForTheActiveBookmarkButton];
    }
    
    [self configureBubleView];
    [self setScrollViewButtonsStatus];
}

-(void)setupBookmarksScrollView {
    [self.bookmarkButtons removeAllObjects];
    int x = 5;
    int y = 10;
    CGFloat buttonSize = 50;
    CGFloat buttonSpacing = 20;
    CGFloat labelWidth = 60;
    CGFloat labelHeight = 10;
    
    //Remove subViews
    for (UIView *view in bookmarksScrollView.subviews) {
        if (view.tag == 3131) {
            [view removeFromSuperview];
        }
    }
    
    if (self.namedBookmarks.count > 0) {
        for (NamedBookmark *namedBookmark in self.namedBookmarks) {
            UIButton *bookmarkButton = [self bookmarkButtonWithFrame:CGRectMake(x, y, buttonSize, buttonSize) image:namedBookmark.iconPictureName];
            
            [self.bookmarkButtons addObject:bookmarkButton];
            [bookmarksScrollView addSubview:bookmarkButton];
            
            UILabel *nameLabel = [self nameLabelWithFrame:CGRectMake(x-5, y + buttonSize + 4, labelWidth, labelHeight) andText:namedBookmark.name];
            [bookmarksScrollView addSubview:nameLabel];
            
            x += buttonSize + buttonSpacing;
        }
        
        [bookmarksScrollView setContentSize:CGSizeMake(x, bookmarksScrollView.frame.size.height) ];
        [self updateActiveBookmarkFromCache];
    }else{
        [self.openRouteButton removeFromSuperview];
        self.openRouteButton.enabled = NO;
        
        self.bookmarksButton = [self openBookmarkButtonWithFrame:CGRectMake(x, y, buttonSize, buttonSize)];
        
        [bookmarksScrollView addSubview:self.bookmarksButton];
        
        UILabel *nameLabel = [self nameLabelWithFrame:CGRectMake(x-5, y + buttonSize + 4, labelWidth, labelHeight) andText:@"Bookmarks"];
        [bookmarksScrollView addSubview:nameLabel];
    }
}

-(void)updateActiveBookmarkFromCache {
    NSInteger prevSelectedButtonIndex = [self getLastSelectedBookmarkIndexFromCahce];
    self.activeBookmarkButton = self.bookmarkButtons.count > 0 ? self.bookmarkButtons[prevSelectedButtonIndex] : nil;
}

-(void)updateDetailViewForTheActiveBookmarkButton{
    //1. Chech if there is a saved route for the bookmark
    infoLabel.hidden = YES;
    addBookmarkButton.hidden = YES;
    bookmarkNameLabel.hidden = NO;
    
    //Remove previous route view
    for (UIView *view in routeViewScrollView.subviews) {
        if (view.tag == 1001) {
            [view removeFromSuperview];
        }
    }
    
    [self.openRouteButton removeFromSuperview];
    self.openRouteButton.enabled = NO;
    
    NamedBookmark *namedBookmark = [self namedBookmarkForTheCurrentButton];
    if (!namedBookmark) {
        [self showNoBookmarks];
        return;
    }
    
    [self setBubbleArrowPositionForView:self.activeBookmarkButton animated:YES];
    
    bookmarkNameLabel.text = [namedBookmark getFullAddress];
    bookmarkNameLabel.hidden = isCompactMode;
    bookmarkNameLabel.textColor = isIOS10 ? [UIColor darkTextColor] : [UIColor whiteColor];
    routeArriveAtLabel.textColor = isIOS10 ? [UIColor darkTextColor] : [UIColor whiteColor];
    routeMoreDetailLabel.textColor = isIOS10 ? [UIColor darkTextColor] : [UIColor whiteColor];
    routeLeaveAtLabel.textColor = isIOS10 ? [UIColor darkTextColor] : [UIColor whiteColor];
    
    Route *route = [self validRouteForTheActiveBookmarkButton];
    if (route) {
        [activityIndicator endRefreshing];
        UIView *routeView = [self viewForRoute:route longestDuration:[route.routeDurationInSeconds floatValue] width:routeViewScrollView.frame.size.width - 40];
        CGRect frame = routeView.frame;
        frame.origin.y = 0;
        frame.origin.x = 0;
        
        routeView.frame = frame;
        routeView.tag = 1001;
        routeView.alpha = 0.9;
        [routeViewScrollView addSubview:routeView];
//        [routeView asa_growHorizontalAnimationFromZero:0];
        
        [routeViewScrollView setContentSize:CGSizeMake(routeView.frame.size.width, routeView.frame.size.height)];
        CGFloat walkingKm = route.getTotalWalkLength/1000.0;
        
        NSString *numberString = [ReittiStringFormatterE formatRoundedNumberFromDouble:walkingKm roundDigits:2 androundUp:YES];
        if (route.isOnlyWalkingRoute) {
            routeArriveAtLabel.hidden = YES;
            routeMoreDetailLabel.hidden = YES;
            routeLeaveAtLabel.text = [NSString stringWithFormat:@"%@ km walking", numberString];
        }else{
            routeArriveAtLabel.hidden = NO;
            routeMoreDetailLabel.hidden = NO;
            routeLeaveAtLabel.text = [NSString stringWithFormat:@"leave at %@ ", [ReittiStringFormatterE formatHourStringFromDate:route.startingTimeOfRoute]];
            routeArriveAtLabel.text = [NSString stringWithFormat:@"| arrive at %@", [ReittiStringFormatterE formatHourStringFromDate:route.endingTimeOfRoute]];
            routeMoreDetailLabel.text = [NSString stringWithFormat:@"%@ from first stop · %@ km walking",
                                  [ReittiStringFormatterE formatHourStringFromDate:route.timeAtTheFirstStop], numberString];
        }
        
        routeInfoContainerView.backgroundColor = [UIColor clearColor];
        
        routeInfoContainerView.hidden = NO;
        
        [routeInfoContainerView addSubview:self.openRouteButton];
        self.openRouteButton.enabled = YES;
    }else{
        //2. If there is no saved bookmark, fetch new one
        routeInfoContainerView.hidden = YES;
        [activityIndicator beginRefreshing];
        if (userLocationIsAvailable) {
            //Fetch route
            [self fetchRouteForTheActiveBookmarksButton];
            
        }else{
            //Wait for user location to be available and fetch routes from the location manager delegate method
            if ([self isLocationServiceAvailable]) {
                fetchRouteWhenLocationIsKnow = YES;
                userLocationWaitTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timerCallBack:) userInfo:nil repeats:YES];
            }else{
                [activityIndicator endRefreshing];
                infoLabel.hidden = NO;
                infoLabel.text = @"Access to user location is not granted. Please grant access from Settings to get route suggestions.";
            }
            
        }
    }
}

-(void)showNoBookmarks {
    routeInfoContainerView.hidden = YES;
    bookmarkNameLabel.hidden = YES;
    addBookmarkButton.hidden = NO;
    addBookmarkButton.backgroundColor = isIOS10 ? [UIColor colorWithWhite:0.95 alpha:1] : [UIColor colorWithWhite:0.2 alpha:1];
    addBookmarkButton.layer.cornerRadius = 5;
    infoLabel.textColor = isIOS10 ? [UIColor darkTextColor] : [UIColor lightGrayColor];
    infoLabel.hidden = NO;
    
    infoLabel.text = @"No bookmarks created yet.";
    self.activeBookmarkButton = self.bookmarksButton;
    
    [self setBubbleArrowPositionForView:self.bookmarksButton animated:YES];
}

-(Route *)validRouteForTheActiveBookmarkButton{
    NamedBookmark *activeButtonsBookmark = [self namedBookmarkForTheCurrentButton];
    if (!activeButtonsBookmark)
        return nil;
    //TODO: Do more checks before returning
    NSArray *routeArray = [self.bookmarkRouteMap objectForKey:[activeButtonsBookmark getUniqueIdentifier]];
    if (routeArray && routeArray.count > 0) {
        NSMutableArray *routes = [routeArray mutableCopy];
        
        for (int i = 0; i < routes.count;i++) {
            Route *route = [routes objectAtIndex:i];
            
            //Check start location is too far.
            BOOL userHasMoved = NO;
            if (self.currentUserLocation) {
                CLLocation *routeStartLocation = [[CLLocation alloc] initWithLatitude:route.startCoords.latitude longitude:route.startCoords.longitude];
                CLLocationDistance dist = [routeStartLocation distanceFromLocation:self.currentUserLocation];
                userHasMoved = dist > 200;
            }
            
            //TODO: remember thisssssssssssss
            if ([route.startingTimeOfRoute timeIntervalSinceNow] > 0 || userHasMoved){
                //If walking return even if a bit old.
                if (route.isOnlyWalkingRoute && [route.startingTimeOfRoute timeIntervalSinceNow] > -600 && !userHasMoved) {
                    return route;
                }
                [routes removeObject:route];
            }else{
                [self.bookmarkRouteMap setObject:routes forKey:[activeButtonsBookmark getUniqueIdentifier]];
                return route;
            }
            
            if (i == routes.count - 1) {
                return nil;
            }
        }
    }
    
    return nil;
}

-(void)configureBubleView{
    if (isCompactMode) {
        self.bubleView.hidden = YES;
    } else {
        self.bubleView.hidden = NO;
        
        if ( self.bubleView != nil ) {
            [self.bubleView hide:NO];
            self.bubleView = nil;
        }
        
        CGRect bubleFrame = detailContainerView.frame;
        bubleFrame.origin.x = 0;
        bubleFrame.origin.y = 0;
        bubleFrame.size.height = 130;
        
        // Display the new view
        self.bubleView = [[KBPopupBubbleView alloc] initWithFrame:bubleFrame];
        self.bubleView.useDropShadow = NO;
        self.bubleView.useBorders = NO;
        self.bubleView.draggable = NO;
        self.bubleView.alpha = 0.15;
        self.bubleView.cornerRadius = 5;
        self.bubleView.drawableColor = isIOS10? [UIColor darkGrayColor] : [UIColor lightGrayColor];
        [self.bubleView showInView:detailContainerView atIndex:0 animated:NO];
        
        if (self.activeBookmarkButton) {
            [self setBubbleArrowPositionForView:self.activeBookmarkButton animated:NO];
        }
    }
}

- (NSArray *)bookmarkButtons{
    if (!_bookmarkButtons) {
        _bookmarkButtons = [@[] mutableCopy];
    }
    
    return _bookmarkButtons;
}

- (UIButton *)openRouteButton{
    if (!_openRouteButton) {
        _openRouteButton = [[UIButton alloc] initWithFrame:routeInfoContainerView.frame];
        [_openRouteButton addTarget:self action:@selector(openRouteInMainAppButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_openRouteButton setTitle:nil forState:UIControlStateNormal];
    }
    
    return _openRouteButton;
}

//Setup right and left arrow buttons for scrollong the buttons
- (void)setScrollViewButtonsStatus{
    if (isCompactMode) {
        leftScrollViewButton.hidden = YES;
        rightScrollViewButton.hidden = YES;
        return;
    }
    
    CGSize scrollViewContentSize = bookmarksScrollView.contentSize;
    CGRect scrollViewBounds = bookmarksScrollView.bounds;
    
    [rightScrollViewButton setImage:[rightScrollViewButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    rightScrollViewButton.tintColor = isIOS10 ? [UIColor grayColor] : [UIColor lightGrayColor];
    
    [leftScrollViewButton setImage:[leftScrollViewButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    leftScrollViewButton.tintColor = isIOS10 ? [UIColor grayColor] : [UIColor lightGrayColor];
    
    if (scrollViewBounds.origin.x > 5) {
        leftScrollViewButton.hidden = NO;
    }else{
        leftScrollViewButton.hidden = YES;
    }
    
    if (scrollViewContentSize.width > scrollViewBounds.size.width && (scrollViewBounds.origin.x + scrollViewBounds.size.width) != scrollViewContentSize.width) {
        rightScrollViewButton.hidden = NO;
    }else{
        rightScrollViewButton.hidden = YES;
    }
}

- (void)setBubbleArrowPositionForView:(UIView *)view animated:(BOOL)animated{
    CGFloat arrowPosition = 0.5;
    if (view) {
        CGPoint centerInWindow = [view.superview convertPoint:view.center toView:self.view];
        CGPoint pointInBubbleContainerView = [self.view convertPoint:centerInWindow toView:detailContainerView];
        
        if (pointInBubbleContainerView.x < 0) {
            self.bubleView.side = kKBPopupPointerSideLeft;
            arrowPosition = 0.05;
        }else if (pointInBubbleContainerView.x > self.bubleView.frame.size.width){
            self.bubleView.side = kKBPopupPointerSideRight;
            arrowPosition = 0.05;
        }else{
            self.bubleView.side = kKBPopupPointerSideTop;
            /* dont know why substracting 10 below works. It just does */
            arrowPosition = (pointInBubbleContainerView.x - 10)/self.bubleView.frame.size.width;
        }
    }
    
    [self.bubleView setPosition:arrowPosition animated:animated];
}

- (UIView *)viewForRoute:(Route *)route longestDuration:(CGFloat)longestDuration width:(CGFloat)totalWidth
{
    float tWidth  = 70;
    float x = 0;
    UIView *transportsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalWidth , 36)];
    transportsContainer.clipsToBounds = YES;
    transportsContainer.tag = 1987;
    transportsContainer.layer.cornerRadius = 4;
    
    for (RouteLeg *leg in route.routeLegs) {
        if (route.isOnlyWalkingRoute) {
            //Leg duration of a walking leg get freaky sometimes
            tWidth = totalWidth * (([route.routeDurationInSeconds floatValue])/longestDuration);
        }else{
            tWidth = totalWidth * (([leg.legDurationInSeconds floatValue])/longestDuration);
        }
        
        Transport *transportView = [[Transport alloc] initWithRouteLeg:leg andWidth:tWidth - 1 alwaysShowVehicle:NO];
        CGRect frame = transportView.frame;
        transportView.frame = CGRectMake(x, 0, frame.size.width, frame.size.height);
        transportView.clipsToBounds = YES;
        [transportsContainer addSubview:transportView];
        x += frame.size.width + 1;
        
        //Append waiting view if exists
        if (leg.waitingTimeInSeconds > 0 && !route.isOnlyWalkingRoute) {
            float waitingWidth = totalWidth * (leg.waitingTimeInSeconds/longestDuration);
            UIView *waitingView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, waitingWidth, transportView.frame.size.height)];
            waitingView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            waitingView.clipsToBounds = YES;
            if (waitingWidth > 22) {
                UIImageView *waitingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sitting-filled-grey-64.png"]];
                waitingImageView.frame = CGRectMake((waitingView.frame.size.width - 20)/2, (transportsContainer.frame.size.height - 20)/2, 20, 20);
                [waitingView addSubview:waitingImageView];
            }
            [transportsContainer addSubview:waitingView];
            x += waitingWidth;
        }
    }
    transportsContainer.frame = CGRectMake(0, 0, x, 36);
    
    return transportsContainer;
}

- (NamedBookmark *)namedBookmarkForTheCurrentButton {
    if (self.activeBookmarkButton && self.namedBookmarks && self.namedBookmarks.count > 0 && self.bookmarkButtons.count == self.namedBookmarks.count ) {
        NSInteger bookmarkIndex = [self.bookmarkButtons indexOfObject:self.activeBookmarkButton];
        NamedBookmark * bookmark = self.namedBookmarks[bookmarkIndex];
        return bookmark;
    }
    
    return nil;
}

- (void)fetchRouteForTheActiveBookmarksButton{
    
    NamedBookmark *bookmark;
    bookmark = [self namedBookmarkForTheCurrentButton];
    [self.widgetDataManager getRouteForNamedBookmark:bookmark fromLocation:self.currentUserLocation routeOptions:self.routeSearchOptions andCompletionBlock:^(NSArray * response, NSString *errorString){
        infoLabel.hidden = NO;
        if (errorString && !response) {
            infoLabel.text = errorString;
        }else{
            [self.bookmarkRouteMap setValue:response forKey:[bookmark getUniqueIdentifier]];
            [self updateDetailViewForTheActiveBookmarkButton];
        }
        
        [activityIndicator endRefreshing];
    }];
}

- (void)saveLastSelectedBookmarkToCache:(NamedBookmark *)bookmark{
    if (!bookmark)
        return;
    
    NSMutableArray *history = [[self readLastSelectedBookmarksFromCache] mutableCopy];
    if (!history) history = [@[] mutableCopy];
    
    if ([history containsObject:[bookmark getUniqueIdentifier]])
        [history removeObject:[bookmark getUniqueIdentifier]];
    
    [history addObject:[bookmark getUniqueIdentifier]];
    
    [[NSUserDefaults standardUserDefaults] setObject:history forKey:@"previousSelectedBookmark"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSArray *)readLastSelectedBookmarksFromCache {
    id array = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"previousSelectedBookmark"];
    
    if (array && [array isKindOfClass:[NSArray class]]) return array;
    else return @[];
}

- (NSInteger)getLastSelectedBookmarkIndexFromCahce{
    NSArray * history = [[self readLastSelectedBookmarksFromCache] reversedArray];
    if (history.count < 1) return 0;
    //If last one is too close, return second to last.
    
    NSString *bookmarkUniqueName = history[0];
    if (history.count > 1 && self.currentUserLocation) {
        NamedBookmark *bookmark = [self bookmarkWithUniqueIdentifier:bookmarkUniqueName];
        CLLocationCoordinate2D bookmarkCoords = [WidgetHelpers convertStringTo2DCoord:bookmark.coords];
        CLLocation *bookmarkLocation = [[CLLocation alloc] initWithLatitude:bookmarkCoords.latitude longitude:bookmarkCoords.longitude];
        CLLocationDistance dist = [bookmarkLocation distanceFromLocation:self.currentUserLocation];
        
        if (dist < 150) {
            bookmarkUniqueName = history[1];
        }
    }
    
    NSInteger index = [self indexOfBookmark:[self bookmarkWithUniqueIdentifier:bookmarkUniqueName]];
    return index != NSNotFound ? index : 0;
}

-(NamedBookmark *)bookmarkWithUniqueIdentifier:(NSString *)uniqueIdentifier {
    for (int i = 0; i < self.namedBookmarks.count; i++) {
        if ([[self.namedBookmarks[i] getUniqueIdentifier] isEqualToString:uniqueIdentifier]) {
            return self.namedBookmarks[i];
        }
    }
    
    return nil;
}

-(NSInteger )indexOfBookmark:(NamedBookmark *)bookmark {
    if (!bookmark) return NSNotFound;
    
    return [self.namedBookmarks indexOfObject:bookmark];
}

#pragma mark - Action methods
-(void)bookmarkButtonPressed:(id)sender{
    UIButton *bookmarkButton = (UIButton *)sender;
    self.activeBookmarkButton = bookmarkButton;
    
    [bookmarkButton asa_bounceAnimateViewByScale:0.2];
    [self setBubbleArrowPositionForView:bookmarkButton animated:YES];
    [self updateDetailViewForTheActiveBookmarkButton];
    
    NamedBookmark *bookmark = [self namedBookmarkForTheCurrentButton];
    [self saveLastSelectedBookmarkToCache:bookmark];
    
}

- (IBAction)scrollViewButtonsPressed:(id)sender {
    CGRect visibleRect = bookmarksScrollView.bounds;
    if (sender == rightScrollViewButton) {
        visibleRect.origin.x += 70;
    }else{
        visibleRect.origin.x -= 70;
    }
    
    [bookmarksScrollView scrollRectToVisible:visibleRect animated:YES];
    //No need to call this here since it is scrolling animated. Called in the delegate method.
    //    [self setScrollViewButtonsStatus];
}

- (IBAction)addBookmarkButtonPressed:(id)sender {
    UIButton *bookmarkButton = (UIButton *)sender;
    [bookmarkButton asa_bounceAnimateViewByScale:0.2];
    // Open the main app
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?addBookmark", [AppManagerBase mainAppUrl]]];
//    NSURL *url = [NSURL URLWithString:@"CommuterProMainApp://?addBookmark"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (IBAction)openBookmarkButtonPressed:(id)sender {
    UIButton *bookmarkButton = (UIButton *)sender;
    [bookmarkButton asa_bounceAnimateViewByScale:0.2];
    // Open the main app
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?bookmarks", [AppManagerBase mainAppUrl]]];
//    NSURL *url = [NSURL URLWithString:@"CommuterProMainApp://?bookmarks"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (IBAction)openRouteInMainAppButtonPressed:(id)sender{
    NamedBookmark *bookmark = [self namedBookmarkForTheCurrentButton];
    if (bookmark) {
        //Escape space in name
        NSString *urlString = [NSString stringWithFormat:@"%@?routeSearch&%@&%@",[AppManagerBase mainAppUrl], bookmark.name, bookmark.coords];
        if ([urlString respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
            urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }else{
            urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        NSURL *url = [NSURL URLWithString:urlString];
        [self.extensionContext openURL:url completionHandler:nil];
    }
}

- (void)timerCallBack:(id)sender{
    [userLocationWaitTimer invalidate];
    if (fetchRouteWhenLocationIsKnow && self.currentUserLocation == nil) {
        fetchRouteWhenLocationIsKnow = NO;
        [activityIndicator endRefreshing];
        infoLabel.hidden = NO;
        infoLabel.text = @"Current user location cannot be determined. Please try again later.";
    }
}

#pragma mark - location services
- (void)initLocationManager{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
}

-(BOOL)isLocationServiceAvailable{
    BOOL accessGranted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    
    if (!locationServicesEnabled) {
        return NO;
    }
    
    if (!accessGranted) {
        return NO;
    }
    
    return YES;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    self.currentUserLocation = [locations lastObject];
    userLocationIsAvailable = YES;
    
    if (fetchRouteWhenLocationIsKnow) {
        //Fetch Route
        [self setUpView];
        fetchRouteWhenLocationIsKnow = NO;
        [self fetchRouteForTheActiveBookmarksButton];
    }
}

#pragma mark - UIScrolView delegate methods
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self setBubbleArrowPositionForView:self.activeBookmarkButton animated:NO];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self setScrollViewButtonsStatus];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self setScrollViewButtonsStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    [self readNamedBookmarksFromUserDefaults];
    [self readRouteSearchOptionsFromUserDefaults];
    [self setUpView];
    
    completionHandler(NCUpdateResultNewData);
}

@end
