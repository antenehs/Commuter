//
//  LinesTableViewController.m
//  
//
//  Created by Anteneh Sahledengel on 21/6/15.
//
//

#import "LinesTableViewController.h"
#import "AMBlurView.h"
#import "CacheManager.h"
#import "EnumManager.h"
#import "AppManager.h"
#import "LineDetailViewController.h"

@interface LinesTableViewController ()

@end

@implementation LinesTableViewController

@synthesize busLines, trainLines, tramLines, ferryLines, metroLines, allLines;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self setUpMainView];
    
    self.busLines = [[NSMutableArray alloc] init];
    self.ferryLines = [[NSMutableArray alloc] init];
    self.metroLines = [[NSMutableArray alloc] init];
    self.tramLines = [[NSMutableArray alloc] init];
    self.trainLines = [[NSMutableArray alloc] init];
    
    self.allLines = [[CacheManager sharedManager] allInMemoryRouteList];
    
    [self groupLinesByType:allLines];
    
    [self.tableView reloadData];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setTableBackgroundView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - view methods
-(void)setUpMainView{
    [self setTitle:@"Lines"];
    [self setTableBackgroundView];
    
    //Set search bar text color
    for (UIView *subView in addressSearchBar.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                
                //set font color here
                searchBarTextField.textColor = [UIColor whiteColor];
                
                break;
            }
        }
    }
    
    addressSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
}

- (void)setTableBackgroundView {
    UIView *bluredBackViewContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    bluredBackViewContainer.backgroundColor = [UIColor whiteColor];
    UIImageView *mapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_background.png"]];
    mapImageView.frame = bluredBackViewContainer.frame;
    mapImageView.alpha = 0.5;
    AMBlurView *blurView = [[AMBlurView alloc] initWithFrame:bluredBackViewContainer.frame];
    
    [bluredBackViewContainer addSubview:mapImageView];
    [bluredBackViewContainer addSubview:blurView];
    
    self.tableView.backgroundView = bluredBackViewContainer;
    self.tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark - search bar methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //hide segment control
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)thisSearchBar {
    //Show segment control if there is no text in seach field
    if (thisSearchBar.text == nil || [thisSearchBar.text isEqualToString:@""]){
        //List all
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSMutableArray *searched = [self searchForLinesForString:searchText];
    [self groupLinesByType:searched];
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
   
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    switch (section) {
//        case 0:
//            return self.trainLines.count;
//            break;
//            
//        case 1:
//            return self.tramLines.count;
//            break;
//            
//        case 2:
//            return self.metroLines.count;
//            break;
//            
//        case 3:
//            return self.ferryLines.count;
//            break;
//            
//        case 4:
//            return self.busLines.count;
//            break;
//            
//        default:
//            return 0;
//            break;
//    }
    
    return [self dataSourceForSection:section].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lineCell" forIndexPath:indexPath];
    
    StaticRoute *routeForCell;
    
    routeForCell = [[self dataSourceForSection:indexPath.section] objectAtIndex:indexPath.row];
    
    UILabel *numberLabel = (UILabel *)[cell viewWithTag:1001];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1002];
    
//    UIImageView *typeImageView = (UIImageView *)[cell viewWithTag:1003];
    
    numberLabel.text = routeForCell.shortName;
//    numberLabel.textColor = [AppManager colorForLineType:[EnumManager lineTypeForHSLLineTypeId:routeForCell.routeType]];
    numberLabel.textColor = [UIColor darkGrayColor];
    if (indexPath.section == 0) {
        nameLabel.text = [NSString stringWithFormat:@"%@ - %@", routeForCell.lineStart, routeForCell.lineEnd];
    }else
        nameLabel.text = routeForCell.longName;
    
//    typeImageView.image = [AppManager vehicleImageForLineType:[EnumManager lineTypeForHSLLineTypeId:routeForCell.routeType]];
    
    // Configure the cell...
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0 && trainLines.count != 0) {
//        return 30;
//    }else if (section == 1 && tramLines.count != 0){
//        return 30;
//    }else if (section == 2 && metroLines.count != 0){
//        return 30;
//    }else if (section == 3 && ferryLines.count != 0){
//        return 30;
//    }else if (section == 4 && busLines.count != 0){
//        return 30;
//    }
    
    if ([self dataSourceForSection:section].count != 0) {
        return 30;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UIImageView *typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 6, 18, 18)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, self.view.frame.size.width - 60, 30)];
    titleLabel.font = [titleLabel.font fontWithSize:14];
    titleLabel.textColor = [UIColor darkGrayColor];
    if (section == 0) {
        titleLabel.text = @"   TRAIN";
        typeImageView.image = [AppManager vehicleImageForLineType:LineTypeTrain];
    }else if (section == 1){
        titleLabel.text = @"   TRAM";
        typeImageView.image = [AppManager vehicleImageForLineType:LineTypeTram];
    }else if (section == 2){
        titleLabel.text = @"   METRO";
        typeImageView.image = [AppManager vehicleImageForLineType:LineTypeMetro];
    }else if (section == 3){
        titleLabel.text = @"   FERRY";
        typeImageView.image = [AppManager vehicleImageForLineType:LineTypeFerry];
    }else{
        titleLabel.text = @"   BUS";
        typeImageView.image = [AppManager vehicleImageForLineType:LineTypeBus];
    }
    
    [view addSubview:typeImageView];
    [view addSubview:titleLabel];
    
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    return view;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

