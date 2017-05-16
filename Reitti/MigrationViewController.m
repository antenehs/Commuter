//
//  MigrationViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "MigrationViewController.h"
#import "JTMaterialSpinner.h"
#import "StopCoreDataManager.h"
#import "StopTableViewCell.h"
#import "ASA_Helpers.h"
#import "AppManager.h"
#import "DynamicHeightTableView.h"
#import "RettiDataManager.h"
#import "DigiTransitCommunicator.h"
#import "ASA_Helpers.h"
#import "BusStop.h"
#import "ReittiAnalyticsManager.h"

typedef void(^MigrationCompletionBlock)(NSArray *invalidStops, NSArray *validStops);
typedef void(^SearchCompletionBlock)(NSArray *stops, NSError *error, ReittiApi fetchedFrom);

@interface MigrationViewController ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet JTMaterialSpinner *activitySpinner;
@property (strong, nonatomic) IBOutlet UIView *changeListContainerView;
@property (strong, nonatomic) IBOutlet DynamicHeightTableView *changeListTableView;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topSpaceContraint;

@property (strong, nonatomic) NSArray *oldSavedStops;
@property (strong, nonatomic) RettiDataManager *reittiDataManager;

@property (nonatomic) NSInteger tempRowNumber;

@end

@implementation MigrationViewController

@synthesize titleLabel, iconImageView, activitySpinner, changeListContainerView, changeListTableView, continueButton, topSpaceContraint;
@synthesize oldSavedStops;

+(instancetype)instantiate {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Migration" bundle:nil];
    MigrationViewController *vc = [sb instantiateInitialViewController];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Instantiate singlton just in case.
    [StopCoreDataManager sharedManager];
    
    self.tempRowNumber = 3;
    self.reittiDataManager = [RettiDataManager new];
    
    [changeListTableView registerNib:[UINib nibWithNibName:@"StopTableViewCell" bundle:nil] forCellReuseIdentifier:@"savedStopCell"];
    
    [self setupView];
    [self configureUpdatingView];
}

