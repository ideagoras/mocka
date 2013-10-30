//
//  ExamplesVerify.m
//  mocka
//
//  Created by Markus Gasser on 18.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExamplesCommon.h"
#import "AsyncService.h"


@interface ExamplesVerify : XCTestCase
@end

@implementation ExamplesVerify {
    NSMutableArray *mockArray;
}

#pragma mark - Setup

- (void)setUp {
    // we'll use this object in the examples
    mockArray = mock([NSMutableArray class]);
}


#pragma mark - Basic Verification

- (void)testVerifySimpleMethodCall {
    // you first use the mock  then verify that the desired method was called
    
    [mockArray removeAllObjects];
    
    verifyCall [mockArray removeAllObjects];
}

- (void)testVerifyWillFailIfMethodWasNeverCalled {
    // if you verify a method that has never been called it will fail
    
    ThisWillFail({
        verifyCall [mockArray removeAllObjects];
    });
}

- (void)testTooManyInvocationsAreIgnoredByVerify {
    // by default, verify will just check if a given method was at least called once
    // any more invocations are simply ignored
    
    [mockArray removeAllObjects];
    [mockArray removeAllObjects];
    
    verifyCall [mockArray removeAllObjects]; // too many invocations are ok
}

- (void)testYouCanUseMultipleVerifyTestsToRequireMultipleCalls {
    // if you wan to test that a method was called multiple times just repeat the verify call
    // (you can also use a modifier to verify, see below)
    
    [mockArray removeAllObjects];
    [mockArray removeAllObjects];
    
    verifyCall [mockArray removeAllObjects];
    verifyCall [mockArray removeAllObjects]; // verifyCall that the method was called at least 2 times
}

- (void)testVerifyingSomethingMultpleTimesThatWasCalledOnceWillFail {
    // from the example above follows that if you try to verify a call that was made only once
    // multiple times, the second verify will fail
    
    [mockArray removeAllObjects];
    
    verifyCall [mockArray removeAllObjects];
    
    ThisWillFail({
        verifyCall [mockArray removeAllObjects]; // multiple verifyCall calls will also expect multiple invocations
    });
}


#pragma mark - Verification With Arguments

- (void)testVerifyWillMatchOnEqualObjectArguments {
    // when you verify a method that has arguments verify will match equal arguments (isEqual: is used to compare)
    
    [mockArray addObject:@"Hello World"];
    
    verifyCall [mockArray addObject:@"Hello World"];
}

- (void)testVerifyWillFailForUnequalObjectArguments {
    // in contrast to above, if the arguments are not equal verify will not consider it a match
    
    [mockArray addObject:@"Hello World"];
    
    ThisWillFail({
        verifyCall [mockArray addObject:@"Goodbye"];
    });
}

- (void)testVerifyWillMatchOnEqualPrimitiveArguments {
    // when you verify a method that has arguments verify will match equal primitive arguments
    
    [mockArray objectAtIndex:10];
    
    verifyCall [mockArray objectAtIndex:10];
}

- (void)testVerifyWillFailForUnequalPrimitiveArguments {
    // in contrast to above, if the arguments are not equal verify will not consider it a match
    
    [mockArray objectAtIndex:10];
    
    ThisWillFail({
        verifyCall [mockArray objectAtIndex:0];
    });
}

- (void)testVerifyWillMatchOnEqualStructArguments {
    // when you verify a method that has arguments verify will match equal struct arguments (equal as compared by memcmp)
    
    [mockArray subarrayWithRange:NSMakeRange(10, 20)];
    
    verifyCall [mockArray subarrayWithRange:NSMakeRange(10, 20)];
}

- (void)testVerifyWillFailForUnequalStructArguments {
    // in contrast to above, if the arguments are not equal verify will not consider it a match
    
    [mockArray subarrayWithRange:NSMakeRange(10, 20)];
    
    ThisWillFail({
        verifyCall [mockArray subarrayWithRange:NSMakeRange(10, 10)];
    });
}


#pragma mark - Verify An Exact Number Of Invocations

