//
//  NGame.m
//  Puzzoodle
//
//  Created by macmini on 12/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
// 	const char *sql = "UPDATE games SET gamename=? , id_picture =? , status = ? WHERE ID=?";

#import "NGame.h"
#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}

static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;
static sqlite3_stmt *create_statement = nil;
static sqlite3_stmt *dehydrate_main_statement = nil;
static sqlite3_stmt *new_main_statement = nil;
static sqlite3_stmt *new_main_statement2 = nil;
static sqlite3_stmt *create_statement_game=nil;
static sqlite3_stmt *init_photo=nil;

UIImageOrientation stuff_orient;



@implementation NGame

@synthesize  primaryKey;
@synthesize  gameName;
@synthesize  pictureId;
@synthesize  status;
@synthesize ImageGame;
@synthesize Thubmnail;
@synthesize ImageShowMini;
@synthesize orientation;
- (void)dealloc
{
	[self.ImageGame release];
	[self.ImageShowMini release];
//	[self.Thubmnail release];
	[self.gameName release];
	[super dealloc];
};


+ (void)finalizeStatements
{
    if (init_statement) sqlite3_finalize(init_statement);
	if ( dehydrate_statement ) sqlite3_finalize(dehydrate_statement );
	if ( create_statement ) sqlite3_finalize(create_statement );
	if ( dehydrate_main_statement ) sqlite3_finalize(dehydrate_main_statement);
	if ( new_main_statement  ) sqlite3_finalize(new_main_statement );
	if ( new_main_statement2  ) sqlite3_finalize(new_main_statement2 );
	if (create_statement_game)sqlite3_finalize(create_statement_game );
	if (init_photo)sqlite3_finalize(init_photo );

	
	
}


- (UIImage *)rotate:(UIImage *)img
{
	CGSize size = [img size];
	
	CGImageRef imageRef = [img CGImage];
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												size.height,
												size.width,
												CGImageGetBitsPerComponent(imageRef),
												4*size.height,
												CGImageGetColorSpace(imageRef),
												CGImageGetBitmapInfo(imageRef));
	if (stuff_orient ==	UIImageOrientationRight)
	{
		CGContextTranslateCTM( bitmap, 0, size.width);
		CGContextRotateCTM( bitmap, 3*radians(90.) );
	}
	else
	{
		CGContextTranslateCTM( bitmap, size.height, 0 );
		CGContextRotateCTM( bitmap, radians(90.) );
	}
	CGContextDrawImage( bitmap, CGRectMake(0,0,size.width,size.height), imageRef );
	CGImageRef ref = CGBitmapContextCreateImage( bitmap );	
	CGContextRelease( bitmap );
	UIImage *oimg = [UIImage imageWithCGImage:ref];
	CGImageRelease( ref );
	return oimg;
}

- (UIImage*)scaleAndRotateImage:(UIImage*)img {
	
	CGImageRef imgRef = img.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	UIImageOrientation orient = [img imageOrientation];
	stuff_orient =orient;
	if (orient == UIImageOrientationUp) {
		return img;
	}
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);

//	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	
	CGContextRef context = CGBitmapContextCreate(
												NULL,
												
												bounds.size.width,
												bounds.size.height,
												CGImageGetBitsPerComponent(imgRef),
												4*bounds.size.width,
												CGImageGetColorSpace(imgRef),
												CGImageGetBitmapInfo(imgRef));
	
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
	
	
	
	CGImageRef ref = CGBitmapContextCreateImage( context );	
	CGContextRelease( context );
	UIImage *oimg = [UIImage imageWithCGImage:ref];
	
//	[img release];
//	CGImageRelease( imgRef );
//	img= oimg;
	return oimg;
	
	
	
}






+(NSInteger) createGameindatabase:(sqlite3 *)db picture:(NSString*)lapicture
{
	int valor=0;
	if (create_statement_game == nil) 
	{
		const char *sql = "update  pictures  set imagename=? where id =4";
		if (sqlite3_prepare_v2(db, sql, -1, &create_statement_game, NULL) != SQLITE_OK) 
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
	}
	sqlite3_bind_text(create_statement_game, 1, [lapicture UTF8String],-1,SQLITE_STATIC);
	if (sqlite3_step(create_statement_game) == SQLITE_ROW) 
	{
		//valor= sqlite3_last_insert_rowid(db); 
	}
	sqlite3_reset(create_statement_game);
	return valor;

}


