//
//  MCKVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKVerificationResult.h"
#import "MCKInvocationPrototype.h"


@protocol MCKVerificationHandler <NSObject>

- (MCKVerificationResult *)verifyInvocations:(NSArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype;

- (BOOL)mustAwaitTimeoutForFailure;
- (BOOL)failsFastDuringTimeout;

@end


extern void _mck_setVerificationHandler(id<MCKVerificationHandler> handler);
