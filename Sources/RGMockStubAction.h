//
//  RGMockStubAction.h
//  rgmock
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RGMockStubAction <NSObject>

- (void)performWithInvocation:(NSInvocation *)invocation;

@end