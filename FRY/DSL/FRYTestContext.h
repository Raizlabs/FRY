//
//  FRYQueryContext.h
//  FRY
//
//  Created by Brian King on 3/29/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FRY_TEST_CONTEXT ({[[FRYTestContext alloc] initWithTestTarget:self inFile:[NSString stringWithUTF8String:__FILE__] atLine:__LINE__];})

@class FRYQuery;

/**
 * Manage interactions with the test frameworks.
 */
@interface FRYTestContext : NSObject

- (id)initWithTestTarget:(id)target inFile:(NSString *)filename atLine:(NSUInteger)lineNumber;

@property (strong, nonatomic) id testTarget;
@property (copy, nonatomic) NSString *filename;
@property (assign, nonatomic) NSUInteger lineNumber;

- (void)recordFailureWithMessage:(NSString *)message action:(FRYQuery *)action results:(NSSet *)results;

@end
