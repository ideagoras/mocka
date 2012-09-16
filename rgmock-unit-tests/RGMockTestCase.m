//
//  RGMockTestCase.m
//  rgmock
//
//  Created by Markus Gasser on 15.09.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockTestCase.h"

@implementation RGMockTestCase {
    BOOL _interceptFailures;
    NSException *_failure;
}

- (void)mock_interceptFailuresInFile:(NSString *)file line:(int)line block:(void(^)())block mode:(RGMockFailureHandlingMode)mode {
    if (block == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Need a code block" userInfo:nil];
    }
    
    _interceptFailures = YES;
    @try {
        _failure = nil;
        if (block != nil) {
            block();
        }
        _interceptFailures = NO;
        
        if (mode == RGMockFailureProhibited && _failure != nil) {
            [self failWithException:[NSException failureInFile:file atLine:line withDescription:@"Failed with exception: %@", _failure]];
        } else if (mode == RGMockFailureRequired && _failure == nil) {
            [self failWithException:[NSException failureInFile:file atLine:line withDescription:@"This should have failed"]];
        } // otherwise ignore the failure
    } @finally {
        _interceptFailures = NO;
    }
}

- (void)failWithException:(NSException *)anException {
    if (_interceptFailures) {
        _failure = anException;
    } else {
        [super failWithException:anException];
    }
}

@end
