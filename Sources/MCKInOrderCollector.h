//
//  MCKInOrderCollector.h
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKVerificationResultCollector.h"


@interface MCKInOrderCollector : NSObject <MCKVerificationResultCollector>

@end


// safe syntax
#define mck_verifyCallsInOrder \
   _mck_beginVerifyWithTimeout(self, _MCKCurrentLocation(), 0.0);\
    mck_beginVerifyGroupCallsUsingCollector([[MCKInOrderCollector alloc] init])

#define mck_inOrder mck_beginVerifyGroupCallsUsingCollector([[MCKInOrderCollector alloc] init])

// nice syntax
#ifndef MCK_DISABLE_NICE_SYNTAX

    #define verifyCallsInOrder  mck_verifyCallsInOrder
    #define inOrder mck_inOrder

#endif
