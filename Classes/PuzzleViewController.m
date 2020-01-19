#import "PuzzleViewController.h"
#import "PuzzoodleAppDelegate.h"

#import <QuartzCore/QuartzCore.h>  // Needed for animations

#define 	PI_OVER_2  1.57079632679489661923f


@interface PuzzleViewController()
 @property (nonatomic) BOOL piecesOnTop;  
@property (nonatomic) CGPoint startTouchPosition;

@end

int thearrayMasternext[21];

@interface PuzzleViewController (PrivateMethods)
-(NPiece *)newPieceViewWithImageNamed:(NSString *)imageName atPostion:(CGPoint)centerPoint positionImage:(CGPoint)positionImage;

-(void)animateFirstTouchAtPoint:(CGPoint)touchPoint forView:(NPiece *)theView;
-(void)animateView:(NPiece *)theView toPosition:(CGPoint) thePosition;
-(void) dispatchFirstTouchAtPoint:(CGPoint)touchPoint forEvent:(UIEvent *)event;
-(void) dispatchTouchEvent:(UIView *)theView toPosition:(CGPoint)position;
-(void) dispatchTouchEndEvent:(UIView *)theView toPosition:(CGPoint)position;
- (void)rotateFirstTouchAtPoint:(CGPoint)touchPoint forView:(NPiece *)theView;
-(BOOL)isokpiece:(NPiece*)firstPieceView;

@end


@implementation PuzzleViewController

#define GROW_ANIMATION_DURATION_SECONDS 0.15    // Determines how fast a piece size grows when it is moved.
#define SHRINK_ANIMATION_DURATION_SECONDS 0.15  // Determines how fast a piece size shrinks when a piece stops moving.

@synthesize piecesOnTop;
@synthesize startTouchPosition;
@synthesize agame;
@synthesize  startPoint;
@synthesize Minipiece;
@synthesize saved;
@synthesize thearrayMaster;
@synthesize  actual;


-(void) SavePiecesPosition
{
	
	sqlite3_stmt *statement;
	const char *sql2 = "update  games_pieces  set posx =? , posy = ? , orientation = ? , status= ?  where id_main_piece = ? and game_id = ? and id_pieces=?";
	if (sqlite3_prepare_v2(database, sql2, -1, &statement, NULL) == SQLITE_OK) 
	{
		NSInteger atotal = [thearray count];
		NPiece *firstPieceView;
		for (NSInteger i=0 ; i< atotal; i++) 
		{
			firstPieceView = (NPiece *) [thearray objectAtIndex:i];	

			sqlite3_bind_double(statement, 1 ,firstPieceView.center.x);
			sqlite3_bind_double(statement, 2 , firstPieceView.center.y);
			sqlite3_bind_int(statement, 3 ,firstPieceView.orientation);
			if (firstPieceView.is_ok ==YES)
			{
				sqlite3_bind_int(statement, 4 ,1);
			}else
			{
				sqlite3_bind_int(statement, 4 ,0);
			}

			sqlite3_bind_int(statement, 5 ,Minipiece.piecenumber);
			sqlite3_bind_int(statement, 6 ,agame.primaryKey);
			sqlite3_bind_int(statement, 7 ,firstPieceView.piecenumber);
	
			if (sqlite3_step(statement) == SQLITE_ROW) 
			{
			}
			else
			{
				
			}
			sqlite3_reset(statement);

		}
	}
	sqlite3_finalize(statement);
	if ([self isok])
	{
		[self.agame saveMainPiece:Minipiece.piecenumber status:1];
		self.Minipiece.is_okMaster =YES;
	};
	
}






