//
//  HomeAndWorkRowController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 2/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import "NamedBookmarkE.h"

@protocol HomeAndWorkRowControllerDelegate <NSObject>
-(void)selectedBookmark:(NamedBookmarkE * _Nonnull)bookmark;
-(void)selectedNoneExistingBookmark:(NSString * _Nonnull)bookmarkName;
@end

@interface HomeAndWorkRowController : NSObject

-(void)setUpWithHomeBookmark:(NamedBookmarkE * _Nullable)home andWorkBookmark:(NamedBookmarkE * _Nullable)work;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup * _Nullable homeGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceButton * _Nullable homeButton;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel * _Nullable homeLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup * _Nullable workGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *_Nullable workButton;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel * _Nullable workLabel;

@property (nonatomic, strong)NamedBookmarkE * _Nullable homeBookmark;
@property (nonatomic, strong)NamedBookmarkE * _Nullable workBookmark;

@property (nonatomic, weak)NSObject<HomeAndWorkRowControllerDelegate> * _Nullable delegate;

@end
