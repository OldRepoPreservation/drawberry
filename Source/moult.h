/*
 *  moult.h
 *  Equation
 *
 *  Created by iBook G4 on 12/03/2006.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef MOULT_H
#define MOULT_H
#include <stdlib.h>
struct ObjPtr;
extern ObjPtr * pileLibre;
struct ObjPtr {
	ObjPtr 	*	next;
	ObjPtr  *	prev;
	void	*	ptr;
	
//protected :
	inline void insert_apres(ObjPtr* o) {
		next->prev=o;
		o->next=next;
		o->prev=this;
		next=o;
	}
	inline void insert_avant(ObjPtr* o) {
		prev->next=o;
		o->next=this;
		o->prev=prev;
		prev=o;
	}
//public:
	inline void suprime() {
		prev->next=next;
		next->prev=prev;
		next=pileLibre;
		pileLibre=this;
	}
};

typedef bool (*classDansMoult) (void*,void*,void*); // > croissant , < decroissant

class Moult :public ObjPtr {
public:
#define prems		next
#define	der			prev
	unsigned int	count;
	Moult() {
		ptr=NULL;
		prems=der=(ObjPtr*)this;
		count=0;
	}
	inline void init() 
	{
		ptr=NULL;
		prems=der=(ObjPtr*)this;
		count=0;
	}
	~Moult() {
		if(prems!= this) {
			der->next=pileLibre;
			pileLibre=prems;}
	}
#ifdef FALLOC_H
	static Moult * alloc() {
		static Falloc<Moult> f;
		Moult * m=f.alloc();
		m->ptr=NULL;
		m->prems=m->der=m;
		m->count=0;
		return m;
	}
	void release() {
		if(prems!= this) {
			der->next=pileLibre;
			pileLibre=prems;}
		frelease(this);
	}
#endif
	inline void add(void* ptr) {
		ObjPtr * o=newObjPtr();
		o->ptr=ptr;
		insert_avant(o);
	}
	inline void push(void* ptr) {
		ObjPtr * o=newObjPtr();
		o->ptr=ptr;
		insert_apres(o);
	}
	inline void* pop() {
		void * r=prems->ptr;
		if(r) { prems->suprime();count--;}
		return r;
	}
	inline void* poplast() {
		void * r=der->ptr;
		if(r) { der->suprime();count--;}
		return r;
	}
	inline void supall() {
		if(prems== this) return;
		der->next=pileLibre;
		pileLibre=prems;
		prems=der=this;
		count=0;
	}
	inline void supall(void *ptr) {
		ObjPtr * o=prems;
		while(o->ptr) {
			if(o->ptr==ptr) {
				o=o->prev;
				o->next->suprime();count--;
			}
			o=o->next;
		}
	}
	inline void sup(void* ptr) {
		ObjPtr * o=prems;
		while(o->ptr) {
			if(o->ptr==ptr) {
				o->suprime();
				count--;
				return;
			}
			o=o->next;
		}
	}
	inline void remplace(void* ptr,void *nouvptr) {
		ObjPtr * o=prems;
		while(o->ptr) {
			if(o->ptr==ptr) {
				o->ptr=nouvptr;
				return;
			}
			o=o->next;
		}
	}
	inline bool existe(void * ptr) {
		ObjPtr * o=prems;
		while(o->ptr) {
			if(o->ptr==ptr) {
				return true;
			}
			o=o->next;
		}
		return false;
	}
	void addList(Moult * m) {
		ObjPtr *o=m->prems;
		while(o->ptr) {
			add(o->ptr);
			o=o->next;
		}
	}

	void insert_et_class(void *ptr,classDansMoult class__PTR_apres_OBJ__CONTEXT,void* context=NULL) {
		ObjPtr * o=newObjPtr(),*c=prems;
		o->ptr=ptr;
		while( c->ptr && class__PTR_apres_OBJ__CONTEXT(ptr,c->ptr,context)) c=c->next;
		c->insert_avant(o);
	}
	void reclass(classDansMoult methodReclass,void * context=NULL) 	{
		ObjPtr * big = prems,*c,*cc;
		void * sp;

		while( c= big->next) {
			if(c->ptr == NULL) return;
			cc= big;
			big=c;
			if(methodReclass(c->ptr,cc->ptr,context)) 
				continue; // rien a classer on pass
			for(;;) {
				sp=c->ptr;c->ptr=cc->ptr;cc->ptr=sp;
				c=cc;
				cc=cc->prev;
				if(cc->ptr == NULL || methodReclass(c->ptr,cc->ptr,context)) 
					break;
			}
		}
	}
//private:
	inline ObjPtr* newObjPtr() {
		ObjPtr *o;
		if(pileLibre) {
			o=pileLibre;
			pileLibre=pileLibre->next;
		}else {
			o=(ObjPtr*)malloc(sizeof(ObjPtr));
		}
		count++;
		return o;
	}

	inline void * last() {
		return der->ptr;
	}
	inline void * first() {
		return prems->ptr;
	}
};


template<class CAST>
class Enum {
public:
	ObjPtr *o;
	Moult * m;
	

	inline Enum(Moult *mm) {
		m=mm;
		o=(ObjPtr*)mm;
	}
	inline CAST* cur() {
		return (CAST*)o->ptr;
	}
	inline CAST* next() {// null pour le dernier
		o=o->next;
		return (CAST*)o->ptr;
	}
	inline CAST* prev() {
		o=o->prev;
		return (CAST*)o->ptr;
	}
	inline void rst() {
		o=(ObjPtr*)m;
	}
	inline void insert_apres(void * ptr) {
		ObjPtr * O=m->newObjPtr();
		O->ptr=ptr;
		o->insert_apres(O);
		o=O;
	}
	inline void insert_avant(void * ptr) {
		ObjPtr * O=m->newObjPtr();
		O->ptr=ptr;
		o->insert_avant(O);
	}
	inline void sup() {
		o->suprime();
		o=o->prev;
		m->count--;
	}
};
#define foreach(type,var,moult) for(Enum<type> zE(moult);type* var= zE.next();)
#endif