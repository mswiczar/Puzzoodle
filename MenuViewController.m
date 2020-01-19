//
//  MenuViewController.m
//  Puzzoodle
//
//  Created by macmini on 05/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"
#import "PuzzoodleAppDelegate.h"

@implementation MenuViewController

@synthesize amasterView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		PuzzoodleAppDelegate *appDelegate = (PuzzoodleAppDelegate *)[[UIApplication sharedApplication] delegate];
		database = appDelegate.database;
		TheGame=nil;
		isphotoroll=NO;
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}





-(void)ClickOnPuzz1:aobje
{
	if (amasterView==nil)
	{
		amasterView =[[MasterViewController alloc] initWithNibName:@"MainPuzzleWindow" bundle:nil];
	}
		
	if (TheGame!=nil)
	{
		[TheGame release];
		
	}
	isphotoroll=NO;


	TheGame = [[NGame alloc] initWithPrimaryKey:1 database:database];

	amasterView.agame = TheGame;
	[amasterView Begin];
	[self.navigationController pushViewController:amasterView animated:YES];
	
	
}

-(void)ClickOnPuzz2:aobje
{
	if (amasterView==nil)
	{
		amasterView =[[MasterViewController alloc] initWithNibName:@"MainPuzzleWindow" bundle:nil];
	}
	
	if (TheGame!=nil)
	{
		[TheGame release];
	}
	isphotoroll=NO;

	TheGame = [[NGame alloc] initWithPrimaryKey:2 database:database];

	amasterView.agame = TheGame;
	[amasterView Begin];
	[self.navigationController pushViewController:amasterView animated:YES];
	
	
}


-(void)ClickOnPuzz3:aobje
{
	if (amasterView==nil)
	{
		amasterView =[[MasterViewController alloc] initWithNibName:@"MainPuzzleWindow" bundle:nil];
	}
	
	if (TheGame!=nil)
	{
		[TheGame release];
	}
	isphotoroll=NO;

	TheGame = [[NGame alloc] initWithPrimaryKey:3 database:database];
	
	amasterView.agame = TheGame;
	[amasterView Begin];
	[self.navigationController pushViewController:amasterView animated:YES];
	
}

-(void)ClickOnPuzz4:aobje
{
	isphotoroll=YES;

	if ([NGame is_photorrollSelected:database]==NO)
	{
		if (amasterView==nil)
		{
			amasterView =[[MasterViewController alloc] initWithNibName:@"MainPuzzleWindow" bundle:nil];
		}
		if (TheGame!=nil)
		{
			[TheGame release];
		}
		isphotoroll=NO;
		TheGame = [[NGame alloc] initWithPrimaryKey:4 database:database];
		if (TheGame==nil)	
		{
			anavcontrollersource = self.navigationController;
			imagePickerController = [[UIImagePickerController alloc] init];
			imagePickerController.delegate = self;
			imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			imagePickerController.allowsImageEditing=YES;
			[[self navigationController] presentModalViewController:imagePickerController animated:YES];
			
			return;
		}
		else
		{
			amasterView.agame = TheGame;
			[amasterView Begin];
			[self.navigationController pushViewController:amasterView animated:YES];
		}
	}
	else
	{
		anavcontrollersource = self.navigationController;
		imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePickerController.allowsImageEditing=YES;
		[[self navigationController] presentModalViewController:imagePickerController animated:YES];
		
		
	}
	
	
};



- (void)dealloc {
	[super dealloc];
}



- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"image_new.jpg"];
	
	UIImage *orig = [editingInfo objectForKey:UIImagePickerControllerOriginalImage];
	NSData * imageData = UIImageJPEGRepresentation(orig, 1);

	if (imageData != nil) {
		[imageData writeToFile:path atomically:YES];
	}
	

	[NGame createGameindatabase:database picture:@"image_new.jpg"];
	if (amasterView==nil)
	{
		amasterView =[[MasterViewController alloc] initWithNibName:@"MainPuzzleWindow" bundle:nil];
	}
	if (TheGame!=nil)
	{
		[TheGame release];
	}

	TheGame = [[NGame alloc] initWithPrimaryKey:4 database:database];
	
	if (TheGame!=nil) 
	{
		amasterView.agame = TheGame;
		[amasterView Begin];
		[self.navigationController pushViewController:amasterView animated:YES];
		[[imagePickerController parentViewController] dismissModalViewControllerAnimated:YES];
		[imagePickerController release];
	}
	else
	{
		[[imagePickerController parentViewController] dismissModalViewControllerAnimated:YES];
		[imagePickerController release];
		
		
	}
	return;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[[imagePickerController parentViewController] dismissModalViewControllerAnimated:YES];
	[imagePickerController release];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex==0)
	{
		return;
	}

	if (buttonIndex==2)
	{
		[TheGame deleteGame];
	}
	
	amasterView.agame = TheGame;
	[amasterView Begin];
	[self.navigationController pushViewController:amasterView animated:YES];
	if 	(isphotoroll)
	{
		[[imagePickerController parentViewController] dismissModalViewControllerAnimated:YES];
		[imagePickerController release];
	};
	return;
	
}

@end
