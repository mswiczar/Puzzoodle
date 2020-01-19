//
//  MasterViewController.m
//  Puzzoodle
//
//  Created by macmini on 12/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#define 	PI_OVER_2  1.57079632679489661923f

#import "MasterViewController.h"
#import "PuzzoodleAppDelegate.h"
#import <QuartzCore/QuartzCore.h>  // Needed for animations

#import "NPiece.h"
#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}



@interface MasterViewController (PrivateMethods)

-(void) dispatchFirstTouchAtPoint:(CGPoint)touchPoint forEvent:(UIEvent *)event;
-(void) dispatchTouchEvent:(UIView *)theView toPosition:(CGPoint)position;
 -(void) dispatchTouchEndEvent:(UIView *)theView toPosition:(CGPoint)position;


@end
@implementation MasterViewController
@synthesize agame;
@synthesize apuzzleview;



int moovingNumber;


-(NPiece *)newPieceViewWithImageNamed:(NSString *)imageName atPostion:(CGPoint)centerPoint positionImage:(CGPoint)positionImage
{
	UIImage *image = [UIImage imageNamed:imageName];
	CGRect arect2 = CGRectMake(centerPoint.x, centerPoint.y,  image.size.width,image.size.height);
	CGRect arect = CGRectMake(positionImage.x , positionImage.y , image.size.width, image.size.height);
	
	NPiece *theView = [[NPiece alloc] initWithFrame:arect2];
	CGImageRef myMask = CGImageMaskCreate(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage),
										  CGImageGetBitsPerComponent(image.CGImage), CGImageGetBitsPerPixel(image.CGImage), CGImageGetBytesPerRow(image.CGImage),
										  CGImageGetDataProvider(image.CGImage), NULL, YES);	
	
	CGImageRef imamyMask = CGImageCreateWithImageInRect(agame.Thubmnail.CGImage,arect);
	CGImageRef imamyMask2 = CGImageCreateWithMask(imamyMask, myMask);
	CGImageRelease(imamyMask);
	CGImageRelease(myMask);
	theView.myMaskedImage = imamyMask2;
	
	return theView;
}


- (void)initializeArrayPieces {
	const char *sql = "SELECT id, piecename, posx, posy ,imagex, imagey, click_id,status  FROM main_pieces,games_main where main_pieces.id=games_main.id_main_pieces and games_main.id_game=?";
	sqlite3_stmt *statement;
	CGPoint apoint;
	CGPoint apointInImage;
	NPiece * aimageview;
	NSInteger a=0;
	displayed=NO;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
	{
		sqlite3_bind_int(statement, 1 , agame.primaryKey) ;
		while (sqlite3_step(statement) == SQLITE_ROW) 
		{
			a++;
			apoint.x =sqlite3_column_double(statement, 2);
			apoint.y =sqlite3_column_double(statement, 3);
			apointInImage.x = sqlite3_column_int(statement, 4);
			apointInImage.y =sqlite3_column_int(statement, 5);
			NSString * astr = [NSString stringWithFormat:@"%s",sqlite3_column_text(statement, 1)];
			aimageview = [self newPieceViewWithImageNamed:astr atPostion:apoint positionImage:apointInImage];
			aimageview.piecenumber =sqlite3_column_int(statement, 0);
			aimageview.orientation =3;
			aimageview.pieceClick = sqlite3_column_int(statement, 0);
			CGAffineTransform transform = CGAffineTransformMakeRotation(PI_OVER_2 * aimageview.orientation);
			aimageview.transform = transform;
			aimageview.is_okMaster =sqlite3_column_int(statement, 7);
			aimageview.alpha =sqlite3_column_int(statement, 7);
//			aimageview.alpha =0.9;
			aimageview.is_master=YES;
			[self.view addSubview:aimageview];
			
			aimageview.center=apoint;
			[thearray addObject:aimageview];
			[aimageview release];
		}
		sqlite3_finalize(statement);
    } 
	else 
	{
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		PuzzoodleAppDelegate *appDelegate = (PuzzoodleAppDelegate *)[[UIApplication sharedApplication] delegate];
		database = appDelegate.database;
		[self.view addSubview:aviewmenu];

		CGRect adid;
		adid =  aviewmenu.frame;
		adid.origin.x= 330;
		aviewmenu.frame = adid;
		
		progressInd = [[UIActivityIndicatorView alloc] init];
		progressInd.hidesWhenStopped = YES;
		progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		[progressInd sizeToFit];
		progressInd.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
										UIViewAutoresizingFlexibleRightMargin |
										UIViewAutoresizingFlexibleTopMargin |
										UIViewAutoresizingFlexibleBottomMargin);
		
		backAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Saving", @"")
											   message:NSLocalizedString(@"Please wait", @"")
											  delegate:nil 
									 cancelButtonTitle:nil
									 otherButtonTitles:nil];
		
		progressInd.center = CGPointMake(backAlert.frame.size.width / 2.0, -5.0);
		[backAlert addSubview:progressInd];
		
		
		
	}
	return self;
}

