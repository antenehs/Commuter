//
//  ReittiAppShortcutManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/11/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiAppShortcutManager.h"
#import "CoreDataManagers.h"
#import "ASA_Helpers.h"

@interface ReittiAppShortcutManager()

@end

@implementation ReittiAppShortcutManager

+(id)sharedManager{
    static ReittiAppShortcutManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

+(NSString *)shortcutIdentifierStringValue:(ShortcutIdentifier)identifier{
    NSString *result = nil;
    
    switch(identifier) {
        case NamedBookmarkShortcutType:
            result = @"NamedBookmarkShortcutType";
            break;
        case MoreBookmarksShortcutType:
            result = @"MoreBookmarksShortcutType";
            break;
        case AddBookmarkShortcutType:
            result = @"AddBookmarkShortcutType";
            break;
        case UnknownShortcutType:
            result = @"UnknownShortcutType";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return result;
}

+(ShortcutIdentifier)shortcutIdentifierFromString:(NSString *)string{
    
    if ([string isEqualToString:@"NamedBookmarkShortcutType"]) {
        return NamedBookmarkShortcutType;
    }else if ([string isEqualToString:@"MoreBookmarksShortcutType"]) {
        return MoreBookmarksShortcutType;
    }else if ([string isEqualToString:@"AddBookmarkShortcutType"]) {
        return AddBookmarkShortcutType;
    }else{
        return UnknownShortcutType;
    }
}

-(void)updateAppShortcuts{
    
    if(![UIApplicationShortcutItem class])
        return;
    
    NSMutableArray *shortcuts = [@[] mutableCopy];
    
    NSArray *namedBookmarks = [[NamedBookmarkCoreDataManager sharedManager] fetchAllSavedNamedBookmarks];
    
    //TODO: Sort based on closeness to current location
    
    int shortcutCount = 0;
    if (namedBookmarks != nil && namedBookmarks.count > 0) {
        //Add upto 3 shortcuts
        for (NamedBookmark *bookmark in namedBookmarks) {
            if (shortcutCount == 3) {
                break;
            }
            shortcutCount ++;
            
            [shortcuts addObject:[self createShortcutForNamedBookmark:bookmark]];
        }
    }
    
    if (shortcutCount < 3) {
        //Add one shortcut to create a bookmark or bookmark current place
        [shortcuts addObject:[self createShortcutForAddBookmark]];
    }
    
    [shortcuts addObject:[self createShortcutForMoreBookmarks]];
    
    [UIApplication sharedApplication].shortcutItems = [shortcuts reversedArray];
}

-(UIApplicationShortcutItem *)createShortcutForNamedBookmark:(NamedBookmark *)bookmark{
    
    NSString *subtitle = [bookmark.name isEqualToString:bookmark.streetAddress] ? nil : bookmark.streetAddress;
    NSString *iconName = bookmark.monochromeIconName != nil ? bookmark.monochromeIconName : bookmark.iconPictureName;
    
    UIApplicationShortcutIcon * shortcutIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:iconName];
    UIApplicationShortcutItem * shortcutItem = [[UIApplicationShortcutItem alloc] initWithType:[ReittiAppShortcutManager shortcutIdentifierStringValue:NamedBookmarkShortcutType] localizedTitle:bookmark.name localizedSubtitle:subtitle icon:shortcutIcon userInfo: @{@"namedBookmarkName" : bookmark.name , @"namedBookmarkCoords" : bookmark.coords}];
    
    return shortcutItem;
}

-(UIApplicationShortcutItem *)createShortcutForMoreBookmarks{
    UIApplicationShortcutIcon * shortcutIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeBookmark];
    UIApplicationShortcutItem * shortcutItem = [[UIApplicationShortcutItem alloc] initWithType:[ReittiAppShortcutManager shortcutIdentifierStringValue:MoreBookmarksShortcutType] localizedTitle:@"Bookmarks" localizedSubtitle: nil icon:shortcutIcon userInfo: nil];
    
    return shortcutItem;
}

-(UIApplicationShortcutItem *)createShortcutForAddBookmark{
    UIApplicationShortcutIcon * shortcutIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAdd];
    UIApplicationShortcutItem * shortcutItem = [[UIApplicationShortcutItem alloc] initWithType:[ReittiAppShortcutManager shortcutIdentifierStringValue:AddBookmarkShortcutType] localizedTitle:@"Add New Bookmark" localizedSubtitle: nil icon:shortcutIcon userInfo: nil];
    
    return shortcutItem;
}

@end
