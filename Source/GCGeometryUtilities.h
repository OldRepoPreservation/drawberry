///**********************************************************************************************************************************
///  GCGeometryUtilities.h
///  GCDrawKit
///
///  Created by graham on 22/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
extern "C"
{
#endif


NSRect		NSRectFromTwoPoints( const NSPoint a, const NSPoint b);

float		PointFromLine( const NSPoint inPoint, const NSPoint a, const NSPoint b );
NSPoint		NearestPointOnLine( const NSPoint inPoint, const NSPoint a, const NSPoint b );
float		RelPoint( const NSPoint inPoint, const NSPoint a, const NSPoint b );

NSPoint		BisectLine( const NSPoint a, const NSPoint b );
NSPoint		Interpolate( const NSPoint a, const NSPoint b, const float proportion);
float		LineLength( const NSPoint a, const NSPoint b );

float		SquaredLength( const NSPoint p );
NSPoint		DiffPoint( const NSPoint a, const NSPoint b );
float		DiffPointSquaredLength( const NSPoint a, const NSPoint b );

NSPoint		EndPoint( NSPoint origin, float angle, float length );
float		Slope( const NSPoint a, const NSPoint b );
float		AngleBetween( const NSPoint a, const NSPoint b, const NSPoint c );
float		DotProduct( const NSPoint a, const NSPoint b );
NSPoint		Intersection( NSPoint aa, NSPoint ab, NSPoint ba, NSPoint bb );

NSRect		CentreRectOnPoint( NSRect inRect, NSPoint p );

NSRect		ScaledRectForSize( NSSize inSize, NSRect fitRect );
NSRect		CentreRectInRect( NSRect r, NSRect cr );

NSRect		NormalizedRect( NSRect r );

//NSPoint		PerspectiveMap( NSPoint inPoint, NSSize sourceSize, NSPoint quad[4]);

NSPoint		NearestPointOnCurve( const NSPoint inp, const NSPoint bez[4], double* tValue );
NSPoint		Bezier( const NSPoint* v, const int degree, const double t, NSPoint* Left, NSPoint* Right );

float		BezierSlope( const NSPoint bez[4], const float t );

#ifdef __cplusplus
}
#endif