- (void)initializeArrayPieces {
	

	const char *sql = "SELECT pieces.id,piecename,offsetx, offsety , games_pieces.posx , games_pieces.posy , orientation, solved_pieces.posx , solved_pieces.posy FROM pieces , games_pieces , solved_pieces where pieces.id = games_pieces.id_pieces and solved_pieces.piece_id = pieces.id and games_pieces.game_id =? and id_main_piece =? order by status desc";	
	sqlite3_stmt *statement;
	CGPoint apoint;
	CGPoint apointInImage;
	srand ( time(NULL) );
	CGPoint apointresult;
	NPiece * aimageview;
	NSInteger a=0;
	double r;
	double z;
	double x;
	double y;

	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
	{
		sqlite3_bind_int(statement, 1 ,agame.primaryKey);
		sqlite3_bind_int(statement, 2 ,Minipiece.piecenumber);
		while (sqlite3_step(statement) == SQLITE_ROW) 
		{
			a++;
			apoint.x =sqlite3_column_double(statement, 4);
			apoint.y =sqlite3_column_double(statement, 5);
			
			apointInImage.x = sqlite3_column_int(statement, 2);
			apointInImage.y =sqlite3_column_int(statement, 3);
			
			NSString * astr = [NSString stringWithFormat:@"%s",sqlite3_column_text(statement, 1)];
			
			aimageview = [self newPieceViewWithImageNamed:astr atPostion:apoint positionImage:apointInImage];
			aimageview.piecenumber =sqlite3_column_int(statement, 0);

			apointresult.x = sqlite3_column_int(statement, 7);
			apointresult.y =sqlite3_column_int(statement, 8);
			aimageview.posxyFixed = apointresult;
			
			if ((apoint.x ==0  ) && (apoint.x ==0  ) ) 
			{
				
				r = (   (double)rand() / ((double)(RAND_MAX)+(double)(1)) );
				z = (r * 4);
				aimageview.orientation =(int) z;
				r = (   (double)rand() / ((double)(RAND_MAX)+(double)(1)) );

				x = (r * 200);
				r = (   (double)rand() / ((double)(RAND_MAX)+(double)(1)) );

				y = (r * 300);
				apoint.x = x+50;
				apoint.y = y+50;
			}
			else
			{
				aimageview.orientation =sqlite3_column_int(statement, 6);
			}
			CGAffineTransform transform = CGAffineTransformMakeRotation(PI_OVER_2 * aimageview.orientation);
			aimageview.transform = transform;
			
			[thearray addObject:aimageview];
			[panel addSubview:aimageview];
			aimageview.center = apoint;
			[self isokpiece:aimageview];

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





#pragma mark -
#pragma mark === Setting up and tearing down ===
#pragma mark

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
	/*
		//		thearrayMasternext[3]=3;
		thearrayMasternext = [NSArray arrayWithObjects:@"10",@"1",@"2",@"3",@"4",
														@"15",@"6",@"7",@"8",@"9",
														@"20", @"11",@"12",@"13",@"14",  
														@"5",@"16",@"17",@"18",@"19", nil];
	 */
		thearrayMasternext[1]=10;
		thearrayMasternext[2]=1;
		thearrayMasternext[3]=2;
		thearrayMasternext[4]=3;
		thearrayMasternext[5]=4;

		thearrayMasternext[6]=15;
		thearrayMasternext[7]=6;
		thearrayMasternext[8]=7;
		thearrayMasternext[9]=8;
		thearrayMasternext[10]=9;

		
		thearrayMasternext[11]=20;
		thearrayMasternext[12]=11;
		thearrayMasternext[13]=12;
		thearrayMasternext[14]=13;
		thearrayMasternext[15]=14;
		
		thearrayMasternext[16]=5;
		thearrayMasternext[17]=16;
		thearrayMasternext[18]=17;
		thearrayMasternext[19]=18;
		thearrayMasternext[20]=19;
		
		
		PuzzoodleAppDelegate *appDelegate = (PuzzoodleAppDelegate *)[[UIApplication sharedApplication] delegate];
		database = appDelegate.database;
		moovingNumber =-1;
		mustRotate = NO;
		startPoint.x=0;
		startPoint.y=0;
		thearray = [[NSMutableArray alloc] init];
		[self.view addSubview:amenu];
		buttonNext.alpha=0;

		saved=NO;
	}
	return self;
}


-(void)BeginwithImage:(UIImage*)imagename
{
	buttonNext.alpha=0;

	CGRect adid;
	adid =  amenu.frame;
	adid.origin.x= 330;
	amenu.frame = adid;
	aimagePuzzle = imagename;
	CGRect arect;
	if (agame.orientation)
	{
		arect = CGRectMake( startPoint.x, startPoint.y, 320, 300);
	}
	else
	{
		arect = CGRectMake( startPoint.x, startPoint.y, 320, 300);
	}
	ahelperImageSource = CGImageCreateWithImageInRect(aimagePuzzle.CGImage,arect);
	helpimage = [[UIImage alloc] initWithCGImage:ahelperImageSource];
	CGImageRelease(ahelperImageSource);
	[self initializeArrayPieces];
	saved=NO;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


-(void)ClearAll
{
	NSInteger atotal = [thearray count];
	NPiece *firstPieceView;
	for (NSInteger i=0 ; i< atotal; i++) 
	{
		firstPieceView = (NPiece *) [thearray objectAtIndex:i];
		[firstPieceView  removeFromSuperview];
	}
	[thearray removeAllObjects];
	[helpimage release];
}




-(NPiece *)newPieceViewWithImageNamed:(NSString *)imageName atPostion:(CGPoint)centerPoint positionImage:(CGPoint)positionImage
{
	UIImage *image = [UIImage imageNamed:imageName];
	
	CGRect arect2 = CGRectMake(centerPoint.x, centerPoint.y,  image.size.width,image.size.height);
	CGRect arect = CGRectMake(positionImage.x + startPoint.x, positionImage.y + startPoint.y, image.size.width, image.size.height);

	NPiece *theView = [[NPiece alloc] initWithFrame:arect2];
	CGImageRef myMask = CGImageMaskCreate(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage),
										  CGImageGetBitsPerComponent(image.CGImage), CGImageGetBitsPerPixel(image.CGImage), CGImageGetBytesPerRow(image.CGImage),
										  CGImageGetDataProvider(image.CGImage), NULL, YES);	

	CGImageRef imamyMask = CGImageCreateWithImageInRect(aimagePuzzle.CGImage,arect);
	CGImageRef imamyMask2 = CGImageCreateWithMask(imamyMask, myMask);
	CGImageRelease(imamyMask);
	CGImageRelease(myMask);
	theView.myMaskedImage = imamyMask2;

	return theView;
	
}


// Releases necessary resources. 
- (void)dealloc
{
	/*
	[ahelpcontroller release];
	[thearray release];
	[aimagePuzzle release];
	//[ahelperImageSource ];
	[helpimage release];

	[panel release];
	[board release];
	[amain release];
	[amenu release];
	
	*/
	[super dealloc];	
}

#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	moovingNumber =-1;

    NSInteger numTaps = [[touches anyObject] tapCount];

	if(numTaps >= 2) 
	{
		if (numTaps == 2) 
		{
			mustRotate=YES;
		}
		else
		{
			mustRotate=NO;
		}
	} 
	else 
	{
		mustRotate=NO;
	}
	NSInteger touchCount = 0;
	for (UITouch *touch in touches) {
		[self dispatchFirstTouchAtPoint:[touch locationInView:self.view] forEvent:nil];
		touchCount++;  
	}	
}

