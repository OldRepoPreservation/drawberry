
#ifndef pointh
#include <math.h>
#include <stdio.h>
#define pointh
#define MOD2RAD(rv,v) rv=v;while(rv<-3.141592653f) rv+=6.283185307f; while(rv >= 3.141592653f) rv-=6.283185307f; 
#define RADTODEG 57.2957795131
#define DEGTORAD  0.0174532925
#ifdef POINT2D
#define Z(code...)
#else
#define Z(code...) code
#endif
class point;
typedef point vec;
typedef point euler;

class point{
public:
	float x;
	float y;
	Z(float z;)
	
	inline void	operator=(const point& p)					{x=p.x;y=p.y;Z(z=p.z;)}
	inline point operator+(const point& p)const				{return point(x+p.x,y+p.y Z(,z+p.z));}
	inline point operator-(const point& p)const				{return point(x-p.x,y-p.y Z(,z-p.z));}
	inline point operator-()const							{return point(-x,-y	Z(	,-z) );}
	inline float operator*(const vec&	v)const				{return x*v.x + y*v.y Z(+ z*v.z);}//dot
	inline float operator/(const vec&	v)const				{return x/v.x + y/v.y Z(+ z/v.z);}//dot^-1
	inline point operator*(const float	f)const				{return point(x*f,y*f	Z(,z*f));}
	inline point operator/(const float	f)const				{return point(x/f,y/f	Z(,z/f));}
	inline void operator+=(const point& p)					{x+=p.x;y+=p.y;	Z(z+=p.z;)}
	inline void operator-=(const point& p)					{x-=p.x;y-=p.y;	Z(z-=p.z;)}
	inline void operator*=(const point& p)					{x*=p.x;y*=p.y;	Z(z*=p.z;)}
	inline void operator/=(const point& p)					{x/=p.x;y/=p.y;	Z(z/=p.z;)}
	inline void operator*=(const float	f)					{x*=f;y*=f;	Z(z*=f;)}
	inline void operator/=(const float	f)					{x/=f;y/=f;	Z(z/=f;)}
	
	inline bool operator==(const point & p)const			{return x>= p.x-0.00001 && x<= p.x+0.00001 && y >= p.y-0.00001 && y<= p.y+0.00001 	Z( && z>= p.z-0.00001 && z<= p.z+0.00001 );}
	inline void zero()										{x=0;y=0;	Z(z=0;)}

	inline void set(const point& p)							{x=p.x;y=p.y;	Z(z=p.z;)}
	inline void set(const point* p)							{x=p->x;y=p->y;	Z(z=p->z;)}
Z(	inline void set(float xx,float yy,float zz)				{x=xx;y=yy;z=zz;}	)
	inline void set(float xx,float yy)						{x=xx;y=yy;Z(z=0;)}
	inline void set(float xyz)								{x=xyz;y=xyz;	Z(z=xyz;)}
	inline void min(const point & p)						{if(p.x <x) x=p.x;if(p.y <y) y=p.y;	Z(if(p.z <z) z=p.z;)}
	inline void max(const point & p)						{if(p.x >x) x=p.x;if(p.y >y) y=p.y;	Z(if(p.z >z) z=p.z;)}
	inline void normaliz()									{float mag=sqrtf(x*x+y*y 	Z(+z*z)); if(mag >0.00001){ x/=mag;y/=mag;	Z(z/=mag;)}else zero();}
	inline vec  dir()const									{float mg= mag(); return mg>0.00001? vec(x/mg,y/mg Z(,z/mg)) : vec(0.0f);}
	inline float magcarre()const							{return x*x+y*y Z(+z*z); }
	inline float magcarre(const point&  p)const				{float r,c; c=x- p.x;r=c*c;c=y- p.y; r+=c*c; 	Z(c=z-p.z; r+=c*c;)return r; }
	inline float magcarre(const point*  p)const				{float r,c; c=x- p->x;r=c*c;c=y- p->y; r+=c*c; 	Z(c=z-p->z; r+=c*c;)return r; }
	inline float mag()const									{return sqrtf(x*x+y*y	Z(+z*z));}

	inline float distance(const point& p)const				{float r,c; c=x- p.x;r=c*c;c=y- p.y; r+=c*c; 	Z(c=z-p.z; r+=c*c); return sqrtf(r);}
	inline float distance(const point* p)const				{float r,c; c=x- p->x;r=c*c;c=y- p->y; r+=c*c; 	Z(c=z-p->z; r+=c*c); return sqrtf(r);}
	
