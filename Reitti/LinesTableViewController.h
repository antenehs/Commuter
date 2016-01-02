//
//  LinesTableViewController.h
//  
//
//  Created by Anteneh Sahledengel on 21/6/15.
//
//

#import <UIKit/UIKit.h>
#import "RettiDataManager.h"
#import "JTMaterialSpinner.h"

@interface LinesTableViewController : UITableViewController<UISearchBarDelegate, UIScrollViewDelegate>{
    IBOutlet UISearchBar *addressSearchBar;
    
    IBOutlet UIView *searchBarContainerView;
    IBOutlet JTMaterialSpinner *searchActivityIndicator;
    
    BOOL scrollingShouldResignFirstResponder;
    BOOL tableIsScrolling;
    
    BOOL isSearching;
    
    BOOL linesFromStopsRequested;
    BOOL linesFromNearByStopsRequested;
    
    BOOL wasShowingLineDetail;
    
    NSInteger numberOfSections, linesFromSavedStopsSection, linesFromNearbyStopsSection, searchedLinesSection;
    NSInteger numberOfLinesFromSavedStops, numberOfLinesFromNearbyStops, numberOfSearchedLines;
}


//@property (strong, nonatomic) NSMutableArray * metroLines;
//@property (strong, nonatomic) NSMutableArray * busLines;
//@property (strong, nonatomic) NSMutableArray * ferryLines;
//@property (strong, nonatomic) NSMutableArray * tramLines;
//@property (strong, nonatomic) NSMutableArray * trainLines;
//@property (strong, nonatomic) NSMutableArray * allLines;

@property (strong, nonatomic) NSMutableArray * linesFromSavedStops;
@property (strong, nonatomic) NSMutableArray * linesFromNearStops;
@property (strong, nonatomic) NSMutableArray * searchedLines;

@property (strong, nonatomic) RettiDataManager *reittiDataManager;

@end
