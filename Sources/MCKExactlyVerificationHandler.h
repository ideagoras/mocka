//
//  MCKExactlyVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKVerificationHandler.h"


@interface MCKExactlyVerificationHandler : NSObject <MCKVerificationHandler>

+ (id)exactlyHandlerWithCount:(NSUInteger)count;
- (id)initWithCount:(NSUInteger)count;

@end


// Mocking Syntax
#define mck_exactly(count) mck_setVerificationHandler([MCKExactlyVerificationHandler exactlyHandlerWithCount:(count)])
#define mck_once mck_exactly(1)

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define exactly(count) mck_exactly((count))
#define once mck_once
#endif