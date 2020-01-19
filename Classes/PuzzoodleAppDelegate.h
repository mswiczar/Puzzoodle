//
//  PuzzoodleAppDelegate.h
//  Puzzoodle
//
//  Created by macmini on 05/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "/usr/include/sqlite3.h"
#import "MenuViewController.h"

@class PuzzoodleViewController;

@interface PuzzoodleAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	MenuViewController *myMenuViewController;
	UINavigationController *mynavcontroller;
	sqlite3 *database;
	
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic) sqlite3 *database;
@property (nonatomic, retain) UINavigationController *mynavcontroller;


@end

