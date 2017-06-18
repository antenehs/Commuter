//
//  TodayViewController.m
//  Commuter - Departures
//
//  Created by Anteneh Sahledengel on 30/10/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "BusStop.h"
#import "ReittiStringFormatterE.h"
#import "AppManagerBase.h"
#import "WidgetDataManager.h"
#import "ReittiDateHelper.h"

int kMaxNumberOfStops = 3;

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong)WidgetDataManager *widgetDataManager;

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) NSMutableArray *stopList;
@property (strong, nonatomic) NSDictionary *stopSourceApiMap;
@property (strong, nonatomic) NSString *stopCodesString;
@property (strong, nonatomic, readonly) NSMutableArray *stopCodeList;
@property (strong, nonatomic) NSUserDefaults *sharedDefaults;
//@property (nonatomic) NSInteger totalNumberOfStops;
@property (nonatomic) BOOL thereIsMore;
@property (nonatomic) BOOL cachedMode;
@property (nonatomic) BOOL enoughCatchedDepartures;

@end

@implementation TodayViewController

@synthesize label;
@synthesize stopList, stopSourceApiMap;
@synthesize thereIsMore, cachedMode, enoughCatchedDepartures;
@synthesize stopCodesString;
@synthesize sharedDefaults;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.widgetDataManager = [[WidgetDataManager alloc] init];
    
    isCompactMode = NO;
    
    isIOS10 = [self.extensionContext respondsToSelector:@selector(setWidgetLargestAvailableDisplayMode:)];
    if (isIOS10) {
        [self.extensionContext setWidgetLargestAvailableDisplayMode:NCWidgetDisplayModeExpanded];
        isCompactMode = [self.extensionContext widgetActiveDisplayMode] == NCWidgetDisplayModeCompact;
    }
    
    self.enoughCatchedDepartures = NO;
    [self setUpView];
    
    self.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManagerBase nsUserDefaultsStopsWidgetSuitName]];
    [self fetchSavedStopsFromDefaults];
    
    self.stopList = [self getStopsFromCacheAfterTime:[NSDate date] andStops:self.stopCodeList];
    if (cachedMode) {
        infoLabel.hidden = YES;
    }else{
        if (!self.enoughCatchedDepartures) {
            infoLabel.hidden = NO;
        }else{
            infoLabel.hidden = YES;
        }
    }
    
    [self setUpStopViewsForStops:self.stopList];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self fetchStops];
}

-(void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if (activeDisplayMode == NCWidgetDisplayModeCompact)
        self.preferredContentSize = CGSizeMake(320, 100);
    else
        self.preferredContentSize = CGSizeMake(320, (self.stopList.count*100) + (self.stopList.count == 0 ? 90 : 50) + (thereIsMore || cachedMode || (thereIsMore && enoughCatchedDepartures) ? 44 : 0));
    
    isCompactMode = activeDisplayMode == NCWidgetDisplayModeCompact;
    
    [self setUpStopViewsForStops:self.stopList];
}

-(NSMutableArray *)stopCodeList {
    NSMutableArray *codeList = [[self arrayFromCommaSeparatedString:self.stopCodesString] mutableCopy];
    
    if (codeList.count > kMaxNumberOfStops) {
        [codeList removeObjectsInRange:NSMakeRange(kMaxNumberOfStops, codeList.count - kMaxNumberOfStops)];
    }
    
    return codeList;
}

-(BOOL)thereIsMore {
    NSMutableArray *codeList = [[self arrayFromCommaSeparatedString:self.stopCodesString] mutableCopy];
    
    return codeList.count > kMaxNumberOfStops;
}