-(void)Begin
{

	if (thearray !=nil)
	{
		[thearray removeAllObjects];
	
		[thearray release];
	}
	thearray = [[NSMutableArray alloc] init];
	if ( agame.orientation==NO)
	{
//		aimageboard.image= [UIImage imageNamed:@"lboardmaster.png"];
		aimageboard.image= [UIImage imageNamed:@"boardmaster.jpg"];

	}
	else
	{
		aimageboard.image= [UIImage imageNamed:@"boardmaster.jpg"];
	}

	[self initializeArrayPieces];
}

- (void)viewDidAppear:(BOOL)animated
{
	NPiece *firstPieceView;
	NSUInteger atotal = [thearray count];
	for (NSUInteger i=0 ; i< atotal; i++) 
	{
		firstPieceView = (NPiece *) [thearray objectAtIndex:i];	
//		[ firstPieceView setNeedsDisplay];
	};

}


- (void)viewWillAppear:(BOOL)animated
{
	NSUInteger atotal = [thearray count];
	NPiece *firstPieceView;
	BOOL todook =YES;
	for (NSUInteger i=0 ; i< atotal; i++) 
	{
		firstPieceView = (NPiece *) [thearray objectAtIndex:i];	
		if (firstPieceView.is_okMaster==YES)
		{
			firstPieceView.alpha =1;
		}
		else
		{
			todook= NO;
		}
		//[ firstPieceView setNeedsDisplay];
	}
	if((todook) && (displayed==NO))
	{
		displayed = YES;
		adone.alpha = 0;
		CGRect aframe = [adone frame];
		aframe.origin.x = 80;
		aframe.origin.y = 130;
		adone.frame = aframe;
		[self.view addSubview:adone];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:2];
		adone.alpha = 1;
		[UIView commitAnimations];
		
	}
	
}

- (void)viewWillDisappear:(BOOL)animated
{

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}


- (void)dealloc {
	[apuzzleview release];
	[super dealloc];
}

-(void)clickstart:aobj
{

}



-(void)clickHint:aobj
{
	viewmenu=YES;
	CGRect adid;
	adid =  aviewmenu.frame;
	adid.origin.x= 330;
	aviewmenu.frame = adid;
	[aviewmenu removeFromSuperview];
	[self.view addSubview:aviewmenu];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.8];
	
	adid =  aviewmenu.frame;
	adid.origin.x =0; 
	aviewmenu.frame = adid;
	adone.alpha = 0;

	[UIView commitAnimations];

}
-(void)clickcancel:aobj
{
	CGRect adid;
	adid =  aviewmenu.frame;
	adid.origin.x =330; 
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.8];
	aviewmenu.frame = adid;
	adone.alpha = 0;

	[UIView commitAnimations];
	viewmenu=NO;
	
}



-(void)workOnBackground:(BOOL)background
{
	self.view.userInteractionEnabled = !background;
	if (background)
	{
		[backAlert show];
		[progressInd startAnimating];
	}
	else
	{
		[progressInd stopAnimating];
		[backAlert dismissWithClickedButtonIndex:0 animated:YES];
	}
}


-(void)saving:aobj
{
	NSAutoreleasePool	 *autoreleasepool = [[NSAutoreleasePool alloc] init];
	UIImageWriteToSavedPhotosAlbum(agame.ImageShowMini	, nil, nil, nil);
	sleep(2);	
	[self workOnBackground:NO];
	[self clickcancel:nil];
	[autoreleasepool release];
}


-(void)ClickSave:aobj
{
	
	if (agame.primaryKey !=4)
	{
		[self workOnBackground:YES];
		[self performSelectorInBackground:@selector(saving:)  withObject:nil];
	}
	else
	{
		[self clickcancel:nil];
	}
}

-(void)ClickPiece:aobj
{
	NPiece * abuton = (NPiece *)aobj;

//	if (abuton.is_okMaster)
//		return;
	
	if (apuzzleview ==nil) 
	{
		apuzzleview = [[PuzzleViewController alloc] initWithNibName:@"PuzzleWindow" bundle:nil];
	}
	else
	{
		[apuzzleview ClearAll];
	}

	apuzzleview.agame = agame;
	CGPoint  apoint;
	int resultadox;
	int resultadoy;	

	NSInteger aint = abuton.pieceClick;

	if ( agame.orientation)
	{
		resultadoy = ((aint-1)% 5);
		resultadox = ((aint-1) /  5);
		
		apoint.y =resultadox * 300 ;
		apoint.x = resultadoy * 320 ;
	}
	else
	{
		resultadoy = ((aint-1)% 5);
		resultadox = ((aint-1) /  5);
		
		apoint.y =resultadox * 320 ;
		apoint.x = resultadoy * 300 ;
		
	}
	apuzzleview.startPoint = apoint;
	apuzzleview.Minipiece = abuton;
	apuzzleview.thearrayMaster = thearray;
	[apuzzleview BeginwithImage:agame.ImageGame];

	[self.navigationController pushViewController:apuzzleview animated:YES];
	return;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSUInteger touchCount = 0;
	for (UITouch *touch in touches) {
		[self dispatchFirstTouchAtPoint:[touch locationInView:self.view] forEvent:nil];
		touchCount++;  
	}	
}


