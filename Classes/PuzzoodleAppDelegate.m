//
//  PuzzoodleAppDelegate.m
//  Puzzoodle
//
//  Created by macmini on 05/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "PuzzoodleAppDelegate.h"
#import "NGame.h"

#define SQLDATABASENAME @"puzzoodle.sql"

@implementation PuzzoodleAppDelegate

@synthesize window;
@synthesize database;
@synthesize mynavcontroller;

- (void)createEditableCopyOfDatabaseIfNeeded 
{
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:SQLDATABASENAME];
	success = [fileManager fileExistsAtPath:writableDBPath];
	if (success) return;
	// The writable database does not exist, so copy the default to the appropriate location.
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:SQLDATABASENAME];
	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	if (!success) 
	{
		NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
	}
}


- (void)initializeDatabase
{
	// The database is stored in the application bundle. 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:SQLDATABASENAME];
	// Open the database. The database was prepared outside the application.
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
	{
	} 
	else 
	{
		// Even though the open failed, call close to properly clean up resources.
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		// Additional error handling, as appropriate...
	}
}


-(void)startdatabase
{
	[self createEditableCopyOfDatabaseIfNeeded];
	[self initializeDatabase];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	
	[self startdatabase];
	[application setStatusBarHidden:YES animated:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self.window makeKeyAndVisible];
	myMenuViewController = [[MenuViewController alloc] initWithNibName:@"MenuWindow" bundle:nil];
	self.mynavcontroller = [[UINavigationController alloc]initWithRootViewController:myMenuViewController];
	self.mynavcontroller.navigationBarHidden=YES;
	[self.window addSubview:self.mynavcontroller.view];
	[myMenuViewController.view setBackgroundColor:[UIColor clearColor]];
//	[[UIApplication sharedApplication]setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated:NO];

}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	
	if (myMenuViewController.amasterView.apuzzleview.saved==NO)
	{
		[myMenuViewController.amasterView.apuzzleview SavePiecesPosition];
	};

	[NGame finalizeStatements];
	if (sqlite3_close(database) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
	}
	
}


- (void)dealloc {
	[window release];
	[super dealloc];
}




 
 
 
 
 
 
 
 
 


@end
