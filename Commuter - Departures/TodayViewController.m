//
//  TodayViewController.m
//  Commuter - Departures
//
//  Created by Anteneh Sahledengel on 30/10/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "HSLAPI.h"
#import "BusStopE.h"
#import "ReittiStringFormatterE.h"

@interface TodayViewController () <NCWidgetProviding>

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) NSMutableArray *stopList;

@end

@implementation TodayViewController

@synthesize label;
@synthesize stopList;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.stopList = [self getStopsFromCache];
    self.stopList = [@[] mutableCopy];
    if (stopList.count != 0) {
        [departuresTable reloadData];
        infoLabel.hidden = YES;
    }
    departuresTable.backgroundColor = [UIColor clearColor];
    routesButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    routesButton.layer.borderWidth = 0.5;
    routesButton.layer.cornerRadius = 5;
    
    bookmarksButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    bookmarksButton.layer.borderWidth = 0.5;
    bookmarksButton.layer.cornerRadius = 5;
//    infoLabel.hidden = YES;
    [self updateContentSizeForTableRows:0];
}

//- (void)viewWillAppear:(BOOL)animated{
//    
//}

- (void)updateContentSizeForTableRows:(int)row{
    CGRect tableF = departuresTable.frame;
    departuresTable.frame = CGRectMake(tableF.origin.x, tableF.origin.y, tableF.size.width,  [departuresTable numberOfRowsInSection:0] * departuresTable.rowHeight);
    self.preferredContentSize = CGSizeMake(320, departuresTable.frame.size.height + ([departuresTable numberOfRowsInSection:0] == 0 ? 90 : 50));
    
    routeButtonTopConstraint.constant = [departuresTable numberOfRowsInSection:0] == 0 ? 55 :departuresTable.frame.size.height + 10;
    bookmarkButtonTopConstraint.constant = [departuresTable numberOfRowsInSection:0] == 0 ? 55 :departuresTable.frame.size.height + 10;
    
//    CGRect routeFrame = routesButton.frame;
//    routeFrame.origin.y = [departuresTable numberOfRowsInSection:0] == 0 ? 55 : departuresTable.frame.size.height + 10;
//    routesButton.frame = routeFrame;
//    
//    CGRect bookmarksFrame = bookmarksButton.frame;
//    bookmarksFrame.origin.y = [departuresTable numberOfRowsInSection:0] == 0 ? 55 : departuresTable.frame.size.height + 10;
//    bookmarksButton.frame = bookmarksFrame;
    
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins
{
    margins.bottom = 0.0;
    margins.left = 10.0;
    margins.right = 0.0;
    margins.top = 10.0;
    return margins;
}
#pragma mark - ibactions
- (IBAction)searchRouteButtonClicked:(id)sender {
    // Open the main app
    NSURL *url = [NSURL URLWithString:@"CommuterMainApp://?routeSearch"];
    [self.extensionContext openURL:url completionHandler:nil];
}
- (IBAction)openBookmarksButtonClicked:(id)sender {
    // Open the main app
    NSURL *url = [NSURL URLWithString:@"CommuterMainApp://?bookmarks"];
    [self.extensionContext openURL:url completionHandler:nil];
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
        
        BusStopE *stop = [self.stopList objectAtIndex:indexPath.row];
        if (stop) {
            
            @try {
                UIView *backView = [cell viewWithTag:1000];
                backView.layer.cornerRadius = 5.0;
                
                UILabel *nameLabel = (UILabel *)[cell viewWithTag:1001];
                nameLabel.text = [NSString stringWithFormat:@"%@ - %@",stop.name_fi,stop.code_short];
                
                UILabel *departuresLabel = (UILabel *)[cell viewWithTag:1002];
                
                NSMutableDictionary *busNumberDict = [NSMutableDictionary dictionaryWithObject:[UIColor orangeColor] forKey:NSForegroundColorAttributeName];
                [busNumberDict setObject:[UIFont systemFontOfSize:18.0] forKey:NSFontAttributeName];
                NSDictionary *timeDict = [NSDictionary dictionaryWithObject:[UIColor lightGrayColor] forKey:NSForegroundColorAttributeName];
                
                NSMutableAttributedString *departuresString = [[NSMutableAttributedString alloc] initWithString:@"" attributes: busNumberDict];
                NSMutableAttributedString *tempStr = [NSMutableAttributedString alloc];
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
            @catch (NSException *exception) {
                if (self.stopList.count == 0) {
                    UITableViewCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
                    infoCell.backgroundColor = [UIColor clearColor];
                    return infoCell;
                }
            }
            @finally {
                NSLog(@"finally");
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

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateContentSizeForTableRows:indexPath.row + 1];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Open stop in main app
    BusStopE *selected = [self.stopList objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"CommuterMainApp://?openStop-%d",[selected.code intValue]]];
    [self.extensionContext openURL:url completionHandler:nil];
}

#pragma mark - Helpers

-(NSArray *)arrayFromCommaSeparatedString:(NSString *)csString{
    return [csString componentsSeparatedByString:@","];
}

-(void)storeStopsToCache:(NSArray *)stops{
    @try {
        NSMutableArray *array = [@[] mutableCopy];
        for (BusStopE *stop in stops) {
            [array addObject:[stop toDictionary]];
        }
        NSDictionary *myDictionary = [NSDictionary dictionaryWithObject:array forKey:@"stops"];
        [[NSUserDefaults standardUserDefaults] setObject:myDictionary forKey:@"previousStops"];
    }
    @catch (NSException *exception) {
        NSLog(@"Storing history failed");
    }
}

-(NSMutableArray *)getStopsFromCache{
    NSDictionary * myDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"previousStops"];
    
    if (myDictionary != nil) {
        NSArray * dictArray = [myDictionary objectForKey:@"stops"];
        
        NSMutableArray *stops = [@[] mutableCopy];
        
        for (NSDictionary *dict in dictArray) {
            BusStopE *newStop = [[BusStopE alloc] initWithDictionary:dict];
            [stops addObject:newStop];
        }
        
        return stops;
    }
    
    return [@[] mutableCopy];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ewketApps.commuterDepartures"];
    NSString *stopCodes = [sharedDefaults objectForKey:@"StopCodes"];
    
    [sharedDefaults synchronize];
    
    NSLog(@"%@",[sharedDefaults dictionaryRepresentation]);
    
    if ([stopCodes isEqualToString:@""] || stopCodes == nil) {
        infoLabel.text = @"No stops bookmarked";
//        infoLabel.hidden = NO;
    }else{
        infoLabel.text = @"Reloading departures...";
//        infoLabel.hidden = NO;
    }
    
    HSLAPI *hslAPI = [[HSLAPI alloc] init];
    
    NSArray *stopCodeList = [self arrayFromCommaSeparatedString:stopCodes];
    if (stopCodeList.count != 0) {
        if (self.stopList.count != stopCodeList.count) {
            self.stopList = [@[] mutableCopy];
        }
        
        [hslAPI searchStopForCodes:stopCodeList completionBlock:^(NSMutableArray *resultList, NSError *error) {
            if (!error && resultList != nil) {
//                NSUInteger idx = [self.stopList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
//                    return [[(BusStopE *)obj code] intValue] == [resultStop.code intValue];
//                }];
//                if (idx != NSNotFound)
//                    [self.stopList replaceObjectAtIndex:idx withObject:resultStop];
                
                self.stopList = resultList;
                departuresTable.delegate = self;
                departuresTable.dataSource = self;
                [departuresTable reloadData];
                infoLabel.hidden = YES;
                //                [self updateContentSize];
                //            [self widgetPerformUpdateWithCompletionHandler:nil];
                [self storeStopsToCache:self.stopList];
                completionHandler(NCUpdateResultNewData);
            }else{
                completionHandler(NCUpdateResultNoData);
                infoLabel.text = @"Fetching stops failed.";
            }
        }];
        
    }
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
}

@end
