//
//  MasterViewController.h
//  Puzzoodle
//
//  Created by macmini on 12/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "/usr/include/sqlite3.h"
#import "NGame.h"
#import "PuzzleViewController.h"


@interface MasterViewController : UIViewController <UIAlertViewDelegate>
{
	NSMutableArray *thearray;
	sqlite3		   *database;
	NGame		   *agame;
	PuzzleViewController* apuzzleview;
	IBOutlet UIView *aviewmain;
	IBOutlet UIView *aviewmenu;
	BOOL            viewmenu;
	IBOutlet UIView *ahelpview;
	IBOutlet UIImageView *aimageviewHelp;
	NSInteger ahelpid;
	IBOutlet UIButton * adone;
	IBOutlet UIImageView * aimageboard;
	UIActivityIndicatorView*	progressInd;
	UIAlertView *backAlert;
	BOOL displayed;

}

@property (nonatomic,assign) 	NGame * agame;
@property (nonatomic,assign) 	PuzzleViewController* apuzzleview;





-(void)Begin;

@end