-(UIImage*)MakeThumbnail:(UIImage*)img
{
	CGSize size = [img size];
	UIImageOrientation imageOrientation = [img imageOrientation];
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	CGImageRef imageRef = [img CGImage];
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												size.width,
												size.height,
												CGImageGetBitsPerComponent(imageRef),
												4*size.width,
												CGImageGetColorSpace(imageRef),
												CGImageGetBitmapInfo(imageRef));
	
	CGContextTranslateCTM( bitmap,0, size.height-320 );
	
	switch (imageOrientation) {
	    case UIImageOrientationUp:
			transform = CGAffineTransformScale(transform, .200, .275);
			CGContextConcatCTM(bitmap,transform);
			break;
		case UIImageOrientationDown:
			// rotate 180 degees CCW
	//		CGContextRotateCTM( bitmap, radians(180.) );
			break;
		case UIImageOrientationLeft:
			// rotate 90 degrees CW
	//		CGContextRotateCTM( bitmap, radians(90.) );
			break;
		case UIImageOrientationRight:
			// rotate 90 degrees CCW
		//	CGContextRotateCTM( bitmap, radians(-90.) );
			break;
		default:
			break;
	}
	CGContextDrawImage( bitmap, CGRectMake(0,0,size.width,size.height), imageRef );	
	CGImageRef ref = CGBitmapContextCreateImage( bitmap );	
	CGContextRelease( bitmap );
	UIImage *oimg = [UIImage imageWithCGImage:ref];
	CGImageRelease( ref );
	return oimg;	
}



-(UIImage*)MakeThumbnail3:(UIImage*)img
{
	CGSize size = [img size];
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	CGImageRef imageRef = [img CGImage];
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												size.width,
												size.height,
												CGImageGetBitsPerComponent(imageRef),
												4*size.width,
												CGImageGetColorSpace(imageRef),
												CGImageGetBitmapInfo(imageRef));
	
	CGContextTranslateCTM( bitmap,0, size.height-320 );
	
			transform = CGAffineTransformScale(transform,  .200,.265);
//				transform = CGAffineTransformScale(transform,  .15,.15);

	CGContextConcatCTM(bitmap,transform);
	CGContextDrawImage( bitmap, CGRectMake(0,0,size.height,size.width), imageRef );	
	CGImageRef ref = CGBitmapContextCreateImage( bitmap );	
	CGContextRelease( bitmap );
	UIImage *oimg = [UIImage imageWithCGImage:ref];
	CGImageRelease( ref );
	return oimg;	
}






-(UIImage*)MakeThumbnail2:(UIImage*)img
{
	CGSize size = [img size];
	UIImageOrientation imageOrientation = [img imageOrientation];
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	CGImageRef imageRef = [img CGImage];
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												size.width,
												size.height,
												CGImageGetBitsPerComponent(imageRef),
												4*size.width,
												CGImageGetColorSpace(imageRef),
												CGImageGetBitmapInfo(imageRef));
	
	CGContextTranslateCTM( bitmap,0, size.height-320 );
	
	switch (imageOrientation) {
	    case UIImageOrientationUp:
			transform = CGAffineTransformScale(transform,  .200,.265);
			CGContextConcatCTM(bitmap,transform);
			break;
		case UIImageOrientationDown:
			// rotate 180 degees CCW
	//		CGContextRotateCTM( bitmap, radians(180.) );
			break;
		case UIImageOrientationLeft:
			// rotate 90 degrees CW
	//		CGContextRotateCTM( bitmap, radians(90.) );
			break;
		case UIImageOrientationRight:
			// rotate 90 degrees CCW
	//		CGContextRotateCTM( bitmap, radians(-90.) );
			break;
		default:
			break;
	}
	CGContextDrawImage( bitmap, CGRectMake(0,0,size.width,size.height), imageRef );	
	CGImageRef ref = CGBitmapContextCreateImage( bitmap );	
	CGContextRelease( bitmap );
	UIImage *oimg = [UIImage imageWithCGImage:ref];
	CGImageRelease( ref );
	return oimg;	
}







- (UIImage *)fixImageOrientationPhoto:(UIImage *)img
{
	CGSize size = [img size];
	double afactor;
	if (size.width > size.height)
	{
		afactor=1600/size.width;
	}
	else
	{
		afactor=1200/size.width;
	
	}
	
	UIImageOrientation imageOrientation = [img imageOrientation];
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGImageRef imageRef = [img CGImage];
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												1600,
												1200,
												CGImageGetBitsPerComponent(imageRef),
												4*1600,
												CGImageGetColorSpace(imageRef),
												CGImageGetBitmapInfo(imageRef));