- (void)testUseOnceToSpecifyExactlyOneInvocation {
    // by default verify will succeed if one *or more* calls which match are made
    // verify once will only succeed if there was *exactly* one call whitch matches
    // same as verify exactly(1)
    
    [mockArray count];
    [mockArray objectAtIndex:0];
    [mockArray objectAtIndex:1];
    
    verifyCall once [mockArray count];
    ThisWillFail({
        verifyCall once [mockArray objectAtIndex:anyInt()];
    });
}

- (void)testUseExactlyToSpecifyAnExactNumberOfInvocations {
    // using verify exactly(X) you can test that exactly X matching calls were made
    
    [mockArray objectAtIndex:0];
    [mockArray objectAtIndex:1];
    [mockArray count];
    
    verifyCall exactly(2) [mockArray objectAtIndex:anyInt()];
    ThisWillFail({
        verifyCall exactly(2) [mockArray count];
    });
}

- (void)testUseNeverToSpecifyNoMatchingCallsWereMade {
    // using verify never you can test that no matching call was made
    // same as verify exactly(0)
    
    [mockArray objectAtIndex:0];
    
    verifyCall never [mockArray count];
    ThisWillFail({
        verifyCall never [mockArray objectAtIndex:anyInt()];
    });
}


#pragma mark - Verify That No Actions Were Executed

- (void)testVerifyingNoInteractionsFailsIfAnyUnverifiedCallsWereMade {
    // using verify noInteractionsOn() or verifyCall noMoreInteractionsOn() you can
    // check if no unverified invocations were done on the specified mock
    
    verifyNoInteractionsOn(mockArray); // no interactions made, all is fine
    
    [mockArray count];
    ThisWillFail({
        verifyNoInteractionsOn(mockArray); // [mockArray count] is an unverified interaction
    });
}

- (void)testVerifyingNoInteractionsDoesNotFailForVerifiedInteractions {
    // verified interactions are not checked with noInteractionsOn() / noMoreInteractionsOn()
    // note: the two variants are synonyms, but noMoreInteractionsOn() reads better when
    //       previous verify calls were made
    
    [mockArray count];
    
    verifyCall [mockArray count];
    verifyNoMoreInteractionsOn(mockArray); // [mockArray count] was verified
}


#pragma mark - Ordered Verify

- (void)testThatVerifyingInOrderFailsIfCallIsMadeOutOfOrder {
    // by verifying in order you can check that a certain flow of methods is called one after another
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray addObject:@"Three"];
    
    ThisWillFail({
        verifyCall inOrder {
            [mockArray addObject:@"One"];
            [mockArray addObject:@"Three"];
            [mockArray addObject:@"Two"];   // <-- EVIL, out of order!
        };
    });
}

- (void)testThatVerifyingInOrderIgnoresUnverifiedCalls {
    // if you simply verify in order then 
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Unverified"];      // this is ignored
    [mockArray addObject:@"Two"];
    [mockArray addObject:@"Also unverified"]; // also this
    [mockArray addObject:@"Three"];
    
    verifyCall inOrder {
        [mockArray addObject:@"One"];
        [mockArray addObject:@"Two"];
        [mockArray addObject:@"Three"];
    };
}

- (void)testCanUseExactlyInOrderedVerify {
    // you can use exactly() as usual in ordered verify
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray addObject:@"Three"];
    [mockArray removeAllObjects];
    
    verifyCall inOrder {
        exactly(3) [mockArray addObject:anyObject()];
        [mockArray removeAllObjects];
    };
}

- (void)testLeadingUnverifiedMethodCallsAreIgnoredWithExactly {
    // also with exactly, leading method calls are just ignored
    
    [mockArray count];
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray addObject:@"Three"];
    [mockArray removeAllObjects];
    
    verifyCall inOrder {
        exactly(3) [mockArray addObject:anyObject()];
        [mockArray removeAllObjects];
    };
}

- (void)testInterleavedUnverifiedMethodCallsAreIgnoredWithExactly {
    // also with exactly, interleaving method calls are just ignored
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    [mockArray addObject:@"Three"];
    
    verifyCall inOrder {
        exactly(3) [mockArray addObject:anyObject()];
    };
}

- (void)testOrderedVerifyFailsIfExactlyFails {
    // exactly must also match exactly n objects in ordered verify
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    
    ThisWillFail({
        verifyCall inOrder {
            exactly(3) [mockArray addObject:anyObject()];
            [mockArray removeAllObjects];
        };
    });
}