-(void)viewDidAppear:(BOOL)animated {
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
    
    [self migrateStopToDigiTransitApiWithCompletion:^(NSArray *invalidStops, NSArray *validStops) {
        
        if (invalidStops.count > 0) {
            self.oldSavedStops = invalidStops;
            [self.changeListTableView reloadData];
            
            [self configureShowingListView];
//            [[StopCoreDataManager sharedManager] deleteSavedStops:invalidStops];
            
            if (validStops.count == 0) {
                [[ReittiAnalyticsManager sharedManager] trackEventForEventName:kEventTotalFailStopMigration category:nil value:@1];
            } else {
                [[ReittiAnalyticsManager sharedManager] trackEventForEventName:kEventPartialFailStopMigration category:nil value:[NSNumber numberWithInteger:invalidStops.count]];
            }
            
        } else {
            [self performSelector:@selector(configureDoneView) withObject:nil afterDelay:1];
            [self performSelector:@selector(continueButtonTapped:) withObject:self afterDelay:2];
            
            if (validStops.count == 0) {
                [[ReittiAnalyticsManager sharedManager] trackEventForEventName:kEventNoStopMigrationNeeded category:nil value:@1];
            } else {
                [[ReittiAnalyticsManager sharedManager] trackEventForEventName:kEventSuccessfulStopMigration category:nil value:@1];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)continueButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View methods
-(void)setupView {
    [self.view asa_SetBlurredBackgroundWithImageNamed:nil];
    changeListTableView.backgroundColor = [UIColor clearColor];
    changeListTableView.clipsToBounds = YES;
    
    changeListTableView.layer.cornerRadius = 6.0;
    continueButton.layer.cornerRadius = 10.0;
    
    changeListContainerView.backgroundColor = [UIColor clearColor];
    
    iconImageView.image = [AppManager roundedAppLogoSmall];
    activitySpinner.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    activitySpinner.circleLayer.lineWidth = 2.0;
}

-(void)configureUpdatingView {
    changeListContainerView.hidden = YES;
    continueButton.hidden = YES;
    [activitySpinner beginRefreshing];
    titleLabel.text = @"UPDATING BOOKMARKS";
    topSpaceContraint.constant = (self.view.frame.size.height/2) - 100;
    [self.view layoutIfNeeded];
}

-(void)configureShowingListView {
    changeListContainerView.hidden = YES;
    continueButton.hidden = YES;
    [activitySpinner endRefreshing];
    titleLabel.text = @"UPDATE RESULT";
    topSpaceContraint.constant = 8;
    [self.view asa_springAnimationWithDuration:0.5 animation:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        changeListContainerView.hidden = NO;
        continueButton.hidden = NO;
    }];
}

-(void)configureDoneView {
    changeListContainerView.hidden = YES;
    continueButton.hidden = YES;
    [activitySpinner endRefreshing];
    titleLabel.text = @"DONE!";
    topSpaceContraint.constant = (self.view.frame.size.height/2) - 100;
    [self.view layoutIfNeeded];
}

#pragma mark - table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return oldSavedStops.count;
//    return MIN(self.tempRowNumber, oldSavedStops.count);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
    StopEntity *stopEntity = [self.oldSavedStops objectAtIndex:indexPath.row];
    
    [(StopTableViewCell *)cell setupFromStopEntity:stopEntity];

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - migration
-(void)migrateStopToDigiTransitApiWithCompletion:(MigrationCompletionBlock)completion {
    NSArray *oldStops = [[StopCoreDataManager sharedManager] fetchAllSavedStopsFromCoreData];
    if (oldStops.count < 1) { completion(@[],@[]); }
    
    NSMutableArray *invalidStops = [@[] mutableCopy];
    NSMutableArray *successfulStops = [@[] mutableCopy];
    
    NSArray *possibleStops = [oldStops filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        StopEntity *entity = (StopEntity *)evaluatedObject;
        return !entity.isDigiTransitStop;
    }]];
    
    if (possibleStops.count < 1) { completion(@[],@[]); }
    
    __block NSInteger numberOfStops = 0;
    
    for (StopEntity *stopEntity in possibleStops) {
        numberOfStops ++;
        
        SearchCompletionBlock searchCompletion = ^(NSArray *stops, NSError *error, ReittiApi fetchedFrom){
            if (!error && stops) {
                DigiStop *digiStop = [self matchingStopFrom:stops forStop:stopEntity];
                if (digiStop) {
                    BusStop *busStop = [[BusStop alloc] initFromDigiStop:digiStop];
                    busStop.fetchedFromApi = fetchedFrom;
                    [[StopCoreDataManager sharedManager] deleteSavedStop:stopEntity];
                    [[StopCoreDataManager sharedManager] saveToCoreDataStop:busStop];
                    [successfulStops addObject:stopEntity];
                } else {
                    [invalidStops addObject:stopEntity];
                }
            } else {
                [invalidStops addObject:stopEntity];
            }
            
            numberOfStops--;
            if (numberOfStops == 0) {
                completion(invalidStops, successfulStops);
            }
        };
        
        
        if ((stopEntity.fetchedFromApi == ReittiTREApi) || (stopEntity.fetchedFromApi == ReittiMatkaApi)) {
            [[DigiTransitCommunicator finlandDigiTransitCommunicator] fetchStopsForName:stopEntity.busStopShortCode withCompletionBlock:^(NSArray *stops, NSError *error){
                searchCompletion(stops, error, ReittiDigiTransitApi);
            }];
        } else {
            [[DigiTransitCommunicator hslDigiTransitCommunicator] fetchStopsForName:stopEntity.busStopShortCode withCompletionBlock:^(NSArray *stops, NSError *error){
                searchCompletion(stops, error, ReittiDigiTransitHslApi);
            }];
        }
        
    }
}

-(DigiStop *)matchingStopFrom:(NSArray *)digiStops forStop:(StopEntity *)stopEntity {
    if (!digiStops || digiStops.count == 0) return nil;
    
    NSArray *matches = [digiStops filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        DigiStop *stop = (DigiStop *)evaluatedObject;
        return [self digiStop:stop isEqualToStopEntity:stopEntity];
    }]];
    
    if (matches.count > 1 && stopEntity.fetchedFromApi == ReittiHSLApi) {
        matches = [matches filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DigiStop *stop = (DigiStop *)evaluatedObject;
            return [stop.gtfsId containsString:[stopEntity.busStopCode stringValue]];
        }]];
    }
    
    return matches.count == 1 ? matches[0] : nil;
}

-(BOOL)digiStop:(DigiStop *)digiStop isEqualToStopEntity:(StopEntity *)stopEntity {
    BOOL sameName = [stopEntity.busStopName containsString:digiStop.name];
    BOOL sameShortCode = [digiStop.code isEqualToString:stopEntity.busStopShortCode];
    
    NSArray *digiStopLatComps = [[digiStop.lat stringValue] componentsSeparatedByString:@"."];
    NSString *digiStopLat = (digiStopLatComps && (digiStopLatComps.count > 0 )) ? digiStopLatComps[0] : @"xxx";
    
    NSArray *stopEntityCoordComps = [stopEntity.busStopCoords componentsSeparatedByString:@","];
    NSString *stopEntityLatString = stopEntityCoordComps && stopEntityCoordComps.count > 1 ? stopEntityCoordComps[1] : @"latitude";
    NSArray *stopEntityLatComps = [stopEntityLatString componentsSeparatedByString:@"."];
    NSString *stopEntityLat = stopEntityLatComps && stopEntityLatComps.count > 0 ? stopEntityLatComps[0] : @"yyy";
    
    BOOL sameLat = [digiStopLat isEqualToString:stopEntityLat];
    
    return sameLat && sameName && sameShortCode;
}

-(NSString *)possibleGtfsIdForStopEntity:(StopEntity *)stopEntity {
    if (stopEntity.isDigiTransitStop || !stopEntity.busStopCode) return nil;
    
    if (stopEntity.fetchedFromApi == ReittiTREApi) {
        return [NSString stringWithFormat:@"JOLI:%@", stopEntity.busStopShortCode];
    } else if (stopEntity.fetchedFromApi == ReittiMatkaApi){
        return [NSString stringWithFormat:@"MATKA:%@", stopEntity.busStopShortCode];
    } else {
        return [NSString stringWithFormat:@"HSL:%d", [stopEntity.busStopCode intValue]];
    }
}

@end
