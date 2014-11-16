# FRY: A UIKit Interaction Library

FRY is an iOS Library inspired by KIF.  The purpose is to simplify iteractions with UIKit and make writing UI tests simple.

NOTE: Everything is still in alpha, and is subject to change before the 1.0 release.

## Overview
FRY consists of three features to help writing integration tests:

- View Lookup
- Touch Modeling
- Touch Recording and Playback

The majority of FRY code is implemented as categories on objects.   Due to the wordy-ness of the API, there's also a thin DSL for FRY that is much more concise.  This DSL is not required to use FRY, and the devout objective-c purists are encouraged to call the category methods directly.

### View Lookup
Two types of queries are supported, a depth-first query that mimics hitTest traversal, and a query that will return all matching objects.

```obj-c
FRY.accessibilityLabel(@"My Label").depthFirst().present();
FRY.accessibilityLabel(@"My Label").all().present();
FRY.accessibilityTraits(UIAccessibilityTraitButton).all().count(14);

// Or the more traditional Objective-C API:
id<FRYLookup> l = [FRY_KEY_WINDOW fry_farthestDescendentMatching:[NSPredicate fry_matchAccessibilityLabel:actionConfirmation]];
XCTAssertNotNil([l fry_representingView]);

```

View lookup is a simple system based on NSPredicate and KeyPaths.  Add support to any object (like CALayer or SceneKit) by implementing `-fry_childKeyPaths`, `-fry_representingView`, and `fry_frameInView`.  UIKit support traverses both `accessibilityElements` and `subviews`.

### Touch Synthesis
FRY uses strongly modeled touches to generate UIKit touch events.  This allows for simple arbitrary touch re-creation, and clear API's for creating common touch sequences.

```obj-c
FRY.accessibilityLabel(@"My Label").depthFirst().tap()
FRY.accessibilityLabel(@"My Label").depthFirst().touches([FRYSyntheticTouch doubleTap])

[[[UIApplication sharedApplication] keyWindow] fry_simulateTouch:[FRYSyntheticTouch tap]
                                               onSubviewMatching:[NSPredicate fry_matchAccessibilityLabel:@"My Label"]];

// Other touch objects:
FRYSyntheticTouch *t1 = [FRYSyntheticTouch dragFromPoint:p1 toPoint:p2 forDuration:1];
FRYSyntheticTouch *t2 = [FRYSyntheticTouch pinchInToCenterOfPoint:p3 point:p4 duration:1];
// Or, slightly more complex.
FRYSyntheticTouch *t3 = [FRYSyntheticTouch touchStarting:0.000 points:33 xyoffsets:0.941f,0.597f,0.000, 0.934f,0.597f,0.094, 0.919f,0.597f,0.121, 0.853f,0.597f,0.147, 0.801f,0.597f,0.164, 0.750f,0.597f,0.182, 0.686f,0.597f,0.215, 0.667f,0.597f,0.232, 0.625f,0.548f,0.264, 0.610f,0.548f,0.282, 0.571f,0.548f,0.322, 0.547f,0.548f,0.350, 0.542f,0.548f,0.367, 0.534f,0.548f,0.386, 0.532f,0.548f,0.416, 0.527f,0.548f,0.448, 0.522f,0.548f,0.472, 0.517f,0.548f,0.504, 0.517f,0.581f,0.604, 0.512f,0.581f,0.692, 0.510f,0.581f,0.720, 0.505f,0.581f,0.737, 0.500f,0.581f,0.765, 0.505f,0.581f,1.170, 0.510f,0.581f,1.216, 0.515f,0.581f,1.263, 0.517f,0.581f,1.350, 0.522f,0.581f,1.382, 0.525f,0.581f,1.452, 0.520f,0.581f,1.624, 0.515f,0.581f,1.641, 0.510f,0.581f,1.670, 0.500f,0.581f,1.698];
```

Notice that points and touches are specified as multiples of the frame they are dispatched in.   So a tap at point 0.5 0.5 will touch in the center of the view, regardless of the views frame.  All touches are dispatched via timers on the main runloop and do not block the main thread.  

Touches are complete when `-[FRYTouchDispatch hasActiveTouches]` returns `NO`.  There is a helper on `NSRunLoop`, `fry_waitForIdle` that will spin the runloop until all touches are finished and all UI Animations have completed.  This greatly simplifies flow-control, and eliminiates the vast majority of `CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.5, false)`.  If you find yourself wanting to add these to your tests, consider adding animation to your UI instead.

### Touch Recording and Playback
A side effect of strong touch modeling is that FRY can record live touch events in your application for later playback.  When the home button is pressed, The FRY commands to reproduce these touches are printed on the console.

*To Enable Monitoring*
```obj-c
[[FRYEventMonitor sharedEventMonitor] enable];
```

FRY will attempt to use relative coordinates with accessibility lookup information for the view that was touched.  This will maximize the reliability of these commands when UI changes occur.  If no accessibility information can be found, absoulte screen coordinates will be used.

## Installation

Add FRY to your Podfile to install.   If you want to use touch recording, add FRY to your application target, otherwise add FRY to your test target.

```
   pod 'FRY'
```

## Why Not KIF?
KIF is amazing framework that has pushed forward UI testing on iOS.  However, I was unable to completely understand or trust the code base.  There are tons of work arounds for UIKit issues spread around the code, without a clear understanding of why, or if they're still applicable to current versions of iOS.  The core design difference with KIF that pushed me to write FRY without looking to maintain compatibility is that looking up a view can modify the view heirarchy to find it.   This causes a lot of bizarre issues, and it is not usually what I want from a testing perspective.

## Design Goals
- Complete Code Coverage and UIKit functionality.
- Clear separation of query and touching.  UIView lookup will never modify the view heirarchy.
- Use simple logic to implement behavior, and categories to hide complex UIKit implementation details.
- Minimize knowledge of and checks against UIKit private classes.
- Isolate runloop spinning.

### Design Questions
- I've never used so many categories, and I'm not sure how to best organize them.


