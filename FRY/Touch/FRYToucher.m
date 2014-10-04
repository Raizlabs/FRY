//
//  FRYToucher.m
//  FRY
//
//  Created by Brian King on 10/3/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "FRYToucher.h"
#import "FRYTouchInteraction.h"
#import "UIApplication+FRY.h"

@interface FRYToucher()

@property (copy, nonatomic) NSMutableArray *touchInteractions;
@property (strong, nonatomic) UIApplication *application;

@end

@implementation FRYToucher

- (id)init
{
    self = [super init];
    if ( self ) {
        self.application = [UIApplication sharedApplication];
        self.touchInteractions = [NSMutableArray array];
    }
    return self;
}

- (void)simulateTouches:(NSArray *)pointsInTime inView:(UIView *)view
{
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    FRYTouchInteraction *touchInteraction = [[FRYTouchInteraction alloc] initWithPointsInTime:pointsInTime inView:view startTime:startTime];

    @synchronized(self) {
        [self.touchInteractions addObject:touchInteraction];
    }
}

- (void)pruneCompletedTouchInteractions
{
    @synchronized(self) {
        for ( FRYTouchInteraction *interaction in [self.touchInteractions copy] ) {
            if ( interaction.currentTouchPhase == UITouchPhaseEnded || interaction.currentTouchPhase == UITouchPhaseCancelled ) {
                [self.touchInteractions removeObject:interaction];
            }
        }
    }
}

- (UIEvent *)eventForCurrentTouches
{
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSMutableArray *touches = [NSMutableArray array];

    @synchronized(self) {
        for ( FRYTouchInteraction *interaction in self.touchInteractions ) {
            [touches addObject:[interaction touchAtTime:currentTime]];
        }
        [self pruneCompletedTouchInteractions];
    }
    return [self.application fry_eventWithTouches:touches];
}

- (void)sendNextEvent
{
    UIEvent *nextEvent = nil;
    @synchronized(self) {
        nextEvent = [self eventForCurrentTouches];
    }
    [self.application sendEvent:nextEvent];
        
    for ( UITouch *touch in nextEvent.allTouches ) {
        if ( touch.phase == UITouchPhaseEnded && [touch.view canBecomeFirstResponder] ) {
            [touch.view becomeFirstResponder];
        }
    }
}


@end
