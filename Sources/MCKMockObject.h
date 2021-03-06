//
//  MCKMockObject.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKMockingContext;


@interface MCKMockObject : NSObject

#pragma mark - Initialization

+ (id)mockWithContext:(MCKMockingContext *)context entities:(NSArray *)sourceList;


#pragma mark - Getting information about the mock

@property (nonatomic, readonly) NSArray *mck_mockedEntites;

@end