- (void)testOrderedVerifyFailsForInterleavedCallsWhichShouldBeOrderedWithExactly {
    // if exactly skips calls while verifying, the skipped calls are not evaluated further
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    [mockArray addObject:@"Three"];
    
    ThisWillFail({
        verifyCall inOrder {
            exactly(3) [mockArray addObject:anyObject()];
            [mockArray removeAllObjects];
        };
    });
}

- (void)testSkippedCallsCanLaterStillBeVerified {
    // if exactly skips calls while verifying, the skipped calls can be verified outside of the inOrder
    
    [mockArray addObject:@"One"];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    [mockArray addObject:@"Three"];
    
    verifyCall inOrder {
        exactly(3) [mockArray addObject:anyObject()];
    };
    verifyCall [mockArray removeAllObjects];
}

- (void)testSkippedCallsCanLaterStillBeVerifiedOrdered {
    // skipped calls can even be verified ordered later
    
    [mockArray addObject:@"One"];
    [mockArray count];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    [mockArray addObject:@"Three"];
    
    verifyCall inOrder {
        exactly(3) [mockArray addObject:anyObject()];
    };
    
    verifyCall inOrder {
        [mockArray count];
        [mockArray removeAllObjects];
    };
}

- (void)testOrderingIsAlsoEnforcedWhenTestingSkippedCalls {
    // skipped calls can even be verified ordered later
    
    [mockArray addObject:@"One"];
    [mockArray count];
    [mockArray addObject:@"Two"];
    [mockArray removeAllObjects];
    [mockArray addObject:@"Three"];
    
    verifyCall inOrder {
        exactly(3) [mockArray addObject:anyObject()];
    };
    
    ThisWillFail({
        verifyCall inOrder {
            [mockArray removeAllObjects];
            [mockArray count];
        };
    });
}


#pragma mark - Verify with Timeout

- (void)testYouCanWaitForAsyncCalls {
    // call some async service
    [[AsyncService sharedService] callBlockDelayed:^{
        [mockArray removeAllObjects];
    }];
    
    // normal verify would fail, since the callback was not called yet at this point
    // therefore use timeout with verify
    verifyCallWithTimeout(0.1) [mockArray removeAllObjects];
}

- (void)testVerifyFailsAfterTheTimeoutExpires {
    // call some async service
    [[AsyncService sharedService] waitForTimeInterval:0.1 thenCallBlock:^{
        [mockArray removeAllObjects];
    }];
    
    // the timeout will expire before the async taks is executed, so this fails
    ThisWillFail({
        verifyCallWithTimeout(0.05) [mockArray removeAllObjects];
    });
}

- (void)testTimeoutWorksAlsoWithOtherModes {
    // call some async service
    [[AsyncService sharedService] callBlockDelayed:^{
        [mockArray removeAllObjects];
        [mockArray removeAllObjects];
    }];
    
    // you can also combine the timeout with verification modes like exactly(...)
    verifyCallWithTimeout(0.2) exactly(2) [mockArray removeAllObjects];
}

- (void)testTimeoutWorksDifferentWithNever {
    // call some async service
    [[AsyncService sharedService] callBlockDelayed:^{
        [mockArray removeAllObjects];
    }];
    
    verifyCall never [mockArray removeAllObjects]; // this does not fail, because the call is delayed
    
    // when using withTimeout(...) together with verify never then the semantics change a bit
    // in this case the call will wait the whole timeout before checking that no call was made
    ThisWillFail({ // because the call is made after 0.2s and we check after 0.5s
        verifyCallWithTimeout(0.5) never [mockArray removeAllObjects];
    });
}

- (void)testTimeoutAlsoWorksWithInOrder {
    // do some non-async calls
    [mockArray addObject:@1];
    [mockArray addObject:@2];
    
    // call some async service
    [[AsyncService sharedService] callBlockDelayed:^{
        [mockArray removeAllObjects];
    }];
    
    // normal verify would fail, since the callback was not called yet at this point
    // therefore use timeout with verify
    verifyCallWithTimeout(1.0) inOrder {
        [mockArray addObject:@1];
        [mockArray addObject:@2];
        [mockArray removeAllObjects];
    };
}

@end