-(void) dispatchFirstTouchAtPoint:(CGPoint)touchPoint forEvent:(UIEvent *)event
{
	
//	NSInteger atotal = [thearray count];
	NPiece *firstPieceView;
	NPiece *tomovePiece;
	//for (NSInteger i=0 ; i< atotal; i++) 
	for (NSInteger i=19 ; i>=0 ; i--) 

	{
		firstPieceView = (NPiece *) [thearray objectAtIndex:i];	
		if (firstPieceView.is_ok==NO)
		{
			if (CGRectContainsPoint([firstPieceView frame], touchPoint)) 
			{
				if (mustRotate)
				{
					[self rotateFirstTouchAtPoint:touchPoint forView:firstPieceView];
					break;
				}
				if (moovingNumber ==-1) 
				{
					moovingNumber = firstPieceView.piecenumber;
//					tomovePiece = [thearray objectAtIndex:0];
//					[thearray replaceObjectAtIndex:0 withObject:firstPieceView];
//					[thearray replaceObjectAtIndex:i withObject:tomovePiece];
					tomovePiece = [thearray objectAtIndex:19];
					[thearray replaceObjectAtIndex:19 withObject:firstPieceView];
					[thearray replaceObjectAtIndex:i withObject:tomovePiece];
					
					
					[self animateFirstTouchAtPoint:touchPoint forView:firstPieceView];
					break;
				}
			}
			
		}
	}
	
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{  

	NSInteger touchCount = 0;
   for (UITouch *touch in touches){
	 	[self dispatchTouchEvent:[touch view] toPosition:[touch locationInView:self.view]];
	    touchCount++;
	}
	
}

-(void) dispatchTouchEvent:(UIView *)theView toPosition:(CGPoint)position
{
	// Check to see which view, or views,  the point is in and then move to that position.
	NSInteger atotal = [thearray count];
	NPiece *firstPieceView;

	for (NSInteger i=0 ; i< atotal; i++) 
	{
		firstPieceView = (NPiece *) [thearray objectAtIndex:i];	
		
		if (CGRectContainsPoint([firstPieceView frame], position)) 
		{
			if (moovingNumber ==firstPieceView.piecenumber) 
			{
				[panel bringSubviewToFront:firstPieceView];
				firstPieceView.center =position;
			};
		} 
	}
}

// Handles the end of a touch event.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches){
		[self dispatchTouchEndEvent:[touch view] toPosition:[touch locationInView:self.view]];
	}
}

