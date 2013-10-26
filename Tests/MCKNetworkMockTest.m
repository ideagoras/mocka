//
//  MCKNetworkMockTest.m
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKNetworkMock.h"
#import "MCKNetworkMock_Private.h"
#import "MCKNetworkRequestMatcher.h"
#import "MCKAnyArgumentMatcher.h"
#import "MCKReturnStubAction.h"
#import "NSInvocation+MCKArgumentHandling.h"

#import "FakeMockingContext.h"
#import "NSInvocation+TestSupport.h"


@interface MCKNetworkMockTest : XCTestCase @end
@implementation MCKNetworkMockTest {
    MCKNetworkMock *networkMock;
    FakeMockingContext *mockingContext;
}

#pragma mark - Setup

- (void)setUp {
    [OHHTTPStubs removeAllStubs];
    
    mockingContext = [FakeMockingContext fakeContext];
    networkMock = [[MCKNetworkMock alloc] initWithMockingContext:mockingContext];
}

- (void)tearDown {
    networkMock = nil;
}


#pragma mark - Test GET() Calls

- (void)testThatGETReturnsRequestMatcher {
    XCTAssertTrue([networkMock.GET(@"http://www.google.ch") isKindOfClass:[MCKNetworkRequestMatcher class]],
                  @"Did not return a request matcher");
}

- (void)testThatGETSetsMethodOnMatcher {
    // when
    MCKNetworkRequestMatcher *matcher = networkMock.GET([NSURL URLWithString:@"http://www.google.ch"]);
    
    // then
    XCTAssertEqualObjects(matcher.HTTPMethod, @"GET", @"Wrong URL passed to matcher");
}

- (void)testThatGETWithURLSetsURLOnMatcher {
    // when
    MCKNetworkRequestMatcher *matcher = networkMock.GET([NSURL URLWithString:@"http://www.google.ch"]);
    
    // then
    XCTAssertEqualObjects(matcher.URL, [NSURL URLWithString:@"http://www.google.ch"], @"Wrong URL passed to matcher");
}

- (void)testThatGETWithStringSetsURLOnMatcher {
    // when
    MCKNetworkRequestMatcher *matcher = networkMock.GET(@"http://www.google.ch");
    
    // then
    XCTAssertEqualObjects(matcher.URL, [NSURL URLWithString:@"http://www.google.ch"], @"Wrong URL passed to matcher");
}

- (void)testThatGETRegistersCallOnContextWithMatcher {
    // when
    MCKNetworkRequestMatcher *matcher = networkMock.GET(@"http://www.google.ch");
    
    // then
    XCTAssertTrue([mockingContext.handledInvocations count] == 1, @"Wrong invocation count");
    
    NSInvocation *invocation = mockingContext.handledInvocations[0];
    XCTAssertEqualObjects(invocation.target, networkMock, @"Wrong invocation target");
    XCTAssertEqual(invocation.selector, @selector(handleNetworkRequest:), @"Wrong invocation selector");
    XCTAssertEqualObjects([invocation objectParameterAtIndex:0], matcher, @"Wrong invocation argument");
}


#pragma mark - Test Request Handling

- (void)testThatHasResponseForRequestReturnsFalseIfNoRequestStubbed {
    // given
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.ch"]];
    
    // no request is stubbed
    
    // then
    XCTAssertFalse([networkMock hasResponseForRequest:request], @"Should not have a response for this request");
}

- (void)testThatHasResponseForRequestReturnsTrueIfOneRequestStubbed {
    // given
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.ch"]];
    
    // add a stubbing that matches always
    [mockingContext beginStubbing];
    [mockingContext handleInvocation:[networkMock handlerInvocationForRequest:[[MCKAnyArgumentMatcher alloc] init]]];
    
    // then
    XCTAssertTrue([networkMock hasResponseForRequest:request], @"Should have a response for this request");
}

- (void)testThatResponseForRequestReturnsStubbedResponse {
    // given
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.ch"]];
    OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:@{}];
    
    // add a stubbing that matches always
    [mockingContext beginStubbing];
    [mockingContext handleInvocation:[networkMock handlerInvocationForRequest:[[MCKAnyArgumentMatcher alloc] init]]];
    [mockingContext addStubAction:[[MCKReturnStubAction alloc] initWithValue:response]];
    
    // then
    XCTAssertEqualObjects([networkMock responseForRequest:request], response, @"Wrong response returned");
}

@end