-(void) dispatchFirstTouchAtPoint:(CGPoint)touchPoint forEvent:(UIEvent *)event
{
	 if (viewmenu)
	 {
		 return;
	 }

	NSUInteger atotal = [thearray count];
	NPiece *firstPieceView;
	for (NSUInteger i=0 ; i< atotal; i++) 
	{
		firstPieceView = (NPiece *) [thearray objectAtIndex:i];	
		
		CGRect arectangulo =[firstPieceView frame];
		arectangulo.origin.x =arectangulo.origin.x+10;
		arectangulo.origin.y =arectangulo.origin.y+10;

		arectangulo.size.width =arectangulo.size.width-10;
		arectangulo.size.height =arectangulo.size.height-10;

		if (CGRectContainsPoint(arectangulo, touchPoint)) 
		{
			[self ClickPiece:firstPieceView]; 
			break;
		}
	}
}

-(void)clickweb:aobj
{
	NSString *ccURL = [NSString stringWithString:@"http://www.puzzoodle.com/"];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:ccURL]];
}


-(void)clickhelp:aobj
{
	ahelpid=1;
	aimageviewHelp.image = [UIImage imageNamed:@"Help1.png"];

	[self.view addSubview:ahelpview];
	
}

-(void)clickmain:aobj
{
	NSUInteger atotal = [thearray count];
	NPiece *firstPieceView;
	for (NSUInteger i=0 ; i< atotal; i++) 
	{
		firstPieceView = (NPiece *) [thearray objectAtIndex:i];
		[firstPieceView  removeFromSuperview];
	}
	[thearray removeAllObjects];
	[aviewmenu removeFromSuperview];
	[apuzzleview ClearAll];
	apuzzleview=nil;
	[self.navigationController popViewControllerAnimated:YES];
	viewmenu=NO;
}

/// new stuff question stuff

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex==1)
	{
		[NGame createGameindatabase:database picture:@"none"];
		[self.agame deleteGame]; 
		sleep(1);
		exit(0);
	}
}


- (void)alertOKCancelAction
{
	// open a alert with an OK and cancel button
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Puzzoodle" message:@"Resetting the Photo puzzle will close Puzzoodle - Do you want to exit?"
												   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Exit", nil];
	[alert show];
	[alert release];
}



-(void)adeletegame:aobj
{
	if (agame.primaryKey ==4)
	{
		[self alertOKCancelAction];

	//	exit(1);
	}
	else
	{
		[self.agame deleteGame]; 
		adone.alpha = 0;
		[adone setNeedsDisplay];
		NSUInteger atotal = [thearray count];
		NPiece *firstPieceView;
		for (NSUInteger i=0 ; i< atotal; i++) 
		{
			firstPieceView = (NPiece *) [thearray objectAtIndex:i];
			[firstPieceView  removeFromSuperview];
		}
		[thearray removeAllObjects];
		[self initializeArrayPieces];
		[self clickcancel:nil];
	}
	
}

-(void)clicknew:aobj
{
	[self adeletegame:nil];
}




-(void)cancelHelp:aobj
{
	[ahelpview removeFromSuperview];

}

-(void)nextHelp:aobj
{
	NSString* Imagstring;
	if 	(ahelpid<4)
	{
		ahelpid=ahelpid+1;
		switch (ahelpid)
		{
			case 1:
				Imagstring = @"Help1.png";
				break;
			case 2:
				Imagstring = @"Help2.png";
				break;
			case 3:
				Imagstring = @"Help3.png";
				break;
			case 4:
				Imagstring = @"Help4.png";
				break;
		}
		aimageviewHelp.image = [UIImage imageNamed:Imagstring];
	}

}

-(void)prevHelp:aobj
{
	NSString* Imagstring;

	if 	(ahelpid>1)
	{
		ahelpid=ahelpid-1;
		switch (ahelpid)
		{
		case 1:
			Imagstring = @"Help1.png";
			break;
		case 2:
			Imagstring = @"Help2.png";
			break;
		case 3:
			Imagstring = @"Help3.png";
			break;
		case 4:
			Imagstring = @"Help4.png";
			break;
		}
		aimageviewHelp.image = [UIImage imageNamed:Imagstring];
	}
}

-(void)waiting:aobj
{
	sleep(2);	
	[adone removeFromSuperview];

}

-(void)clickdones:aobj
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:2];
	adone.alpha = 0;
	[UIView commitAnimations];
	[self performSelectorInBackground:@selector(waiting:)  withObject:nil];
}





@end
