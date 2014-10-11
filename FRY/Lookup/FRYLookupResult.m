//
//  FRYQueryResult.m
//  FRY
//
//  Created by Brian King on 10/8/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "FRYLookupResult.h"

@interface FRYLookupResult()

@property (strong, nonatomic) UIView *view;
@property (assign, nonatomic) CGRect frame;

@end

@implementation FRYLookupResult

+ (NSArray *)removeAncestorsFromLookupResults:(NSArray *)results
{
    // Remove duplicates
    results = [[NSOrderedSet orderedSetWithArray:results] array];
    
    NSMutableArray *reducedResults = [results mutableCopy];
    NSArray *resultViews = [reducedResults valueForKey:NSStringFromSelector(@selector(view))];
    for ( FRYLookupResult *result in results ) {
        UIView *superview = result.view.superview;
        while ( superview ) {
            NSUInteger index = [resultViews indexOfObject:superview];
            if ( index != NSNotFound ) {
                [reducedResults removeObjectAtIndex:index];
                resultViews = [reducedResults valueForKey:NSStringFromSelector(@selector(view))];
            }
            superview = superview.superview;
        }
        
    }
    return reducedResults;
}

- (instancetype)initWithView:(UIView *)view frame:(CGRect)frame
{
    self = [super init];
    if ( self ) {
        _view = view;
        _frame = frame;
    }
    return self;
}

- (NSUInteger)hash
{
    return [self.view hash] ^ [[NSValue valueWithCGRect:self.frame] hash];
}

- (BOOL)isEqual:(FRYLookupResult *)otherResult
{
    if ( [otherResult isKindOfClass:[FRYLookupResult class]] == NO ) {
        return NO;
    }
    BOOL equal = ([self.view isEqual:otherResult.view] &&
                  CGRectEqualToRect(self.frame, otherResult.frame));
    return equal;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p view=%@, frame=%@", self.class, self, self.view, NSStringFromCGRect(self.frame)];
}
@end
