//
//  ReittiAppShortcutManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/11/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    NamedBookmarkShortcutType,
    MoreBookmarksShortcutType,
    AddBookmarkShortcutType,
    UnknownShortcutType
} ShortcutIdentifier;

@interface ReittiAppShortcutManager : NSObject

+(id)sharedManager;
-(id)init;

+(NSString *)shortcutIdentifierStringValue:(ShortcutIdentifier)identifier;
+(ShortcutIdentifier)shortcutIdentifierFromString:(NSString *)string;

-(void)updateAppShortcuts;



@end
