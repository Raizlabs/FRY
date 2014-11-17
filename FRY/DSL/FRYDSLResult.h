//
//  FRYDSLResult.h
//  FRY
//
//  Created by Brian King on 11/14/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRYDSLQuery.h"

@class FRYDSLResult;
@class FRYTouch;

typedef FRYDSLResult *(^FRYDSLArrayBlock)(NSArray *);
typedef FRYDSLResult *(^FRYDSLResultStringBlock)(NSString *);
typedef FRYDSLResult *(^FRYDSLTouchBlock)(FRYTouch *);
typedef FRYDSLResult *(^FRYDSLIntegerBlock)(NSInteger);
typedef FRYDSLResult *(^FRYDSLTimeIntervalBlock)(NSTimeInterval);


@interface FRYDSLResult : NSObject

+ (void)setPauseForeverOnFailure:(BOOL)pause;

- (id)initWithResults:(NSSet *)results query:(FRYDSLQuery *)query;

@property (copy, nonatomic, readonly) FRYDSLTimeIntervalBlock waitFor;
@property (copy, nonatomic, readonly) FRYDSLBlock present;
@property (copy, nonatomic, readonly) FRYDSLBlock absent;
@property (copy, nonatomic, readonly) FRYDSLIntegerBlock count;

@property (copy, nonatomic, readonly) FRYDSLBlock tap;
@property (copy, nonatomic, readonly) FRYDSLTouchBlock touch;
@property (copy, nonatomic, readonly) FRYDSLArrayBlock touches;
@property (copy, nonatomic, readonly) FRYDSLBlock selectText;

@property (copy, nonatomic, readonly) UIView *view;
- (void)onEach:(FRYMatchBlock)matchBlock;

@end
