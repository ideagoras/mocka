//
//  MCKNetworkMock_Private.h
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKNetworkMock.h"
#import "OHHTTPStubs.h"


@interface MCKNetworkMock ()

@property (nonatomic, readonly, weak) MCKMockingContext *customMockingContext;
@property (nonatomic, readonly, weak) id<OHHTTPStubsDescriptor> stubsDescriptor;

- (NSInvocation *)handlerInvocationForRequest:(id)request;
- (id)handleNetworkRequest:(NSURLRequest *)request;

- (BOOL)hasResponseForRequest:(NSURLRequest *)request;
- (OHHTTPStubsResponse *)responseForRequest:(NSURLRequest *)request;

- (OHHTTPStubsResponse *)responseForReturnValue:(id)value;

@end
