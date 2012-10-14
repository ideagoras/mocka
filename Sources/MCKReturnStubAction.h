//
//  MCKReturnStubAction.h
//  mocka
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKStubAction.h"


@interface MCKReturnStubAction : NSObject <MCKStubAction>

+ (id)returnActionWithValue:(id)value;
- (id)initWithValue:(id)value;

@property (nonatomic, readonly) id returnValue;

@end


// Mocking Syntax
#define mck_returnValue(val) [mck_currentContext() addStubAction:mck_returnValueAction(val)]
#define mck_returnStruct(strt) [mck_currentContext() addStubAction:mck_returnStructAction(strt)]

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define returnValue(val) mck_returnValue(val)
#define returnStruct(val) mck_returnStruct(val)
#endif

#define mck_returnValueAction(val) [MCKReturnStubAction returnActionWithValue:mck_createGenericValue(@encode(typeof(val)), val)]
#define mck_returnStructAction(strt) [MCKReturnStubAction returnActionWithValue:[NSValue valueWithBytes:&strt objCType:@encode(typeof(strt))]]
id mck_createGenericValue(const char *type, ...);
