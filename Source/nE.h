
#ifndef ncourbe_H
#define ncourbe_H
#define POINT2D
#include "point.h"
class nE {
public:
	point p;
	float uf;
	nE * next;
	nE * prev;
	static nE* newnE();
	void supnE();
	void supNexts();
	vec getDir() {
		vec n;
		if(next && prev) n= next->p-prev->p;
		else if(next) n= next->p-p;
		else n=p-prev->p;
		
		
		float l= n.magcarre();
		float fHalf = 0.5f*l; // quick way to calculate the inverse of the square root
		int i  = *(int*)&l;
		i = 0x5f3759df - (i >> 1);
		l = *(float*)&i;
		l = l*(1.5f - fHalf*l*l);
		n*=l;
		
		return n;
	}
};
#endif