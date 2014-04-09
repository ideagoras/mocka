//
//  MCKBlockArgumentMatcher.m
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKBlockArgumentMatcher.h"

#import "MCKValueSerialization.h"


@implementation MCKBlockArgumentMatcher

#pragma mark - Initialization

+ (instancetype)matcherWithBlock:(BOOL(^)(id candidate))block {
    return [[self alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(BOOL(^)(id candidate))block {
    if ((self = [super init])) {
        _matcherBlock = [block copy];
    }
    return self;
}


#pragma mark - Candidate Matching

- (BOOL)matchesCandidate:(id)candidate {
    return (self.matcherBlock != nil ? self.matcherBlock(candidate) : YES);
}

@end


#pragma mark - Mocking Syntax

#define CREATE_MATCHER(BLOCK, DECODER) \
    [MCKBlockArgumentMatcher matcherWithBlock:^BOOL(id candidate) {\
        return ((BLOCK) != nil ? (BLOCK)([candidate DECODER]) : YES);\
    }]

id mck_objectMatching(BOOL(^block)(id candidate)) {
    return MCKRegisterMatcher((CREATE_MATCHER(block, nonretainedObjectValue)), id);
}

char mck_integerMatching(BOOL(^block)(SInt64 candidate)) {
    return MCKRegisterMatcher(CREATE_MATCHER(block, longLongValue), char);
}

char mck_unsignedIntegerMatching(BOOL(^block)(UInt64 candidate)) {
    return MCKRegisterMatcher(CREATE_MATCHER(block, unsignedLongLongValue), char);
}

float mck_floatMatching(BOOL(^block)(float candidate)) {
    return MCKRegisterMatcher(CREATE_MATCHER(block, floatValue), float);
}

double mck_doubleMatching(BOOL(^block)(double candidate)) {
    return MCKRegisterMatcher(CREATE_MATCHER(block, doubleValue), double);
}

BOOL mck_boolMatching(BOOL(^block)(BOOL candidate)) {
    return MCKRegisterMatcher(CREATE_MATCHER(block, boolValue), BOOL);
}

const char* mck_cStringMatching(BOOL(^block)(const char *candidate)) {
    return mck_registerCStringMatcher(CREATE_MATCHER(block, pointerValue));
}

SEL mck_selectorMatching(BOOL(^block)(SEL candidate)) {
    return mck_registerSelectorMatcher(CREATE_MATCHER(block, mck_selectorValue));
}

void* mck_pointerMatching(BOOL(^block)(void *candidate)) {
    return mck_registerPointerMatcher(CREATE_MATCHER(block, pointerValue));
}