- (void)setUpView{
    departuresTable.backgroundColor = [UIColor clearColor];
    routesButton.backgroundColor = [AppManagerBase systemGreenColor];
    routesButton.layer.cornerRadius = 5;
    
    bookmarksButton.backgroundColor = [AppManagerBase systemGreenColor];
    bookmarksButton.layer.cornerRadius = 5;
    
    moreButton = [[UIButton alloc] init];
    [moreButton setTitle:@"more..." forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(openBookmarksButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.titleLabel.font = [UIFont systemFontOfSize:16];
}

- (void)updateContentSizeForTableRows:(int)row{
    if (isCompactMode && self.stopList.count > 0) {
        self.preferredContentSize = CGSizeMake(320, 100);
    } else {
        self.preferredContentSize = CGSizeMake(320, (self.stopList.count*100) + (self.stopList.count == 0 ? 100 : 60) + (self.thereIsMore || cachedMode || (self.thereIsMore && enoughCatchedDepartures) ? 44 : 0));
    }
    
    routeButtonTopConstraint.constant = self.stopList.count == 0 ? 55 : (self.stopList.count * 100) + (self.thereIsMore || cachedMode || (self.thereIsMore && enoughCatchedDepartures) ? 44 : 0) + 20;
    bookmarkButtonTopConstraint.constant = self.stopList.count == 0 ? 55 : (self.stopList.count * 100) + (self.thereIsMore || cachedMode || (self.thereIsMore && enoughCatchedDepartures) ? 44 : 0) + 20;
    
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins {
    return UIEdgeInsetsZero;
}

#pragma mark - main method

-(void)fetchSavedStopsFromDefaults{
    NSLog(@"%@", sharedDefaults);

    stopCodesString = [sharedDefaults objectForKey:kUserDefaultsSavedStopsKey];
    
    self.stopSourceApiMap = [sharedDefaults objectForKey:kUserDefaultsStopSourceApiKey];
    
    [sharedDefaults synchronize];
    
//    NSLog(@"%@",[sharedDefaults dictionaryRepresentation]);
}

-(void)fetchStops{
    
    if ([self.stopCodesString isEqualToString:@""] || self.stopCodesString == nil) {
        infoLabel.text = @"No stops bookmarked";
        [self storeStopsToCache:nil];
        self.stopList = nil;
        cachedMode = NO;
        [self setUpStopViewsForStops:self.stopList];
        infoLabel.hidden = NO;
        
        return;
    }else{
        if (!cachedMode && !enoughCatchedDepartures) {
            infoLabel.text = @"loading saved stops...";
            infoLabel.hidden = NO;
        }else{
            infoLabel.hidden = YES;
        }
    }
    
    if (self.stopCodeList.count != 0 ) {
        if ([[self.stopCodeList firstObject] isEqualToString:@""]) {
            return;
        }
        
        if (self.stopList.count != self.stopCodeList.count) {
            self.stopList = [@[] mutableCopy];
        }
        
        [self fetchStopsForCodes:self.stopCodeList withCompletionHandler:^(NSMutableArray *resultList, NSError *error) {
            if (resultList && resultList.count > 0) {
                self.stopList = resultList;
                cachedMode = NO;
                //                infoLabel.hidden = YES;
                [self storeStopsToCache:self.stopList];
                [self setUpStopViewsForStops:resultList];
                infoLabel.hidden = YES;
                
            }else{
                infoLabel.text = @"Fetching stops failed.";
            }
        }];
    }
}

- (void)fetchStopsForCodes:(NSArray *)codes withCompletionHandler:(ActionBlock)completionHandler {
    __block NSInteger stopsToFetch = codes.count;
    __block NSInteger failedCount = 0;
    NSMutableArray *resultList = [@[] mutableCopy];
    
    for (NSString *stopCode in codes) {
        ReittiApi fetchFrom = [self apiForStopCode:stopCode];
        
        [self.widgetDataManager fetchStopForCode:stopCode fetchFromApi:fetchFrom withCompletionBlock:^(BusStop *stop, NSError *error) {
            stopsToFetch--;
            if (!error && stop) {
                [resultList addObject:stop];
            }else{
                failedCount++;
            }
            
            if (stopsToFetch == 0) {
                [self sortArray:resultList withOrder:codes];
                
                completionHandler(resultList, failedCount > 0 ? @"Stop fetch failed for some stops" : nil);
            }
        }];
    }
}

- (ReittiApi)apiForStopCode:(NSString *)code {
    if (self.stopSourceApiMap && self.stopSourceApiMap[code]) {
        int intVal = [self.stopSourceApiMap[code] intValue];
        @try {
            ReittiApi api = (ReittiApi)intVal;
            if (api != ReittiHSLApi && api != ReittiTREApi && api != ReittiMatkaApi)
                return ReittiHSLApi;
            else
                return api;
        } @catch (NSException *exception) {
            return ReittiHSLApi;
        }
    } else {
        return code.length < 5 ? ReittiTREApi : ReittiHSLApi;
    }
}

-(void)sortArray:(NSMutableArray *)array withOrder:(NSArray *)codes {
    [array sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *firstCode = [(BusStop*)a gtfsId];
        NSString *secondCode = [(BusStop*)b gtfsId];
        
        if (firstCode == nil) {
            return NSOrderedDescending;
        }
        
        //Decending by date - latest to earliest
        return [codes indexOfObject:firstCode] > [codes indexOfObject:secondCode];
    }];
}

#pragma mark - ibactions
- (IBAction)searchRouteButtonClicked:(id)sender {
    // Open the main app
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?routeSearch", [AppManagerBase mainAppUrl]]];
    [self.extensionContext openURL:url completionHandler:nil];
}
- (IBAction)openBookmarksButtonClicked:(id)sender {
    // Open the main app
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?bookmarks", [AppManagerBase mainAppUrl]]];
    [self.extensionContext openURL:url completionHandler:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view == infoLabel) {
        NSURL *url = [NSURL URLWithString:[AppManagerBase mainAppUrl]];
        [self.extensionContext openURL:url completionHandler:nil];
    }
}

#pragma mark - Table view delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@"Number of departures is: %d",self.departures.count);
    
    return [self.stopList count] > 3 ? 3 : [self.stopList count];
    //return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.stopList count] != 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"departuresCell"];
        
        BusStop *stop = [self.stopList objectAtIndex:indexPath.row];
        if (stop) {
            
            @try {
                UIView *lineView = [cell viewWithTag:1000];
                lineView.backgroundColor = isIOS10 ? [UIColor grayColor] : [UIColor lightGrayColor];
                
                UILabel *nameLabel = (UILabel *)[cell viewWithTag:1001];
                nameLabel.text = [NSString stringWithFormat:@"%@ - %@",stop.name,stop.codeShort];
                nameLabel.textColor = isIOS10 ? [UIColor darkTextColor] : [UIColor whiteColor];
                
                UILabel *departuresLabel = (UILabel *)[cell viewWithTag:1002];
                departuresLabel.text = @"No departures in the next 6 hours";
                
                NSMutableDictionary *busNumberDict = [NSMutableDictionary dictionaryWithObject:[AppManagerBase systemGreenColor] forKey:NSForegroundColorAttributeName];
                [busNumberDict setObject:[UIFont systemFontOfSize:18.0] forKey:NSFontAttributeName];
                //TODO: Fix for dark background
                NSDictionary *timeDict = [NSDictionary dictionaryWithObject:[UIColor darkGrayColor] forKey:NSForegroundColorAttributeName];
                
                NSMutableAttributedString *departuresString = [[NSMutableAttributedString alloc] initWithString:@"" attributes: busNumberDict];
                NSMutableAttributedString *tempStr = [NSMutableAttributedString alloc];
                if (stop.departures.count != 0) {
                    for (NSDictionary *departure in stop.departures) {
                        NSString *notParsedCode = [departure objectForKey:@"code"];
                        tempStr = [[NSMutableAttributedString alloc] initWithString:[ReittiStringFormatterE parseBusNumFromLineCode:notParsedCode] attributes:busNumberDict];
                        [departuresString appendAttributedString:tempStr];
                        
                        NSString *notFormattedTime = [NSString stringWithFormat:@"%d" ,[(NSNumber *)[departure objectForKey:@"time"] intValue]];
                        
                        tempStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"/%@   "
                                                                                     ,[ReittiStringFormatterE formatHSLAPITimeToHumanTime:notFormattedTime]] attributes:timeDict];
                        
                        [departuresString appendAttributedString:tempStr];
                    }
                    
                    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
                    [paragrahStyle setLineSpacing:5];
                    [departuresString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [departuresString length])];
                    
                    
                    departuresLabel.attributedText = departuresString;
                }
                
            }
            @catch (NSException *exception) {
                if (self.stopList.count != 0) {
//                    UITableViewCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
//                    infoCell.backgroundColor = [UIColor clearColor];
//                    return infoCell;
//                    UILabel *departuresLabel = (UILabel *)[cell viewWithTag:1002];
                    
                }
            }
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else{
        UITableViewCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
        infoCell.backgroundColor = [UIColor clearColor];
        [infoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return infoCell;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    [moreButton setTitleColor:[AppManagerBase systemGreenColor] forState:UIControlStateNormal];
    if (cachedMode) {
        [moreButton setTitle:@"reloading departures..." forState:UIControlStateNormal];
        moreButton.enabled = NO;
        return moreButton;
    }else if (self.thereIsMore || enoughCatchedDepartures ) {
        [moreButton setTitle:@"more..." forState:UIControlStateNormal];
        moreButton.enabled = YES;
        return moreButton;
    }else
        return nil;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.thereIsMore || cachedMode) {
        return 44;
    }else
        return 0;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateContentSizeForTableRows:3];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Open stop in main app
    BusStop *selected = [self.stopList objectAtIndex:indexPath.row];
    [self openBusStop:selected];
}

