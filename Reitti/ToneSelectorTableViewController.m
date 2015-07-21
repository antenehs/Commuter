//
//  ToneSelectorTableViewController.m
//  
//
//  Created by Anteneh Sahledengel on 19/7/15.
//
//

#import "ToneSelectorTableViewController.h"
#import "AppManager.h"
#import "AMBlurView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ToneSelectorTableViewController ()

@property (nonatomic, strong)NSMutableArray *dataToLoad;

@end

@implementation ToneSelectorTableViewController

@synthesize checkedIndexPath,selectedTone, soundID;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.dataToLoad = [[NSMutableArray alloc] initWithObjects:UILocalNotificationDefaultSoundName, nil];
    [self.dataToLoad addObjectsFromArray:[AppManager toneNames]];
    
    checkedIndexPath = [self indexPathForTone:self.selectedTone];
    
    [self setTableBackgroundView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataToLoad.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"toneCell" forIndexPath:indexPath];
    
    NSString *toneName = [self.dataToLoad objectAtIndex:indexPath.row];
    if ([toneName isEqualToString:UILocalNotificationDefaultSoundName]) {
        toneName = @"Default iOS sound";
    }
    
    if ([indexPath isEqual:self.checkedIndexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = toneName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedToneName = [self.dataToLoad objectAtIndex:indexPath.row];
    [self.delegate selectedTone:selectedToneName];
    
    if(self.checkedIndexPath && ![self.checkedIndexPath isEqual:indexPath])
    {
        UITableViewCell* uncheckCell = [tableView
                                        cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if([self.checkedIndexPath isEqual:indexPath])
    {
        [self playMp3AudioNamed:selectedTone];
    }
    else
    {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.checkedIndexPath = indexPath;
        [self playMp3AudioNamed:selectedToneName];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Audio related methods
- (void)playMp3AudioNamed:(NSString *)audioName{
    AudioServicesDisposeSystemSoundID(self.soundID);
    
    if ([audioName isEqualToString:UILocalNotificationDefaultSoundName])
        return;
    
    if (audioName == nil)
        return;
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:audioName
                                                              ofType:@"mp3"];
    
    if (soundFilePath == nil)
        return;
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &soundID);
    
    AudioServicesPlayAlertSound(soundID);
}

#pragma mark - Helper methods
- (NSIndexPath *)indexPathForTone:(NSString *)toneName {
    NSIndexPath *indexPathToReturn = nil;
    for (NSInteger i = 0; i < self.dataToLoad.count; i++) {
        if ([[self.dataToLoad objectAtIndex:i] isEqualToString:toneName]) {
            indexPathToReturn = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        }
    }
    
    if (indexPathToReturn == nil) {
        indexPathToReturn = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    return indexPathToReturn;
}

-(void)dealloc{
    AudioServicesDisposeSystemSoundID(self.soundID);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