//	CGContextTranslateCTM( bitmap, size.width, size.height );
	switch (imageOrientation) {
	    case UIImageOrientationUp:
			transform = CGAffineTransformScale(transform, afactor, afactor);
			CGContextConcatCTM(bitmap,transform);
			break;
		case UIImageOrientationDown:
			// rotate 180 degees CCW
	//		CGContextRotateCTM( bitmap, radians(180.) );
			break;
		case UIImageOrientationLeft:
			// rotate 90 degrees CW
	//		CGContextRotateCTM( bitmap, radians(90.) );
			break;
		case UIImageOrientationRight:
			// rotate 90 degrees CCW
	//		CGContextRotateCTM( bitmap, radians(-90.) );
			break;
		default:
			break;
	}
	CGContextDrawImage( bitmap, CGRectMake(0,0,size.height,size.width), imageRef );
	CGImageRef ref = CGBitmapContextCreateImage( bitmap );	
	CGContextRelease( bitmap );
	UIImage *oimg = [UIImage imageWithCGImage:ref];
	CGImageRelease( ref );
	return oimg;
}




- (UIImage *)fixImageOrientationPhoto2:(UIImage *)img
{
	CGSize size = [img size];
	
	double afactorx;
	double afactory;
	afactorx=((double)1600)/size.width;
	afactory=((double)1200)/size.height;
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGImageRef imageRef = [img CGImage];
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												1600,
												1200,
												CGImageGetBitsPerComponent(imageRef),
												4*1600,
												CGImageGetColorSpace(imageRef),
												CGImageGetBitmapInfo(imageRef));
	transform = CGAffineTransformScale(transform, afactorx, afactory);
	CGContextConcatCTM(bitmap,transform);

	CGContextDrawImage( bitmap, CGRectMake(0,0,size.width,size.height), imageRef );
	CGImageRef ref = CGBitmapContextCreateImage( bitmap );	
	CGContextRelease( bitmap );
	UIImage *oimg = [UIImage imageWithCGImage:ref];
	CGImageRelease( ref );
	return oimg;
}





- (UIImage *)fixImageOrientationPhoto3:(UIImage *)img
{
	CGSize size = [img size];
	double afactor;
	if (size.width > size.height)
	{
		afactor=1600/size.width;
	}
	else
	{
		afactor=1200/size.width;
		
	}
	
	UIImageOrientation imageOrientation = [img imageOrientation];
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGImageRef imageRef = [img CGImage];
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												1600,
												1200,
												CGImageGetBitsPerComponent(imageRef),
												4*1600,
												CGImageGetColorSpace(imageRef),
												CGImageGetBitmapInfo(imageRef));
	//	CGContextTranslateCTM( bitmap, size.width, size.height );
	switch (imageOrientation) {
	    case UIImageOrientationUp:
			transform = CGAffineTransformScale(transform, afactor, afactor);
			CGContextConcatCTM(bitmap,transform);
			break;
		case UIImageOrientationDown:
			// rotate 180 degees CCW
		//	CGContextRotateCTM( bitmap, radians(180.) );
			break;
		case UIImageOrientationLeft:
			// rotate 90 degrees CW
		//	CGContextRotateCTM( bitmap, radians(90.) );
			break;
		case UIImageOrientationRight:
			// rotate 90 degrees CCW
		//	CGContextRotateCTM( bitmap, radians(-90.) );
			break;
		default:
			break;
	}
	CGContextDrawImage( bitmap, CGRectMake(0,0,size.width,size.height), imageRef );
	CGImageRef ref = CGBitmapContextCreateImage( bitmap );	
	CGContextRelease( bitmap );
	UIImage *oimg = [UIImage imageWithCGImage:ref];
	CGImageRelease( ref );
	return oimg;
}


