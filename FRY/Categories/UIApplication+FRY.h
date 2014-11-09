//
//  UIApplication+FRY.h
//  FRY
//
//  Created by Brian King on 10/3/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRYDefines.h"
#import "UIKit+FRYExposePrivate.h"
#import "FRYTypist.h"

@interface UIApplication(FRY)

- (UIEvent *)fry_eventWithTouches:(NSArray *)touches;

- (UIView *)fry_animatingViewToWaitFor;

- (FRYTypist *)fry_typist;


@end
