//
//  NSPredicate+FRY.h
//  FRY
//
//  Created by Brian King on 11/3/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Predicates to aide in looking up views / accessibility elements.   It is a design goal to avoid
 * using block predicate for debug-ability reasons.   -description on a block predicate is not helpful.
 */
@interface NSPredicate(FRY)

+ (NSPredicate *)fry_matchAccessibilityIdentifier:(NSString *)accessibilityIdentifier;
+ (NSPredicate *)fry_matchAccessibilityLabel:(NSString *)accessibilityLabel;
+ (NSPredicate *)fry_matchAccessibilityLabel:(NSString *)accessibilityLabel accessibilityValue:(NSString *)accessibilityValue;

@end