/*
 Checks to see which view, or views,  the point is in and then calls a method to perform the closing animation,
 which is to return the piece to its original size, as if it is being put down by the user.
*/
-(void) dispatchTouchEndEvent:(UIView *)theView toPosition:(CGPoint)position
{   
	// Check to see which view, or views,  the point is in and then animate to that position.

	NSInteger atotal = [thearray count];
	NPiece *firstPieceView;
	for (NSInteger i=0 ; i< atotal; i++) 
	{
		firstPieceView = (NPiece *) [thearray objectAtIndex:i];	
		
		if (CGRectContainsPoint([firstPieceView frame], position)) 
		{
			if (moovingNumber ==firstPieceView.piecenumber) 
			{
				[self isokpiece:firstPieceView];
				moovingNumber=-1;
				break;
			};
		} 
		
	}
	
	
	 if ([self isok])
	 {
	 [UIView beginAnimations:nil context:NULL];
	 [UIView setAnimationDuration:2.5];
		 buttonNext.alpha=1;
	 [UIView commitAnimations];
	 }
	 
	
	
	 
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//	touchPhaseText.text = @"Phase: Touches cancelled";
    // Enumerates through all touch object
    for (UITouch *touch in touches){
		// Sends to the dispatch method, which will make sure the appropriate subview is acted upon
		[self dispatchTouchEndEvent:[touch view] toPosition:[touch locationInView:self.view]];
	}
}

#pragma mark -
#pragma mark === Animating subviews ===
#pragma mark

// Scales up a view slightly which makes the piece slightly larger, as if it is being picked up by the user.
- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint forView:(NPiece *)theView 
{
	return ;
}


- (void)rotateFirstTouchAtPoint:(CGPoint)touchPoint forView:(NPiece *)theView 
{
	// 0 = 0
	// 1 = 90
	// 2 = 180
	// 3 = 270
	// Pulse the view by scaling up, then move the view to under the finger.
	if (theView.orientation<3)
	{
		theView.orientation= theView.orientation+1;
	}

	else
	{
		theView.orientation= 0;
	
	}
	
	NSValue *touchPointValue = [[NSValue valueWithCGPoint:touchPoint] retain];
	[UIView beginAnimations:nil context:touchPointValue];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
	CGAffineTransform transform = CGAffineTransformMakeRotation(PI_OVER_2 * theView.orientation);
	theView.transform = transform;
	[UIView commitAnimations];
	[theView setNeedsDisplay];
	
}


// Scales down the view and moves it to the new position. 
- (void)animateView:(NPiece *)theView toPosition:(CGPoint) thePosition
{
	return;
}



-(void)helppress:aobj
{
	CGRect adid;
	adid =  amenu.frame;
	adid.origin.x= 330;
	amenu.frame = adid;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.8];
	
	adid =  amenu.frame;
	adid.origin.x =0; 
	amenu.frame = adid;
	
	[UIView commitAnimations];
}


-(void)Showhelppress:aobj
{
	[self SavePiecesPosition];
	if (ahelpcontroller ==nil)
	{
		ahelpcontroller = [[HelpViewController alloc]initWithNibName:@"HelpWindow" bundle:nil];
	}
	ahelpcontroller.Aimage = helpimage;
	ahelpcontroller.show;
	[self.navigationController pushViewController:ahelpcontroller animated:YES];
}