-(void)openBusStop:(BusStop *)stop{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://?openStop-%@",[AppManagerBase mainAppUrl], stop.gtfsId]];
    [self.extensionContext openURL:url completionHandler:nil];
}

-(void)setUpStopViewsForStops:(NSArray *)stops{
    [[[firstStopView viewWithTag:1000] layer] setCornerRadius: 5.0];
    [[[secondStopView viewWithTag:1000] layer] setCornerRadius: 5.0];
    [[[thirdStopView viewWithTag:1000] layer] setCornerRadius: 5.0];
    
    firstStopView.hidden = YES;
    secondStopView.hidden = YES;
    thirdStopView.hidden = YES;
    
    [self setUpFooterButton];
    
    NSArray *stopViews = @[firstStopView,secondStopView,thirdStopView,];
    
    if ([self.stopList count] != 0) {
        
        for (int i=0; i<stops.count && i < 3; i++) {
            BusStop *stop = [self.stopList objectAtIndex:i];
            UIView *stopView = [stopViews objectAtIndex:i];
            stopView.hidden = YES;
            if (stop) {
                stopView.hidden = NO;
                UIView *lineView = [stopView viewWithTag:1000];
                lineView.backgroundColor = isIOS10 ? [UIColor lightGrayColor] : [UIColor lightGrayColor];
                lineView.hidden = isCompactMode || i == stops.count - 1;
                
                UILabel *nameLabel = (UILabel *)[stopView viewWithTag:1001];
                nameLabel.text = [NSString stringWithFormat:@"%@ - %@",stop.nameFi,stop.codeShort];
                nameLabel.textColor = isIOS10 ? [UIColor darkTextColor] : [UIColor whiteColor];
                
                UIImageView *stopIconImageView = (UIImageView *)[stopView viewWithTag:1010];
                stopIconImageView.image = [UIImage imageNamed:stop.stopIconName];
                
                UIColor *timeColor = isIOS10 ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
                
                UILabel *departuresLabel = (UILabel *)[stopView viewWithTag:1002];
                departuresLabel.text = @"No departures in the next 6 hours";
                departuresLabel.textColor = timeColor;
                
                UIColor *numberColor = isIOS10 ? [UIColor darkTextColor] : [UIColor whiteColor];
                NSMutableDictionary *busNumberDict = [NSMutableDictionary dictionaryWithObject:numberColor forKey:NSForegroundColorAttributeName];
                [busNumberDict setObject:[UIFont systemFontOfSize:18.0] forKey:NSFontAttributeName];
                
                NSDictionary *timeDict = [NSDictionary dictionaryWithObject:timeColor forKey:NSForegroundColorAttributeName];
                
                NSMutableAttributedString *departuresString = [[NSMutableAttributedString alloc] initWithString:@"" attributes: busNumberDict];
                NSMutableAttributedString *tempStr = [NSMutableAttributedString alloc];
                
                if (![stop.departures isEqual:[NSNull null]]) {
                    @try {
                        if (stop.departures.count != 0){
                            for (StopDeparture *departure in stop.departures) {
                                tempStr = [[NSMutableAttributedString alloc] initWithString:departure.code attributes:busNumberDict];
                                [departuresString appendAttributedString:tempStr];
                                
                                NSString *formattedHour = [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:departure.parsedScheduledDate];
                                
                                tempStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"/%@   " ,formattedHour] attributes:timeDict];
                                
                                [departuresString appendAttributedString:tempStr];
                            }
                            
                            NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
                            [paragrahStyle setLineSpacing:5];
                            [departuresString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [departuresString length])];
                            
                            
                            departuresLabel.attributedText = departuresString;
                        }
                    }
                    @catch (NSException *exception) {
                        NSLog(@"There wa an exception processing departures. %@",exception);
                    }
                }
                
                UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[stopView viewWithTag:1003];
                [indicator stopAnimating];
            }else{
                stopView.hidden = YES;
            }
        }

    }
    
    [self updateContentSizeForTableRows:0];
