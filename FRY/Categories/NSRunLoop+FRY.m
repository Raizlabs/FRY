//
//  NSRunloop+FRY.m
//  FRY
//
//  Created by Brian King on 10/11/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "NSRunloop+FRY.h"
#import "FRYTouchDispatch.h"
#import "UIApplication+FRY.h"
#import "FRYDefines.h"


@implementation NSRunLoop(FRY)

- (BOOL)fry_waitWithTimeout:(NSTimeInterval)timeout forCheck:(FRYCheckBlock)checkBlock;
{
    // Spin the runloop for a tad, incase some action initiated a performSelector:withObject:afterDelay:
    // which will cause some state change very soon.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];

    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    while ( checkBlock() == NO &&
            start + timeout > [NSDate timeIntervalSinceReferenceDate] )
    {
        [self runUntilDate:[NSDate dateWithTimeIntervalSinceNow:kFRYEventDispatchInterval]];
    }
    
    return start + timeout > [NSDate timeIntervalSinceReferenceDate];
}

@end
