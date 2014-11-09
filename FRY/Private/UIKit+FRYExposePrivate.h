//
//  UIKit+Private.m
//  FRY
//
//  Created by Brian King on 10/3/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct __GSEvent * GSEventRef;

@interface UIEvent (FRYExposePrivate)

- (id)_initWithEvent:(GSEventRef)event touches:(id)touches;
- (void)_addTouch:(id)arg1 forDelayedDelivery:(BOOL)arg2;
- (void)_clearTouches;
- (void)_setGSEvent:(GSEventRef)event;
- (GSEventRef)_gsEvent;

@end

@interface UIApplication (FRYExposePrivate)
-(BOOL)handleEvent:(GSEventRef)event withNewEvent:(id)newEvent;

- (UIEvent *)_touchesEvent;
@end

@interface NSObject (FRYExposePrivate)

- (void)tapInteractionWithLocation:(CGPoint)point;

@end

