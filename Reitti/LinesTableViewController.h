//
//  LinesTableViewController.h
//  
//
//  Created by Anteneh Sahledengel on 21/6/15.
//
//

#import <UIKit/UIKit.h>

@interface LinesTableViewController : UITableViewController<UISearchBarDelegate, UIScrollViewDelegate>{
    IBOutlet UISearchBar *addressSearchBar;
    BOOL scrollingShouldResignFirstResponder;
    BOOL tableIsScrolling;
}


@property (strong, nonatomic) NSMutableArray * metroLines;
@property (strong, nonatomic) NSMutableArray * busLines;
@property (strong, nonatomic) NSMutableArray * ferryLines;
@property (strong, nonatomic) NSMutableArray * tramLines;
@property (strong, nonatomic) NSMutableArray * trainLines;
@property (strong, nonatomic) NSMutableArray * allLines;

@end
