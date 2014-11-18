//
//  FRYIdleCheck.h
//  FRY
//
//  Created by Brian King on 11/17/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRYIdleCheck : NSObject

+ (FRYIdleCheck *)system;

+ (void)setSystemIdleCheck:(FRYIdleCheck *)idleCheck;

- (BOOL)isIdle;

- (NSString *)busyDescription;

- (NSTimeInterval)defaultTimeoutForRunloop;

- (BOOL)waitForIdle;

- (void)ignoreAnimationsOnViewsMatching:(NSPredicate *)predicate;

@end
