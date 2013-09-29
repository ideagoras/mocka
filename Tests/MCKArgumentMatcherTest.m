//
//  MCKArgumentMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKArgumentMatcher.h"
#import "MCKBlockArgumentMatcher.h"
#import "MCKArgumentMatcherRecorder.h"


@interface MCKArgumentMatcherTest : XCTestCase
@end

@implementation MCKArgumentMatcherTest {
    MCKMockingContext *context;
    MCKArgumentMatcherRecorder *recorder;
}

#pragma mark - Setup

- (void)setUp {
    context = [MCKMockingContext contextForTestCase:self];
    recorder = [[MCKMockingContext currentContext] argumentMatcherRecorder];
}


#pragma mark - Test Cases

- (void)testThatObjectArgumentMatcherIsPassedDirectly {
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    id value = mck_registerObjectMatcher(matcher);
    XCTAssertTrue(matcher == value, @"Wrong object is returned");
}

- (void)testThatPrimitiveNumberMatcherIndexCanBeRetrievedAgain {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    UInt8 value = mck_registerPrimitiveNumberMatcher([[MCKBlockArgumentMatcher alloc] init]);
    
    // then
    XCTAssertEqual((int)mck_matcherIndexForArgumentBytes(&value, @encode(int)),
                   (int)([recorder.argumentMatchers count] - 1),
                   @"Wrong index returned");
}

- (void)testThatCStringMatcherIndexCanBeRetrievedAgain {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    char *value = mck_registerCStringMatcher([[MCKBlockArgumentMatcher alloc] init], MCKDefaultCStringBuffer);
    
    // then
    XCTAssertEqual((int)mck_matcherIndexForArgumentBytes(&value, @encode(char*)),
                   (int)([recorder.argumentMatchers count] - 1),
                   @"Wrong index returned");
}

- (void)testThatSelectorMatcherIndexCanBeRetrievedAgain {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    SEL value = mck_registerSelectorMatcher([[MCKBlockArgumentMatcher alloc] init]);
    
    // then
    XCTAssertEqual((int)mck_matcherIndexForArgumentBytes(&value, @encode(SEL)),
                   (int)([recorder.argumentMatchers count] - 1),
                   @"Wrong index returned");
}

- (void)testThatPointerMatcherIndexCanBeRetrievedAgain {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    void *value = mck_registerPointerMatcher([[MCKBlockArgumentMatcher alloc] init]);
    
    // then
    XCTAssertEqual((int)mck_matcherIndexForArgumentBytes(&value, @encode(void*)),
                   (int)([recorder.argumentMatchers count] - 1),
                   @"Wrong index returned");
}

- (void)testThatStructMatcherIndexCanBeRetrievedAgain {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    NSRange value = mck_registerStructMatcher([[MCKBlockArgumentMatcher alloc] init], NSRange);
    
    // then
    XCTAssertEqual((int)mck_matcherIndexForArgumentBytes(&value, @encode(NSRange)),
                   (int)([recorder.argumentMatchers count] - 1),
                   @"Wrong index returned");
}


@end
