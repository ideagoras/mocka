//
//  MCKSpyIntegrationTest.m
//  mocka
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Mocka.h"

#import "TestExceptionUtils.h"
#import "TestObject.h"
#import "CategoriesTestClasses.h"


@interface MCKSpyIntegrationTest : XCTestCase
@end

@implementation MCKSpyIntegrationTest {
    TestObject *object;
}


#pragma mark - Setup

- (void)setUp {
    [super setUp];
    object = spy([[TestObject alloc] init]);
    [[MCKMockingContext currentContext] setFailureHandler:[[MCKExceptionFailureHandler alloc] init]];
}


#pragma mark - Test Simple Verify

- (void)testThatVerifySucceedsForSimpleCall {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
}

- (void)testThatVerifyFailsForMissingMethodCall {
    // then
    AssertFails({
        verifyCall [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testThatVerifySucceedsForTwoCallsAndTwoVerifies {
    // when
    [object voidMethodCallWithoutParameters];
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithoutParameters];
    });
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 2);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 1);
}

- (void)testThatVerifyFailsIfAppliedTwiceToOneCall {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithoutParameters];
    });
    AssertFails({
        verifyCall [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
}


#pragma mark - Test Verify with handlers

- (void)testThatVerifyNeverFailsWhenCallWasMade {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        verifyCall never [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
}

- (void)testThatVerifyNeverSucceedsWhenNoCallWasMade {
    AssertDoesNotFail({
        verifyCall never [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testThatExactlyOneSucceedsWhenOneCallWasMade {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verifyCall exactly(1) [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
}

- (void)testThatExactlyOneFailsWhenNoCallWasMade {
    AssertFails({
        verifyCall exactly(1) [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testThatExactlyOneFailsWhenMultipleCallsWereMade {
    // when
    [object voidMethodCallWithoutParameters];
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        verifyCall exactly(1) [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 2);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 1);
}


#pragma mark - Test Verify with Arguments

- (void)testThatVerifySucceedsForMatchingObjectArguments {
    // when
    [object voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithObjectParam1:objectParam2:), 0);
}

- (void)testThatVerifyFailsForNonMatchingObjectArguments {
    // when
    [object voidMethodCallWithObjectParam1:@"World" objectParam2:@"Hello"];
    
    // then
    AssertFails({
        verifyCall [object voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithObjectParam1:objectParam2:), 0);
}

- (void)testThatVerifySucceedsForMatchingPrimitiveArguments {
    // when
    [object voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithIntParam1:2 intParam2:45];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithIntParam1:intParam2:), 0);
}

- (void)testThatVerifyFailsForNonMatchingPrimitiveArguments {
    // when
    [object voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertFails({
        verifyCall [object voidMethodCallWithIntParam1:0 intParam2:45];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithIntParam1:intParam2:), 0);
}


#pragma mark - Test Verify with Argument Matchers

- (void)testThatVerifySucceedsForAnyIntegerWithAnyIntMatcher {
    // when
    [object voidMethodCallWithIntParam1:10 intParam2:20];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()];
    });
}

- (void)testThatVerifySucceedsForEdgeCasesWithAnyIntMatcher {
    // when
    [object voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [object voidMethodCallWithIntParam1:NSIntegerMin intParam2:NSIntegerMax];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()];
        verifyCall [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()];
    });
}


#pragma mark - Test Stubbing

- (void)testThatUnstubbedMethodsReturnOriginalValues {
    TestObject *referenceObject = [[TestObject alloc] init];
    
    XCTAssertEqualObjects([object objectMethodCallWithoutParameters], [referenceObject objectMethodCallWithoutParameters], @"Should return reference value for unstubbed object return");
    XCTAssertEqual([object intMethodCallWithoutParameters], [referenceObject intMethodCallWithoutParameters], @"Should return reference value for unstubbed int return");
    XCTAssertEqual([object intPointerMethodCallWithoutParameters], [referenceObject intPointerMethodCallWithoutParameters], @"Should return reference value for unstubbed pointer return");
    XCTAssertTrue(NSEqualRanges([object rangeMethodCallWithoutParameters], [referenceObject rangeMethodCallWithoutParameters]), @"Should return reference value for unstubbed range");
}

- (void)testThatStubbedReturnValueIsReturned {
    // given
    whenCalling [object objectMethodCallWithoutParameters] thenDo returnValue(@"Hello World");
    
    // when
    id result = [object objectMethodCallWithoutParameters];
    
    // then
    XCTAssertEqualObjects(result, @"Hello World", @"Wrong object value returned");
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testMultipleStubActions {
    // given
    __block NSString *marker = nil;
    whenCalling [object objectMethodCallWithoutParameters] thenDo {
        performBlock(^(NSInvocation *inv) {
            marker = @"called";
        });
        returnValue(@20);
    };
    
    // then
    XCTAssertEqualObjects([object objectMethodCallWithoutParameters], @20, @"Wrong return value");
    XCTAssertEqualObjects(marker, @"called", @"Marker was not set or wrongly set");
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testThatSubsequentStubbingsDontInterfere {
    // given
    TestObject *object1 = spy([[TestObject alloc] init]);
    TestObject *object2 = spy([[TestObject alloc] init]);
    TestObject *object3 = spy([[TestObject alloc] init]);
    TestObject *object4 = spy([[TestObject alloc] init]);
    TestObject *refObject = [[TestObject alloc] init];
    __block NSString *marker = nil;
    
    // when
    whenCalling [object1 objectMethodCallWithoutParameters] thenDo returnValue(@"First Object");
    whenCalling [object2 objectMethodCallWithoutParameters] thenDo returnValue(@"Second Object");
    whenCalling [object3 objectMethodCallWithoutParameters] thenDo performBlock(^(NSInvocation *inv) {
        marker = @"Third Object";
    });
    
    [object4 objectMethodCallWithoutParameters];
    
    
    // then
    XCTAssertEqualObjects([object1 objectMethodCallWithoutParameters], @"First Object", @"Wrong return value for object");
    XCTAssertNil(marker, @"Marker was set too early");
    
    XCTAssertEqualObjects([object2 objectMethodCallWithoutParameters], @"Second Object", @"Wrong return value for object");
    XCTAssertNil(marker, @"Marker was set too early");
    
    XCTAssertNil([object3 objectMethodCallWithoutParameters], @"Wrong return value for object");
    XCTAssertEqualObjects(marker, @"Third Object", @"Marker was not set or wrongly set");
    
    XCTAssertEqualObjects([object4 objectMethodCallWithoutParameters], [refObject objectMethodCallWithoutParameters], @"Non-stubbed call was suddenly stubbed");
    
    AssertNumberOfInvocations(object1, 0);
    AssertNumberOfInvocations(object2, 0);
    AssertNumberOfInvocations(object3, 0);
    
    AssertNumberOfInvocations(object4, 2);
    AssertSelectorCalledAtIndex(object4, @selector(objectMethodCallWithoutParameters), 0);
    AssertSelectorCalledAtIndex(object4, @selector(objectMethodCallWithoutParameters), 1);
}

- (void)testThatLaterStubbingsComplementOlderStubbingsOfSameInvocation {
    // given
    __block NSString *marker = nil;
    whenCalling [object objectMethodCallWithoutParameters] thenDo {
        performBlock(^(NSInvocation *inv) {
            marker = @"called";
        });
        returnValue(@20);
    };
    
    // when
    whenCalling [object objectMethodCallWithoutParameters] thenDo returnValue(@30);
    
    // then
    XCTAssertEqualObjects([object objectMethodCallWithoutParameters], @30, @"Wrong return value for object");
    XCTAssertEqualObjects(marker, @"called", @"Marker was not set");
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testThatMultipleStubbingsCanBeCombined {
    // given
    TestObject *object1 = spy([[TestObject alloc] init]);
    TestObject *object2 = spy([[TestObject alloc] init]);
    
    // when
    whenCalling {
        [object1 objectMethodCallWithoutParameters];
        [object2 objectMethodCallWithoutParameters];
    };
    thenDo returnValue(@10);
    
    // then
    XCTAssertEqualObjects([object1 objectMethodCallWithoutParameters], @10, @"Wrong return value for object");
    XCTAssertEqualObjects([object2 objectMethodCallWithoutParameters], @10, @"Wrong return value for object");
    
    AssertNumberOfInvocations(object1, 0);
    AssertNumberOfInvocations(object2, 0);
}

- (void)testStubbingArray {
    // given
    NSMutableArray *array = spy([NSMutableArray array]);
    
    whenCalling [array count] thenDo {
        performBlock(^(NSInvocation *inv) { [self description]; });
        returnValue(10);
    };
    
    // then
    XCTAssertEqual((int)[array count], (int)10, @"[array count] stub does not work");
}


#pragma mark - Test Stubbing with Argument Matchers

- (void)testThatStubMatchesCallForSimpleIntegersWithAnyIntMatcher {
    // when
    __block BOOL methodMatched = NO;
    whenCalling [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]; thenDo performBlock(^(NSInvocation *inv) {
        methodMatched = YES;
    });
    
    // then
    [object voidMethodCallWithIntParam1:10 intParam2:20];
    XCTAssertTrue(methodMatched, @"Method was not matched");
}

- (void)testThatStubMatchesCallsForEdgeCasesWithAnyIntMatcher {
    // when
    __block int invocationCount = 0;
    whenCalling [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]; thenDo performBlock(^(NSInvocation *inv) {
        invocationCount++;
    });
    
    // then
    [object voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [object voidMethodCallWithIntParam1:NSIntegerMax intParam2:NSIntegerMin];
    XCTAssertEqual(invocationCount, 2, @"Not all egde cases match");
}


#pragma mark - Test Stubbing and Verifying of Category Methods

- (void)testStubbingAndVerifyingOfCategoryMethodOnMockedClass {
    // given
    CategoriesTestMockedClass *spy = spy([[CategoriesTestMockedClass alloc] init]);
    
    __block BOOL called = NO;
    whenCalling [spy categoryMethodInMockedClass] thenDo performBlock(^(NSInvocation *inv) {
        called = YES;
    });
    
    [spy categoryMethodInMockedClass];
    
    verifyCall [spy categoryMethodInMockedClass];
    XCTAssertTrue(called, @"Should have been called");
}

- (void)testStubbingAndVerifyingOfCategoryMethodOnMockedClassSuperclass {
    // given
    CategoriesTestMockedClass *spy = spy([[CategoriesTestMockedClass alloc] init]);
    
    __block BOOL called = NO;
    whenCalling [spy categoryMethodInMockedClassSuperclass] thenDo performBlock(^(NSInvocation *inv) {
        called = YES;
    });
    
    [spy categoryMethodInMockedClassSuperclass];
    
    verifyCall [spy categoryMethodInMockedClassSuperclass];
    XCTAssertTrue(called, @"Should have been called");
}

@end