#pragma mark - scroll view delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == self.tableView)
        [addressSearchBar resignFirstResponder];
}

#pragma mark - helper methods
- (NSMutableArray *)dataSourceForSection:(NSInteger)section{
    switch (section) {
        case 0:
            return self.trainLines;
            break;
            
        case 1:
            return self.tramLines;
            break;
            
        case 2:
            return self.metroLines;
            break;
            
        case 3:
            return self.ferryLines;
            break;
            
        case 4:
            return self.busLines;
            break;
            
        default:
            return allLines;
            break;
    }
}

- (void)groupLinesByType:(NSArray *)lines{
    [self.busLines removeAllObjects];
    [self.ferryLines removeAllObjects];
    [self.metroLines removeAllObjects];
    [self.tramLines removeAllObjects];
    [self.trainLines removeAllObjects];
    
    for (StaticRoute *route in lines) {
        if ([EnumManager lineTypeForHSLLineTypeId:route.routeType] == LineTypeBus) {
            [self.busLines addObject:route];
        }else if ([EnumManager lineTypeForHSLLineTypeId:route.routeType] == LineTypeFerry) {
            [self.ferryLines addObject:route];
        }else if ([EnumManager lineTypeForHSLLineTypeId:route.routeType] == LineTypeMetro) {
            [self.metroLines addObject:route];
        }else if ([EnumManager lineTypeForHSLLineTypeId:route.routeType] == LineTypeTram) {
            [self.tramLines addObject:route];
        }else if ([EnumManager lineTypeForHSLLineTypeId:route.routeType] == LineTypeTrain) {
            [self.trainLines addObject:route];
        }
    }
    
    self.busLines = [self sortRouteArray:self.busLines];
    self.ferryLines = [self sortRouteArray:self.ferryLines];
    self.metroLines = [self sortRouteArray:self.metroLines];
    self.tramLines = [self sortRouteArray:self.tramLines];
    self.trainLines = [self sortRouteArray:self.trainLines];
}

- (NSMutableArray *)sortRouteArray:(NSMutableArray *)array{
    NSArray *sortedArray;
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"shortName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    sortedArray = [array sortedArrayUsingDescriptors:@[sort]];
    
    return [NSMutableArray arrayWithArray:sortedArray];
}

- (NSMutableArray *)searchForLinesForString:(NSString *)key{
    NSMutableArray * searched = [[NSMutableArray alloc] init];
    key = [key lowercaseString];
    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (key == nil || [key isEqualToString:@""]) {
        return self.allLines;
    }
    
    for (StaticRoute *route in self.allLines) {
        if ([[route.shortName lowercaseString] containsString:key]) {
            [searched addObject:route];
        }else if ([[route.longName lowercaseString] containsString:key]) {
            [searched addObject:route];
        }
    }
    
    return searched;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showLineDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        LineDetailViewController * lineDetailViewController = (LineDetailViewController *)[segue destinationViewController];
        
        lineDetailViewController.staticRoute = [[self dataSourceForSection:indexPath.section] objectAtIndex:indexPath.row];
    }
}

@end
