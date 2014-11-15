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

@interface NSObject(FRYTestStub)

- (void) recordFailureWithDescription:(NSString *) description inFile:(NSString *) filename atLine:(NSUInteger) lineNumber expected:(BOOL) expected;

@end

@interface FRYDSLResult()

@property (strong, nonatomic) id testTarget;
@property (copy,   nonatomic) NSString *filename;
@property (assign, nonatomic) NSUInteger lineNumber;

@property (copy, nonatomic) NSSet *results;

@end

@implementation FRYDSLResult

- (id)initWithResults:(NSSet *)results testCase:(id)testCase inFile:(NSString *)filename atLine:(NSUInteger)lineNumber
{
    self = [super init];
    if ( self ) {
        self.testTarget = testCase;
        self.filename = filename;
        self.lineNumber = lineNumber;
        self.results = results;
    }
    return self;
}

- (id<FRYLookup>)singularResult
{
    [self check:self.results.count == 1 explaination:[NSString stringWithFormat:@"Only expected 1 lookup result, found %zd", self.results.count]];
    return self.results.anyObject;
}

- (void)check:(BOOL)result explaination:(NSString *)explaination
{
    NSAssert([self.testTarget respondsToSelector:@selector(recordFailureWithDescription:inFile:atLine:expected:)], @"Called from a non test function.  Not sure how to perform checks.");
    if ( result == NO ) {
        [self.testTarget recordFailureWithDescription:explaination inFile:self.filename atLine:self.lineNumber expected:YES];
    }
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
        [self check:self.results.count == 0 explaination:[NSString stringWithFormat:@"Expected 0 lookup results to be present, found %zd", self.results.count]];
        return self;
    };
}

- (FRYDSLIntegerBlock) count
{
    return ^(NSInteger count) {
        [self check:self.results.count == count explaination:[NSString stringWithFormat:@"Expected %zd lookup results to be present, found %zd", count, self.results.count]];
        return self;
    };
}

- (FRYDSLBlock)tap
{
    return ^() {
        UIView *view = [[self.singularResult fry_representingView] fry_interactableParent];
        CGRect frameInView = [self.singularResult fry_frameInView];
        [view fry_simulateTouch:[FRYTouch tap] insideRect:frameInView];
        return self;
    };
}

- (FRYDSLTouchBlock)touch
{
    return ^(FRYTouch *touch) {
        UIView *view = [[self.singularResult fry_representingView] fry_interactableParent];
        CGRect frameInView = [self.singularResult fry_frameInView];
        [view fry_simulateTouch:touch insideRect:frameInView];
        return self;
    };
}

- (FRYDSLArrayBlock)touches
{
    return ^(NSArray *touches) {
        UIView *view = [[self.singularResult fry_representingView] fry_interactableParent];
        CGRect frameInView = [self.singularResult fry_frameInView];
        [view fry_simulateTouches:touches insideRect:frameInView];
        return self;
    };
}

- (UIView *)view
{
    return [[self singularResult] fry_representingView];
}

- (FRYDSLBlock)selectText
{
    return ^() {
        UIView *view = [self view];
        while ( view && [view respondsToSelector:@selector(fry_selectAll)] == NO ) {
            view = [view superview];
        }
        [self check:view != nil explaination:[NSString stringWithFormat:@"Could not find superview of %@ to select text of.", [self view]]];

        [(UITextField *)view fry_selectAll];
        return self;
    };
}

- (FRYDSLResultStringBlock)type
{
    return ^(NSString *string) {
        FRYTypist *typist = [[UIApplication sharedApplication] fry_typist];
        [typist typeString:string];
        return self;
    };
}

@end
