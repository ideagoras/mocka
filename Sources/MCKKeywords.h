//
//  MCKKeywords.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKMockingContext.h"


#pragma mark - Verifying

// Safe syntax
#define mck_verify [mck_updatedContext() updateContextMode:MockaContextModeVerifying];

// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
#undef verify // under Mac OS X this macro defined already (in /usr/include/AssertMacros.h)
#define verify mck_verify
#endif


#pragma mark - Stubbing

// Safe syntax
#define mck_whenCalling [mck_updatedContext() updateContextMode:MockaContextModeStubbing];
#define mck_orCalling   ; mck_whenCalling
#define mck_thenDo ;
#define mck_andDo  mck_thenDo

// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
#define whenCalling mck_whenCalling
#define orCalling   mck_orCalling
#define thenDo mck_thenDo
#define andDo  mck_andDo
#endif