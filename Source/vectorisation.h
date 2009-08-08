/*
 *  vectorisation.h
 *  nouvelleCourbe
 *
 *  Created by iBook G4 on 23/09/2006.
 *  Copyright 2006 Gael Ferre. All rights reserved.
 *
 */
#ifndef vectorisation_H
#define vectorisation_H
#include "nE.h"
#include "moult.h"
void lisse(nE* s,float marge);
void vectoriz(nE* s,Moult * result,float marge);
bool vectoriz(nE* start,nE* end,point * curve,float margec,
					int ntest=8,int nit=15,bool lock1=false,bool lock2=false);
#endif