- (UIImage *)fixImageOrientation:(UIImage *)img
{
	CGSize size = [img size];

	UIImageOrientation imageOrientation = [img imageOrientation];
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGImageRef imageRef = [img CGImage];
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												size.width,
												size.height,
												CGImageGetBitsPerComponent(imageRef),
												4*size.width,
												CGImageGetColorSpace(imageRef),
												CGImageGetBitmapInfo(imageRef));
	CGContextTranslateCTM( bitmap, size.width, size.height );
	switch (imageOrientation) {
	    case UIImageOrientationUp:
			transform = CGAffineTransformMakeTranslation(0.0, size.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			CGContextRotateCTM( bitmap, radians(-180) );
			CGContextConcatCTM(bitmap,transform);
			break;
		case UIImageOrientationDown:
			// rotate 180 degees CCW
		//	CGContextRotateCTM( bitmap, radians(180.) );
			break;
		case UIImageOrientationLeft:
			// rotate 90 degrees CW
		//	CGContextRotateCTM( bitmap, radians(90.) );
			break;
		case UIImageOrientationRight:
			// rotate 90 degrees CCW
	//		CGContextRotateCTM( bitmap, radians(-90.) );
			break;
		default:
			break;
	}
	CGContextDrawImage( bitmap, CGRectMake(0,0,size.width,size.height), imageRef );
	CGImageRef ref = CGBitmapContextCreateImage( bitmap );	
	CGContextRelease( bitmap );
	UIImage *oimg = [UIImage imageWithCGImage:ref];
	CGImageRelease( ref );
	return oimg;
}


- (UIImage *)fixImageOrientationExport:(UIImage *)img
{
	CGSize size = [img size];
	
	UIImageOrientation imageOrientation = [img imageOrientation];
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGImageRef imageRef = [img CGImage];
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												size.width,
												size.height,
												CGImageGetBitsPerComponent(imageRef),
												4*size.width,
												CGImageGetColorSpace(imageRef),
												CGImageGetBitmapInfo(imageRef));
	CGContextTranslateCTM( bitmap, size.width, size.height );
	switch (imageOrientation) {
	    case UIImageOrientationUp:
			transform = CGAffineTransformMakeTranslation(0.0, size.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			CGContextRotateCTM( bitmap, radians(-180) );
			CGContextConcatCTM(bitmap,transform);
			break;
		case UIImageOrientationDown:
			// rotate 180 degees CCW
			//	CGContextRotateCTM( bitmap, radians(180.) );
			break;
		case UIImageOrientationLeft:
			// rotate 90 degrees CW
			//	CGContextRotateCTM( bitmap, radians(90.) );
			break;
		case UIImageOrientationRight:
			// rotate 90 degrees CCW
			//		CGContextRotateCTM( bitmap, radians(-90.) );
			break;
		default:
			break;
	}
	CGContextDrawImage( bitmap, CGRectMake(0,0,size.width,size.height), imageRef );
	CGImageRef ref = CGBitmapContextCreateImage( bitmap );	
	CGContextRelease( bitmap );
	UIImage *oimg = [UIImage imageWithCGImage:ref];
	CGImageRelease( ref );
	return oimg;
}




+(BOOL)is_photorrollSelected:(sqlite3 *)db
{
	BOOL salida;
	char * str;
	if (init_photo == nil) 
	{
		const char *sql = "SELECT imagename from pictures where id =4";
		if (sqlite3_prepare_v2(db, sql, -1, &init_photo, NULL) != SQLITE_OK) 
			{
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
            }
	}
	if (sqlite3_step(init_photo) == SQLITE_ROW) 
	{
			str = (char *)sqlite3_column_text(init_photo, 0);
			if (strcmp(str,"none")==0)
			{
				salida=YES;
			}
			else
			{
				salida=NO;
			}
	} 
	sqlite3_reset(init_photo);
	return salida;
}




- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db
{
	char * str;
    if (self = [super init]) 
	{
        primaryKey = pk;
        database = db;
        if (init_statement == nil) 
		{
            const char *sql = "SELECT gamename , id_picture ,status , imagename  FROM games , pictures where games.id_picture = pictures.id and games.id=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) 
			{
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        sqlite3_bind_int(init_statement, 1, primaryKey);
        if (sqlite3_step(init_statement) == SQLITE_ROW) 
		{
			str = (char *)sqlite3_column_text(init_statement, 0);
			self.gameName = (str) ? [NSString stringWithUTF8String:str] : @"";
			self.pictureId = sqlite3_column_int(init_statement, 1);
			self.status = sqlite3_column_int(init_statement, 2);
			str = (char *)sqlite3_column_text(init_statement, 3);
			if (pk!=4)
			{
				self.orientation=YES;
				self.ImageShowMini = [UIImage imageNamed:[NSString stringWithUTF8String:str]];
				self.ImageGame = [self fixImageOrientation:self.ImageShowMini];
				self.Thubmnail = [self MakeThumbnail:self.ImageGame];
			}
			else
			{
				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *documentsDirectory = [paths objectAtIndex:0];
				NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:str]];

				UIImage *ImageShowMini2;
				ImageShowMini2 = [UIImage imageWithContentsOfFile:path];
				if  ([ImageShowMini2 size].width >= [ImageShowMini2 size].height) 
				{
					self.ImageShowMini = [self scaleAndRotateImage:ImageShowMini2];
					self.orientation=YES;
					ImageGameaux = [self fixImageOrientation:self.ImageShowMini];
					self.ImageGame = [self fixImageOrientationPhoto3:ImageGameaux];
					[ImageGameaux release];
					self.Thubmnail = [self MakeThumbnail:self.ImageGame];
				}
				else	
				{
					/*
					self.ImageShowMini = [self scaleAndRotateImage:ImageShowMini2];
					self.ImageShowMini = [self rotate:self.ImageShowMini];
					self.orientation=NO;
					ImageGameaux = [self fixImageOrientation:self.ImageShowMini];
					self.ImageGame = [self fixImageOrientationPhoto2:ImageGameaux];
					[ImageGameaux release];
					self.Thubmnail = [self MakeThumbnail3:self.ImageGame];
					*/

					self.ImageShowMini = [self scaleAndRotateImage:ImageShowMini2];
					self.ImageShowMini= [self rotate:self.ImageShowMini];

					self.orientation=NO;
					ImageGameaux = [self fixImageOrientation:self.ImageShowMini];
					self.ImageGame = [self fixImageOrientationPhoto2:ImageGameaux];
					//[ImageGameaux release];
					self.Thubmnail = [self MakeThumbnail2:self.ImageGame];
				}
			}
        } 
		else 
		{
			self.gameName =@"";
			self.pictureId =0;
			self.status = 0;
			self.ImageGame=nil;
		}
        sqlite3_reset(init_statement);
    }
    return self;
}

-(void) saveMainPiece:(NSInteger)idpiece status:(NSInteger)thestatus
{
	if (dehydrate_main_statement == nil) 
	{
		const char *sql = "UPDATE games_main SET status=? where  id_main_pieces =?  and id_game = ?";
		if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_main_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_bind_int(dehydrate_main_statement, 3 , self.primaryKey);
	sqlite3_bind_int(dehydrate_main_statement, 2 , idpiece);
	sqlite3_bind_int(dehydrate_main_statement, 1 , thestatus) ;
	int success = sqlite3_step(dehydrate_main_statement);
	if (success != SQLITE_DONE) 
	{
		NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_reset(dehydrate_main_statement);
	return;
}

-(void) CommitChanges
{
	if (dehydrate_statement == nil) 
	{
		const char *sql = "UPDATE games SET gamename=? , id_picture =? , status = ? WHERE ID=?";
		if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}

	sqlite3_bind_text(dehydrate_statement, 1, [self.gameName UTF8String],-1 , SQLITE_STATIC);
	sqlite3_bind_int(dehydrate_statement, 2 , self.pictureId);
	sqlite3_bind_int(dehydrate_statement, 3 , self.status);
	sqlite3_bind_int(dehydrate_statement, 4 ,primaryKey) ;
	
	int success = sqlite3_step(dehydrate_statement);
	if (success != SQLITE_DONE) 
	{
		NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_reset(dehydrate_statement);

}

- (void)deleteGame
{

	if (new_main_statement == nil) 
	{
		const char *sql = "UPDATE games_main SET status=0 where  id_game = ?";
		if (sqlite3_prepare_v2(database, sql, -1, &new_main_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_bind_int(new_main_statement, 1 , self.primaryKey);
	int success = sqlite3_step(new_main_statement);
	if (success != SQLITE_DONE) 
	{
		NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_reset(new_main_statement);
	
	if (new_main_statement2 == nil) 
	{
		const char *sql = "UPDATE games_pieces SET status=0, posx =0 , posy =0 where  game_id = ?";
		if (sqlite3_prepare_v2(database, sql, -1, &new_main_statement2, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_bind_int(new_main_statement2, 1 , self.primaryKey);
	success = sqlite3_step(new_main_statement2);
	if (success != SQLITE_DONE) 
	{
		NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_reset(new_main_statement2);
	return;
}

-(BOOL) IsGameInProgress
{
	return YES;
}




@end

