//
//  MCKMockingContext+MCKArgumentRecording.h
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKMockingContext.h"


@interface MCKMockingContext (MCKArgumentRecording)

- (UInt8)pushPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher;
- (UInt8)pushObjectArgumentMatcher:(id<MCKArgumentMatcher>)matcher;

- (void)clearArgumentMatchers;

@end
