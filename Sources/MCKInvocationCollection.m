//
//  MCKInvocationCollection.m
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKInvocationCollection.h"
#import "MCKInvocationMatcher.h"


@interface MCKInvocationCollection () {
@protected
    NSMutableArray *_storedInvocations;
    MCKInvocationMatcher *_invocationMatcher;
}
@end


@implementation MCKInvocationCollection

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(MCKInvocationMatcher *)matcher {
    if ((self = [super init])) {
        _storedInvocations = [NSMutableArray array];
        _invocationMatcher = matcher;
    }
    return self;
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Use -initWithInvocationMatcher:" userInfo:nil];
}


#pragma mark - Querying for invocations

- (NSArray *)allInvocations {
    return [_storedInvocations copy];
}

- (NSIndexSet *)invocationsMatchingPrototype:(NSInvocation *)prototype withPrimitiveArgumentMatchers:(NSArray *)argMatchers {
    NSIndexSet *matchingIndexes = [_storedInvocations indexesOfObjectsPassingTest:^BOOL(NSInvocation *candidate, NSUInteger idx, BOOL *stop) {
        return [_invocationMatcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argMatchers];
    }];
    return matchingIndexes;
}

@end


@implementation MCKMutableInvocationCollection

#pragma mark - Adding and Removing Invocations

- (void)addInvocation:(NSInvocation *)invocation {
    [invocation retainArguments];
    [_storedInvocations addObject:invocation];
}

- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes {
    [_storedInvocations removeObjectsAtIndexes:indexes];
}

@end