//    for (int i=0; i<stopViews.count; i++) {
//        i < stops.count ? [[stopViews objectAtIndex:i] setHidden:NO] : [[stopViews objectAtIndex:i] setHidden:YES];
//    }
    
}

-(void)setUpFooterButton{
    if (cachedMode && !enoughCatchedDepartures) {
        [footerButton setTitle:@"reloading departures..." forState:UIControlStateNormal];
        footerButton.enabled = NO;
        footerButton.hidden = NO;
        footerButton.titleLabel.textColor = [AppManagerBase systemGreenColor];
    }else if (self.thereIsMore) {
        [footerButton setTitle:@"more..." forState:UIControlStateNormal];
        footerButton.enabled = YES;
        footerButton.hidden = NO;
        footerButton.titleLabel.textColor = [AppManagerBase systemOrangeColor];
    }else{
        footerButton.hidden = YES;
    }
    
    [footerButton setTitleColor:[AppManagerBase systemGreenColor] forState:UIControlStateNormal];
}

- (IBAction)stopViewSelected:(id)sender {
    UIButton *viewButton = (UIButton *)sender;
    if (viewButton) {
        BusStop *selected;
        if (viewButton == firstViewButton) {
            if (self.stopList.count < 1)
                return;
            selected = [self.stopList objectAtIndex:0];
        }else if (viewButton == secondViewButton) {
            if (self.stopList.count < 2)
                return;
            selected = [self.stopList objectAtIndex:1];
        }else if (viewButton == thirdViewButton) {
            if (self.stopList.count < 3)
                return;
            selected = [self.stopList objectAtIndex:2];
        }else{
            
        }
        
        [self openBusStop:selected];
    }
}


