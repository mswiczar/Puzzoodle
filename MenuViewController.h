//
//  MenuViewController.h
//  Puzzoodle
//
//  Created by macmini on 05/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#import "/usr/include/sqlite3.h"

#import "NGame.h"


@interface MenuViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIAlertViewDelegate>{
	IBOutlet UIButton* newgame;
	IBOutlet UIButton* resumegame;
	IBOutlet UIButton* playfromphoto;

	IBOutlet UIButton* puzzle1;
	IBOutlet UIButton* puzzle2;
	IBOutlet UIButton* puzzle3;
	
	BOOL isphotoroll;
	MasterViewController *amasterView;
	NGame *TheGame;
	sqlite3  *database;
	UIImagePickerController* imagePickerController;
	UINavigationController * anavcontrollersource;

}

@property (nonatomic,assign)	MasterViewController *amasterView;

@end