-(BOOL)isokpiece:(NPiece*)firstPieceView
{
	BOOL salida=YES;
	firstPieceView.is_ok=NO;

	if (firstPieceView.orientation==3)
	{
		if( (firstPieceView.center.x >=firstPieceView.posxyFixed.x-8) &&(firstPieceView.center.x <=firstPieceView.posxyFixed.x+8))
		{
			if( (firstPieceView.center.y >=firstPieceView.posxyFixed.y-8) &&(firstPieceView.center.y <=firstPieceView.posxyFixed.y+8))
			{
				firstPieceView.is_ok=YES;
				firstPieceView.center=firstPieceView.posxyFixed;
				[firstPieceView setNeedsDisplay];
			}
			else
			{
				salida =NO;
			}
		}
		else
		{
			salida =NO;
		}
	}
	else
	{
		salida =NO;
	}
	return salida;
}


-(BOOL)isok
{
	BOOL salida=YES;
	NSInteger atotal = [thearray count];
	NPiece *firstPieceView;
	for (NSInteger i=0 ; i< atotal; i++) 
	{
		firstPieceView = (NPiece *) [thearray objectAtIndex:i];	
		salida =[self isokpiece:firstPieceView]; 
		if (salida==NO)
		{
			break;
		}
	}
	
	return salida;
		
}

-(void)Backpress:aobj
{
	[self SavePiecesPosition];
	[self.navigationController popViewControllerAnimated:YES];
	sleep(1);

}



-(void)Solvepress:aobj
{

	const char *sql = "SELECT piece_id,posx , posy  FROM solved_pieces";
	sqlite3_stmt *statement;
	CGPoint apoint;
	NPiece * aimageview;
	NSInteger atotal = [thearray count];

	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1];
		while (sqlite3_step(statement) == SQLITE_ROW) 
		{
			
			for (NSInteger i=0 ; i< atotal; i++) 
			{
				aimageview = (NPiece *) [thearray objectAtIndex:i];
				if (aimageview.piecenumber==sqlite3_column_int(statement, 0))
				{
					break;
				}
			}
		
			apoint.x =sqlite3_column_double(statement, 1);
			apoint.y =sqlite3_column_double(statement, 2);
			aimageview.orientation =3;
			CGAffineTransform transform = CGAffineTransformMakeRotation(PI_OVER_2 * aimageview.orientation);
			aimageview.transform = transform;
			aimageview.center = apoint;

		}
		sqlite3_finalize(statement);

		[UIView commitAnimations];
		
		for (NSInteger i=0 ; i< atotal; i++) 
		{
			aimageview = (NPiece *) [thearray objectAtIndex:i];
			[self isokpiece:aimageview];
		}
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:2.5];
		buttonNext.alpha=1;
	
		[UIView commitAnimations];
		

		
    } 
	else 
	{
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
}


-(void)clickcancel:aobj
{

	CGRect adid;
	adid =  amenu.frame;
	adid.origin.x =330; 
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.8];
	amenu.frame = adid;
	[UIView commitAnimations];
	
}

-(void)clickhint:aobj
{
	[self clickcancel:nil];
	[self Showhelppress:nil];
}

-(void)clickreturn:aobj
{
	[self clickcancel:nil];
	[self Backpress:nil];
	saved=YES;
}


-(void)clicksolve:aobj
{
	[self clickcancel:nil];
	[self Solvepress:nil];
}


-(void)clicksave:aobj
{
	[self SavePiecesPosition];
	[self clickcancel:nil];
}


-(void)clickonnext:aobj
{
	[self SavePiecesPosition];
	[self Backpress:nil];

	return;
	CGPoint  apoint;
	int resultadox;
	int resultadoy;	
	
	actual=	Minipiece.pieceClick;
	
	NSInteger aint = thearrayMasternext[actual];
	int ax;
	for  (ax=0;ax<20;ax++)
	{
		Minipiece = [self.thearrayMaster objectAtIndex:ax];
		if (Minipiece.pieceClick==aint)
		{
			break;
		}
		
	}
	aint= Minipiece.pieceClick;
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
	self.startPoint = apoint;
	
	
	
	[self BeginwithImage:agame.ImageGame];
	
	buttonNext.alpha=0;
	
}


-(void)clickquick:obj
{
	[self Showhelppress:nil];

}


@end

