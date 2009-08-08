/*
 *  vectorisation.cpp
 *  nouvelleCourbe
 *
 *  Created by iBook G4 on 23/09/2006.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#include "vectorisation.h"
void lisse(nE* start,float marge) {
	if(start->next == NULL) return;
	marge*=marge;
	bool ok;
	
	nE* insert,*p0,*p1,*p2,*p3;
	
	do {
		ok=true;
		
		for(p0=NULL,p1=start,p2=p1->next,p3=p2->next; p2 ;p0=p1,p1=p2,p2=p3) {
			p3= p2->next;
			if(p1->p.magcarre(p2->p) < marge)
					continue;
			
			ok=false;
			
			insert= nE::newnE();
			insert->prev=p1;
			insert->next=p2;
			p1->next=insert;
			p2->prev=insert;
			
			if(p0 && p3) {
				vec v1= p2->p - p0->p,
					v2= p1->p - p3->p,
					vi= p2->p - p1->p;
				float t=v1.x*v2.y-v1.y*v2.x;
				if(t > 0.00001 || t < -0.00001) { 
					t= (vi.x*v2.y-vi.y*v2.x)/t;
					v1*=t;// p1+v1*t == intersection( p0+v1 , p3+v2 )
					t= v1.dot(vi)/vi.magcarre();
					if(t> 0 && t <1) {
						insert->p= (p1->p + p2->p)*0.25 + (p1->p+v1)*0.5;
						continue;
					}
				}
			}
			insert->p= (p1->p + p2->p)*0.5;
		}
	}while(!ok);
}

void vectoriz(nE* start,Moult * result,float marge)	{
	if(start->next==NULL) return; 
	result->add(new point(start->p));
	marge*=marge;
	nE * end=start;
	
	point curve[4];
	point bk[2];
	vec stv;
	
	while(1) {
		curve[0]= start->p;
		stv=start->getDir()+curve[0];
		while(1) {
			end=end->next;
			curve[1]= stv;
			curve[3]= end->p;
			curve[2]= curve[3]-end->getDir();
			
			if(!vectoriz(start,end,curve,marge,8,100,true,true)) {
				end=end->prev;
				curve[1]=bk[0];
				curve[2]=bk[1];
				curve[3]=end->p;
			//	vectoriz(start,end,courbe,marge*0.25,16,500,true,true);// tante d' avoir un meilleur resultat, je c pas si ca vraimant de l' effet.
				break;
			}else if(end->next==NULL) break;
			bk[0]=curve[1];bk[1]=curve[2];
		}
		for(int i=1;i!=4;i++) {
			result->add(new point(curve[i]));
		}
		if(end->next==NULL) break;
		start=end;
	}
}


bool vectoriz(nE* start,nE* end, point * curve,float margec,int ntest,int nit,bool lock1,bool lock2) {
	//start et end, les points repere de debut et fin sur la chaine de points a vectoriser
	// courbe[4], le resultat trouvé, on peut donner une estimation de la position des points de controle pour aider,
	//	ou une contrainte de direction en appliquant lock1 et/ou 2
	// margec, la distance max d' erreur accepté
	// ntest, le nombre de point temoins a utilisé
	// nit , nombre d' itinération maximum avant de decrété que la qu' aucunes courbe possible est capable de satisfaire les contrainte
	// lock1 & 2 , si le point de control 1 et 2 doivent etre contrait a tenir sur une droite 
	//	ou false s' il peuvent se positionner n'import ou
	point zt[ntest];
	float r[ntest];
	point mc[ntest],c,h;
	nE		*e,*se;
	float disc[ntest];
	vec v1,v2,v,l1,l2;
	
	for(int i=0;i!= ntest;i++) {
		r[i]= ((float)i+1)/((float)ntest+2);
	}
		
	if(lock1)l1=curve[1]-curve[0];
	if(lock2)l2=curve[2]-curve[3];
	
	float t,t1,d,dec=5.0f/(float)ntest;
	
	for(int it=0;;it++) {
		for(int i=0;i!=ntest;i++) { // trouve les points temoins
			t=r[i];
			t1 = 1.0f - t; 
			zt[i]= curve[0]*(t1*t1*t1) +curve[1]*(3*t*t1*t1) +curve[2]*(3*t*t*t1) +curve[3]*(t*t*t);
		//	mc[i]=start->p;
			disc[i]=MAXFLOAT;// start->p.magcarre(zt[i]);
		}
		e= start;
		se=NULL;
		int j=0;
		int okpass=0;
		for(;;) {
			//for(int i=j;i!=ntest && i!= j+2;i++) {// trouve les points les plus proches des points temoins
				c= e->next->p-e->p;
				h=zt[j]-e->p;
				d= h.dot(c)/c.magcarre();
				if(d>1) d=1.0f;
				else if(d<0) d=0;
				c*=d;
				d= h.magcarre(c);
				if(d < disc[j]) {
					disc[j]=d;
					mc[j]=e->p+c;
					if(se==NULL)se=e;
					if(okpass==j && d< margec)okpass++;
				}else if(se) {
					j++;
					if(j==ntest) break;
					e=se;
					se=NULL;
				}
				if(e->next==end) {
					j++;
					if(j==ntest) break;
					if(se==NULL) e=start;
					else {
						e=se;
						se=NULL;
					}
				}else e=e->next;
			//}
		}
		if(okpass==ntest) return true;// ok c bon tt les distances des points temoins sont inferieur a la marge d' erreur
		if(it== nit)  // pas bon on a rien trouver, nombre d' iteniration trop courte ou impossible
			return false;

		v1.zero();
		v2.zero();
		for(int i=0;i!=ntest;i++) {// deplace les vecteurs de derivation pour ce rapprocher des points temoins
			v=mc[i]-zt[i];
			v1+=v*(dec*(1.0f-r[i]));
			v2+=v*(dec*r[i]);
		}
#if 1
		if(lock1) {float prj=v1.dot(l1)/l1.magcarre(); v1= l1*(prj<0?0:prj);}
		if(lock2) {float prj=v2.dot(l2)/l2.magcarre(); v2= l2*(prj<0?0:prj);}
#else
		if(lock1) {float prj=v1.dot(l1)/l1.magcarre(); v1= l1*prj;}
		if(lock2) {float prj=v2.dot(l2)/l2.magcarre(); v2= l2*prj;}
#endif
		curve[1]+=v1;
		curve[2]+=v2;
	}
	
}