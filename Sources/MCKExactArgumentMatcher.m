//
//  MCKExactArgumentMatcher.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKExactArgumentMatcher.h"


@implementation MCKExactArgumentMatcher

#pragma mark - Initialization

+ (instancetype)matcherWithArgument:(id)expected
{
    return [[self alloc] initWithArgument:expected];
}

- (instancetype)initWithArgument:(id)expected
{
    if ((self = [super init])) {
        [self setExpectedArgument:expected];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithArgument:nil];
}


#pragma mark - Configuration

- (void)setExpectedArgument:(id)expectedArgument
{
    _expectedArgument = ([expectedArgument conformsToProtocol:@protocol(NSCopying)]
                         ? [expectedArgument copy]
                         : expectedArgument);
}


#pragma mark - Argument Matching

- (BOOL)matchesObjectCandidate:(id)candidate
{
    return (candidate == self.expectedArgument || (candidate != nil && [candidate isEqual:self.expectedArgument]));
}

- (BOOL)matchesNonObjectCandidate:(NSValue *)candidate
{
    return (candidate == self.expectedArgument || (candidate != nil && [candidate isEqual:self.expectedArgument]));
}


#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p expected=%@>", [self class], self, self.expectedArgument];
}

@end


#pragma mark - Mocking Syntax

SInt8 mck_intArg(SInt64 arg) {
    return mck_registerPrimitiveNumberMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)]);
}

UInt8 mck_unsignedIntArg(UInt64 arg) {
    return mck_registerPrimitiveNumberMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)]);
}

float mck_floatArg(float arg) {
    return mck_registerPrimitiveNumberMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)]);
}

double mck_doubleArg(double arg) {
    return mck_registerPrimitiveNumberMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)]);
}

BOOL mck_boolArg(BOOL arg) {
    return mck_registerPrimitiveNumberMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)]);
}

char* mck_cStringArg(const char *arg) {
    return mck_registerCStringMatcher([MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithPointer:arg]]);
}

SEL mck_selectorArg(SEL arg) {
    return mck_registerSelectorMatcher([MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithPointer:arg]]);
}

void* mck_pointerArg(const void *arg) {
    return mck_registerPointerMatcher([MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithPointer:arg]]);
}
