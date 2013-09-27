//
//  MCKInvocationPrototype.m
//  Framework
//
//  Created by Markus Gasser on 27.9.2013.
//
//

#import "MCKInvocationPrototype.h"

#import "MCKArgumentMatcher.h"
#import "MCKExactArgumentMatcher.h"
#import "MCKHamcrestArgumentMatcher.h"
#import "MCKTypeEncodings.h"
#import "MCKArgumentSerialization.h"
#import "NSInvocation+MCKArgumentHandling.h"


@interface MCKInvocationPrototype ()

@property (nonatomic, readonly) NSArray *orderedArgumentMatchers;

@end

@implementation MCKInvocationPrototype

#pragma mark - Initialization

- (instancetype)initWithInvocation:(NSInvocation *)invocation argumentMatchers:(NSArray *)argumentMatchers {
    if ((self = [super init])) {
        _invocation = invocation;
        _argumentMatchers = [argumentMatchers copy];
        _orderedArgumentMatchers = [self prepareOrderedArgumentMatchersFromInvocation:invocation matchers:argumentMatchers];
    }
    return self;
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation {
    return [self initWithInvocation:invocation argumentMatchers:@[]];
}


#pragma mark - Preparing Argument Matchers

- (NSArray *)prepareOrderedArgumentMatchersFromInvocation:(NSInvocation *)invocation matchers:(NSArray *)matchers {
    NSMutableArray *orderedMatchers = [NSMutableArray arrayWithCapacity:(invocation.methodSignature.numberOfArguments - 2)];
    for (NSUInteger argIndex = 2; argIndex < invocation.methodSignature.numberOfArguments; argIndex++) {
        id<MCKArgumentMatcher> matcher = [self matcherAtIndex:argIndex forInvocation:invocation matchers:matchers];
        [orderedMatchers addObject:matcher];
    }
    return orderedMatchers;
}

- (id<MCKArgumentMatcher>)matcherAtIndex:(NSUInteger)index forInvocation:(NSInvocation *)invocation matchers:(NSArray *)matchers {
    BOOL isObjectArg = [MCKTypeEncodings isObjectType:[invocation.methodSignature getArgumentTypeAtIndex:index]];
    BOOL hasProvidedMatchers = ([matchers count] > 0);
    
    if (isObjectArg) {
        return [self wrapObjectInMatcherIfNeeded:[invocation mck_objectParameterAtIndex:(index - 2)]];
    } else if (hasProvidedMatchers) {
        return [matchers objectAtIndex:[self primitiveMatcherIndexFromInvocation:invocation argumentIndex:index]];
    } else {
        return [MCKExactArgumentMatcher matcherWithArgument:[self serializedArgumentAtIndex:index ofInvocation:invocation]];
    }
}

- (id<MCKArgumentMatcher>)wrapObjectInMatcherIfNeeded:(id)object {
    if ([object conformsToProtocol:@protocol(MCKArgumentMatcher)]) {
        return object;
    } else if ([self hamcrestMatcherProtocol] != nil && [object conformsToProtocol:[self hamcrestMatcherProtocol]]) {
        return [MCKHamcrestArgumentMatcher matcherWithHamcrestMatcher:object];
    } else {
        return [MCKExactArgumentMatcher matcherWithArgument:object];
    }
}

- (NSUInteger)primitiveMatcherIndexFromInvocation:(NSInvocation *)invocation argumentIndex:(NSUInteger)index {
    NSUInteger paramSize = [invocation mck_sizeofParameterAtIndex:(index - 2)];
    NSAssert(paramSize >= 1, @"Minimum byte size not given");
    UInt8 buffer[paramSize]; memset(buffer, 0, paramSize);
    [invocation getArgument:buffer atIndex:index];
    return mck_matcherIndexForArgumentBytes(buffer, [invocation.methodSignature getArgumentTypeAtIndex:index]);
}

- (Protocol *)hamcrestMatcherProtocol {
    static Protocol *hamcrestProtocol = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hamcrestProtocol = NSProtocolFromString(@"HCMatcher");
    });
    return hamcrestProtocol;
}


#pragma mark - Matching Invocations

- (BOOL)matchesInvocation:(NSInvocation *)candidate {
    NSParameterAssert(candidate != nil);
    
    // check simple cases
    if ((self.invocation.target != candidate.target) || (self.invocation.selector != candidate.selector)) {
        return NO;
    }
    
    // match arguments
    NSUInteger argIndex = 2;
    for (id<MCKArgumentMatcher> matcher in self.orderedArgumentMatchers) {
        if (![matcher matchesCandidate:[self serializedArgumentAtIndex:argIndex ofInvocation:candidate]]) {
            return NO;
        }
        argIndex++;
    }
    
    return YES;
}


#pragma mark - Serializing Primitive Values

- (id)serializedArgumentAtIndex:(NSUInteger)argIndex ofInvocation:(NSInvocation *)invocation {
    NSUInteger paramSize = [invocation mck_sizeofParameterAtIndex:(argIndex - 2)];
    UInt8 buffer[paramSize]; memset(buffer, 0, paramSize);
    [invocation getArgument:buffer atIndex:argIndex];
    return mck_encodeValueFromBytesAndType(buffer, paramSize, [invocation.methodSignature getArgumentTypeAtIndex:argIndex]);
}

@end
