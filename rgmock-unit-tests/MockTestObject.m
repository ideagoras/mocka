//
//  MockTestObject.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "MockTestObject.h"
#import <objc/runtime.h>


static const NSUInteger CalledObjectsKey;

#define RegisterCall() MockTestRegisterCalledSelector(self, _cmd)
static void MockTestRegisterCalledSelector(MockTestObject *object, SEL selector) {
    NSMutableArray *calledSelectors = objc_getAssociatedObject(object, &CalledObjectsKey);
    if (calledSelectors == nil) {
        calledSelectors = [NSMutableArray array];
        objc_setAssociatedObject(object, &CalledObjectsKey, calledSelectors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [calledSelectors addObject:NSStringFromSelector(selector)];
}

NSArray* MockTestObjectCalledSelectors(MockTestObject *object) {
    NSMutableArray *calledSelectors = objc_getAssociatedObject(object, &CalledObjectsKey);
    return (calledSelectors != nil ? [calledSelectors copy] : @[]);
}


@implementation MockTestObject

#pragma mark - Void Return Calls

- (void)voidMethodCallWithoutParameters {
    RegisterCall();
}

- (void)voidMethodCallWithIntParam1:(int)i1 intParam2:(int)i2 {
    RegisterCall();
}

- (void)voidMethodCallWithObjectParam1:(id)o1 objectParam2:(id)o2 {
    RegisterCall();
}

- (void)voidMethodCallWithSelectorParam1:(SEL)s1 selectorParam2:(SEL)s2 {
    RegisterCall();
}

- (void)voidMethodCallWithCStringParam1:(char *)s1 cStringParam2:(char *)s2 {
    RegisterCall();
}

- (void)voidMethodCallWithPointerParam1:(void *)p1 pointerParam2:(void *)p2 {
    RegisterCall();
}


#pragma mark - Int Return Calls

- (int)intMethodCallWithoutParameters {
    RegisterCall();
    return 150;
}


#pragma mark - Object Return Calls

- (id)objectMethodCallWithoutParameters {
    RegisterCall();
    return @"Hello, beauty";
}


#pragma mark - Pointer Return Calls

- (int *)intPointerMethodCallWithoutParameters {
    RegisterCall();
    static int value = 0;
    return &value;
}


#pragma mark - Struct Return Calls

- (NSRange)rangeMethodCallWithoutParameters {
    RegisterCall();
    return NSMakeRange(10, 99);
}

@end
