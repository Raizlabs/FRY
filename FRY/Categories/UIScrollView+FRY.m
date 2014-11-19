//
//  UIScrollView+FRY.m
//  FRY
//
//  Created by Brian King on 11/16/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "UIScrollView+FRY.h"
#import "NSObject+FRYLookup.h"
#import "FRYTouch.h"
#import "FRYIdleCheck.h"

@implementation UIScrollView(FRY)

- (BOOL)fry_searchForViewsMatching:(NSPredicate *)predicate lookInDirection:(FRYDirection)direction
{
    NSSet *results = [self fry_allChildrenMatching:predicate];
    while ( results.count == 0 && [self fry_moreSpaceInSearchDirection:direction] ) {
        [self fry_scrollInDirection:direction];
        results = [self fry_allChildrenMatching:predicate];
    }
    
    return [self fry_scrollToLookupResultMatching:predicate];
}

- (BOOL)fry_scrollToLookupResultMatching:(NSPredicate *)predicate
{
    id<FRYLookup> result = [self fry_farthestDescendentMatching:predicate];
    if ( result ) {
        CGRect viewFrame = [self convertRect:[result fry_frameInView] fromView:[result fry_representingView]];
        viewFrame.origin.x -= self.contentInset.left;
        viewFrame.origin.y -= self.contentInset.top;
        [self fry_scrollAndWaitToContentOffset:viewFrame.origin];
    }
    return result != nil;
}

- (BOOL)fry_moreSpaceInSearchDirection:(FRYDirection)direction
{
    BOOL moreSpace = NO;
    switch ( direction ) {
        case FRYDirectionUp:
            moreSpace = self.contentOffset.y - self.frame.size.height > self.contentInset.top;
            break;
        case FRYDirectionDown:
            moreSpace = self.contentOffset.y + self.frame.size.height < self.contentSize.height + self.contentInset.bottom;
            break;
        case FRYDirectionLeft:
            moreSpace = self.contentOffset.x - self.frame.size.width > self.contentInset.left;
            break;
        case FRYDirectionRight:
            moreSpace = self.contentOffset.x + self.frame.size.width < self.contentSize.width + self.contentInset.top;
            break;
    }
    return moreSpace;
}

- (void)fry_scrollInDirection:(FRYDirection)direction
{
    CGPoint offset = self.contentOffset;
    switch ( direction ) {
        case FRYDirectionUp:
            offset.y -= self.frame.size.height;
            break;
        case FRYDirectionDown:
            offset.y += self.frame.size.height;
            break;
        case FRYDirectionLeft:
            offset.x -= self.frame.size.width;
            break;
        case FRYDirectionRight:
            offset.x += self.frame.size.width;
            break;
    }
    [self fry_scrollAndWaitToContentOffset:offset];
}

- (BOOL)fry_scrollAndWaitToContentOffset:(CGPoint)offset
{
    [self setContentOffset:offset animated:YES];
    return [[FRYIdleCheck system] waitForIdle];
}

@end

