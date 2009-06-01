/* vim: set sw=4 sts=4: -*- Mode: C; tab-width: 8; indent-tabs-mode: t; c-basic-offset: 4 -*- */
/*
   rsvg-path.h: Draw SVG paths

   Copyright (C) 2000 Eazel, Inc.
   Copyright (C) 2002 Dom Lachowicz <cinamod@hotmail.com>

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this program; if not, write to the
   Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.

   Author: Raph Levien <raph@artofcode.com>
*/

#ifndef DBL_EPSILON
/* 1e-7 is a conservative value.  it's less than 2^(1-24) which is
 * the epsilon value for a 32-bit float.  The regular value for this
 * with 64-bit doubles is 2^(1-53) or approximately 1e-16.
 */
# define DBL_EPSILON 1e-7
#endif

#ifndef RSVG_PATH_H
#define RSVG_PATH_H


//#include "rsvg-bpath-util.h"

//G_BEGIN_DECLS 

void rsvg_parse_path (const char *path_str, void *sender);

void rsvg_set_lineTo_callback( void (* f)(void * sender, float x, float y));
void rsvg_set_moveTo_callback( void (* f)(void * sender, float x, float y));
void rsvg_set_curveTo_callback( void (* f)(void * sender, float x1, float y1, float x2, float y2, float x3, float y3));
void rsvg_set_close_callback( void (* f)(void * sender));

//G_END_DECLS

#endif                          /* RSVG_PATH_H */
