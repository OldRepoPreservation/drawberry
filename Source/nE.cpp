

#include "nE.h"
#include <stdlib.h>

nE* pillnE=NULL;
nE* nE::newnE() {
	nE * e;
	if(pillnE) {e= pillnE; pillnE=e->next;}
	else e= (nE*)malloc(sizeof(nE));
	return e;
}
void nE::supnE() {
	if(next) next->prev=prev;
	if(prev) prev->next=next;
	next=pillnE;
	pillnE=this;
}

void nE::supNexts() {
	if(prev) prev->next=NULL;
	nE * last=this;
	while(last->next) last=last->next;
	last->next=pillnE;
	pillnE=this;
}