//
//  FRYDSLResult.m
//  FRY
//
//  Created by Brian King on 11/14/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//
#import "UIApplication+FRY.h"
#import "UIView+FRY.h"
#import "UITextInput+FRY.h"

#import "FRYDSLResult.h"
#import "FRYTypist.h"

static BOOL pauseOnFailure = NO;

@interface NSObject(FRYTestStub)

- (void) recordFailureWithDescription:(NSString *) description inFile:(NSString *) filename atLine:(NSUInteger) lineNumber expected:(BOOL) expected;

@end

@interface FRYDSLResult()

@property (strong, nonatomic) FRYDSLQuery *query;
@property (copy, nonatomic) NSSet *results;

@property (assign, nonatomic) NSTimeInterval timeout;

@end

@implementation FRYDSLResult

+ (void)setPauseForeverOnFailure:(BOOL)pause;
{
    pauseOnFailure = pause;
}

- (id)initWithResults:(NSSet *)results query:(FRYDSLQuery *)query
{
    self = [super init];
    if ( self ) {
        self.query = query;
        self.results = results;
        self.timeout = 0;
    }
    return self;
}

- (void)check:(FRYCheckBlock)check explaination:(NSString *)explaination
{
    NSParameterAssert(explaination);
    // Easily add support for other frameworks by messaging failures here.
    NSAssert([self.query.testTarget respondsToSelector:@selector(recordFailureWithDescription:inFile:atLine:expected:)], @"Called from a non test function.  Not sure how to perform checks.");
    
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval now   = start;
    BOOL isOK = check();
    while ( isOK == NO && now - start < self.timeout) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:self.timeout / 10]];
        self.results = [self.query performQuery];
        isOK = check();
        now = [NSDate timeIntervalSinceReferenceDate];
    }
    
    if ( isOK == NO ) {
        explaination = [explaination stringByAppendingFormat:@"\nGot:%@\nLookup Origin:%@\nPredicate:%@\n",
                        self.results,
                        self.query.lookupOrigin,
                        self.query.predicate];
        [self.query.testTarget recordFailureWithDescription:explaination inFile:self.query.filename atLine:self.query.lineNumber expected:YES];
        while ( pauseOnFailure ) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
    }
}

- (id<FRYLookup>)singularResult
{
    [self check:^BOOL{return self.results.count == 1;} explaination:[NSString stringWithFormat:@"Only expected 1 lookup result, found %zd", self.results.count]];
    return self.results.anyObject;
}

- (FRYDSLBlock)present
{
    return ^() {
        [self singularResult];
        return self;
    };
}

- (FRYDSLBlock)absent
{
    return ^() {
        [self check:^BOOL{return self.results.count == 0;} explaination:[NSString stringWithFormat:@"Expected 0 lookup results to be present, found %zd", self.results.count]];
        return self;
    };
}

- (FRYDSLIntegerBlock) count
{
    return ^(NSInteger count) {
        [self check:^BOOL{return self.results.count == count;} explaination:[NSString stringWithFormat:@"Expected %zd lookup results to be present, found %zd", count, self.results.count]];
        return self;
    };
}

- (FRYDSLTimeIntervalBlock)waitFor
{
    return ^(NSTimeInterval timeout) {
        self.timeout = timeout;
        return self;
    };
}

- (FRYDSLBlock)tap
{
    return ^() {
        id<FRYLookup> lookup = [self singularResult];
        UIView *view = [[lookup fry_representingView] fry_interactableParent];
        CGRect frameInView = [lookup fry_frameInView];
        [view fry_simulateTouch:[FRYTouch tap] insideRect:frameInView];
        return self;
    };
}

- (FRYDSLTouchBlock)touch
{
    return ^(FRYTouch *touch) {
        NSParameterAssert(touch);
        id<FRYLookup> lookup = [self singularResult];
        UIView *view = [[lookup fry_representingView] fry_interactableParent];
        CGRect frameInView = [lookup fry_frameInView];
        [view fry_simulateTouch:touch insideRect:frameInView];
        return self;
    };
}

- (FRYDSLArrayBlock)touches
{
    return ^(NSArray *touches) {
        NSParameterAssert(touches);
        id<FRYLookup> lookup = [self singularResult];
        UIView *view = [[lookup fry_representingView] fry_interactableParent];
        CGRect frameInView = [lookup fry_frameInView];
        [view fry_simulateTouches:touches insideRect:frameInView];
        return self;
    };
}

- (FRYDSLBlock)selectText
{
    return ^() {
        UIView *view = [self view];
        while ( view && [view respondsToSelector:@selector(fry_selectAll)] == NO ) {
            view = [view superview];
        }
        [self check:^BOOL{return view != nil;} explaination:[NSString stringWithFormat:@"Could not find superview of %@ to select text of.", [self view]]];

        [(UITextField *)view fry_selectAll];
        return self;
    };
}

- (UIView *)view
{
    return [[self singularResult] fry_representingView];
}

- (void)onEach:(FRYMatchBlock)matchBlock
{
    NSParameterAssert(matchBlock);
    for ( id<FRYLookup> lookup in self.results ) {
        matchBlock([lookup fry_representingView], [lookup fry_frameInView]);
    }
}

@end