#pragma mark - Helpers

-(NSArray *)arrayFromCommaSeparatedString:(NSString *)csString{
    return [csString componentsSeparatedByString:@","];
}

-(void)storeStopsToCache:(NSArray *)stops{
    @try {
        NSMutableArray *array = [@[] mutableCopy];
        for (BusStop *stop in stops) {
            [array addObject:[stop toDictionary]];
        }
        NSDictionary *myDictionary = [NSDictionary dictionaryWithObject:array forKey:@"stops"];
        [[NSUserDefaults standardUserDefaults] setObject:myDictionary forKey:@"previousStops"];
    }
    @catch (NSException *exception) {
        NSLog(@"Storing history failed");
    }
}

-(NSMutableArray *)getStopsFromCacheAfterTime:(NSDate *)date andStops:(NSArray *)stops{
    
    if (!stops || stops.count == 0 || [stops[0] isEqualToString:@""])
        return [@[] mutableCopy];
    
    NSDictionary * myDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"previousStops"];
    
    BOOL enoughDepartures = YES;
    
    if (myDictionary != nil) {
        NSArray * dictArray = [myDictionary objectForKey:@"stops"];
        
        NSMutableArray *cachedstops = [@[] mutableCopy];
        
        for (NSDictionary *dict in dictArray) {
            BusStop *newStop = [[BusStop alloc] initWithDictionary:dict parseLines:NO];
            
            if (![stops containsObject:newStop.gtfsId])
                continue;
            
            NSMutableArray *fDepartures = [@[] mutableCopy];
            for (StopDeparture *dept in newStop.departures) {
                if (!dept.parsedScheduledDate) continue;
//                NSLog(@"%@",dept);
                if ([date timeIntervalSinceDate:dept.parsedScheduledDate] < 0) {
                    [fDepartures addObject:dept];
                }
            }
            if (fDepartures.count > 0) {
                newStop.departures = fDepartures;
                [cachedstops addObject:newStop];
                if (enoughDepartures) {
                    enoughDepartures = fDepartures.count > 3 ? YES : NO;
                }
            }
            
        }
        if (cachedstops.count > 0) {
            self.enoughCatchedDepartures = enoughDepartures;
            if (enoughDepartures)
                cachedMode = NO;
            else
                cachedMode = YES;
            return cachedstops;
        }else{
            cachedMode = NO;
        }
        
    }
    
    return [@[] mutableCopy];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