	inline point()											{}
	inline point(const point& p)							{ x=p.x;y=p.y;	Z(z=p.z;)}
	inline point(const point* p)							{ x=p->x;y=p->y;	Z(z=p->z;)}
Z(	inline point(float xx,float yy,float zz)				{x=xx;y=yy;z=zz;})
	inline point(float xx,float yy)							{x=xx;y=yy;	Z(z=0;)}
	inline point(float xyz)									{x=xyz;y=xyz;	Z(z=xyz;)}
	
Z(	inline vec cross(const vec& v)const						{vec vr; vr.x = y * v.z - z * v.y; vr.y = z * v.x - x * v.z; vr.z = x * v.y - y * v.x; return vr;})
Z(	inline vec cross(const vec* v)const						{vec vr; vr.x = y * v->z - z * v->y; vr.y = z * v->x - x * v->z; vr.z = x * v->y - y * v->x; return vr;})
	inline float dot(const vec& v)const						{return x*v.x + y*v.y 	Z(+ z*v.z);}
	inline float dot(const vec* v)const						{return x*v->x + y*v->y 	Z(+ z*v->z);}
	
	bool nan() const										{return isnan(x) || isnan(y) 	Z(|| isnan(z)) ;}

#ifdef POINT2D
	void print()const										{printf("x: %f	y: %f	\n",x,y);}
	void print(char * nom)const								{printf("%s :	x: %f	y: %f	\n",nom,x,y);}
#else
	void print()const										{printf("x: %f	y: %f	z: %f	\n",x,y,z);}
	void print(char * nom)const								{printf("%s :	x: %f	y: %f	z: %f	\n",nom,x,y,z);}
#endif
	
Z(	void soustractionrotationradian(const euler & a,const euler & b) {
		float A,B,z1,z2;

		MOD2RAD(A,a.x);
		MOD2RAD(B,b.x);
		if(A < B) { z1= B-A; z2 =-(A+(6.28318530718f-B));}
		else { z1= (6.28318530718f-A) +B; z2=-( A-B);} 
		x= (z1 <= -z2)?z1:z2;
		
		MOD2RAD(A,a.y);
		MOD2RAD(B,b.y);
		if(A < B) { z1= B-A; z2 =-(A+(6.28318530718f-B));}
		else { z1= (6.28318530718f-A) +B; z2=-( A-B);} 
		y= (z1 <= -z2)?z1:z2;
		
		MOD2RAD(A,a.z);
		MOD2RAD(B,b.z);
		if(A < B) { z1= B-A; z2 =-(A+(6.28318530718f-B));}
		else { z1= (6.28318530718f-A) +B; z2=-( A-B);} 
		z= (z1 <= -z2)?z1:z2;
	})
#ifdef __OBJC__
	inline point(const NSPoint& p)							{ x=p.x;y=p.y;	Z(z=0;)}
	inline void set(const NSPoint& p)						{x=p.x;y=p.y;	Z(z=0;)}
	inline void	operator=(const NSPoint& p)					{x=p.x;y=p.y;	Z(z=0;)}
	inline point(const NSSize& s)							{x=s.width;y=s.height;	Z(z=0;)}
	inline void set(const NSSize& s)						{x=s.width;y=s.height;	Z(z=0;)}
	inline void	operator=(const NSSize& s)					{x=s.width;y=s.height;	Z(z=0;)}
	inline operator NSPoint () const						{return NSMakePoint(x,y);}
	inline operator NSSize () const							{return NSMakeSize(x,y);}
	inline NSPoint ns()	const								{return NSMakePoint(x,y);}
	inline NSRect makeRect(const vec & size) const			{return NSMakeRect(x,y,size.x,size.y);}
	inline NSRect rect(const point & p) const 				{NSRect r; r.size.width=x-p.x;r.size.height=y-p.y;if(r.size.width <0) {r.size.width=-r.size.width; r.origin.x=x;}else r.origin.x=p.x; if(r.size.height <0) {r.size.height=-r.size.height; r.origin.y=y;}else r.origin.y=p.y;return r;}
	void strokerect(float rayon=2)							{[NSBezierPath strokeRect:NSMakeRect(x-rayon,y-rayon,rayon+rayon,rayon+rayon)];}
	void fillrect(float rayon=2)							{[NSBezierPath fillRect:NSMakeRect(x-rayon,y-rayon,rayon+rayon,rayon+rayon)];}
	void strokeround(float rayon=5)							{[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(x-rayon,y-rayon,rayon+rayon,rayon+rayon)]stroke];}
	void fillround(float rayon=3)							{[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(x-rayon,y-rayon,rayon+rayon,rayon+rayon)]fill];}
	void lineto(const point & p)							{[NSBezierPath strokeLineFromPoint:ns() toPoint:p.ns()];}
	void strokecross(float rayon=5)							{[NSBezierPath strokeLineFromPoint:NSMakePoint(x-rayon,y) toPoint:NSMakePoint(x+rayon,y)];
															 [NSBezierPath strokeLineFromPoint:NSMakePoint(x,y-rayon) toPoint:NSMakePoint(x,y+rayon)];}
#endif
};

#undef Z
#endif