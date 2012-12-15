#import "SpectacleScreenDetection.h"
#import "SpectacleUtilities.h"

@interface SpectacleScreenDetection (SpectacleScreenDetectionPrivate)

+ (NSScreen *)screenContainingRect: (CGRect)rect;

#pragma mark -

+ (CGFloat)percentageOfRect: (CGRect)rect withinFrameOfScreen: (CGRect)frameOfScreen;

#pragma mark -

+ (NSScreen *)nextOrPreviousScreenToFrameOfScreen: (CGRect)frameOfScreen inDirectionOfAction: (SpectacleWindowAction)action;

@end

#pragma mark -

@implementation SpectacleScreenDetection

+ (NSScreen *)screenWithAction: (SpectacleWindowAction)action andRect: (CGRect)rect {
    NSScreen *result = [self screenContainingRect: rect];
    
    if (MovingToNextOrPreviousDisplay(action)) {
        result = [self nextOrPreviousScreenToFrameOfScreen: NSRectToCGRect([result frame]) inDirectionOfAction: action];
    }
    
    return result;
}

@end

#pragma mark -

@implementation SpectacleScreenDetection (SpectacleScreenDetectionPrivate)

+ (NSScreen *)screenContainingRect: (CGRect)rect {
    CGFloat largestPercentageOfRectWithinFrameOfScreen = 0.0f;
    NSScreen *result = [NSScreen mainScreen];
    
    for (NSScreen *currentScreen in [NSScreen screens]) {
        CGRect currentFrameOfScreen = NSRectToCGRect([currentScreen frame]);
        CGRect flippedRect = rect;
        CGFloat percentageOfRectWithinCurrentFrameOfScreen = 0.0f;
        
        flippedRect.origin.y = FlipVerticalOriginOfRectInRect(flippedRect, currentFrameOfScreen);
        
        if (CGRectContainsRect(currentFrameOfScreen, flippedRect)) {
            result = currentScreen;
            
            break;
        }
        
        percentageOfRectWithinCurrentFrameOfScreen = [self percentageOfRect: flippedRect withinFrameOfScreen: currentFrameOfScreen];
        
        if (percentageOfRectWithinCurrentFrameOfScreen > largestPercentageOfRectWithinFrameOfScreen) {
            largestPercentageOfRectWithinFrameOfScreen = percentageOfRectWithinCurrentFrameOfScreen;
            
            result = currentScreen;
        }
    }
    
    return result;
}

#pragma mark -

+ (CGFloat)percentageOfRect: (CGRect)rect withinFrameOfScreen: (CGRect)frameOfScreen {
    CGRect intersectionOfRectAndFrameOfScreen = CGRectIntersection(rect, frameOfScreen);
    CGFloat result = 0.0f;
    
    if (!CGRectIsNull(intersectionOfRectAndFrameOfScreen)) {
        result = AreaOfRect(intersectionOfRectAndFrameOfScreen) / AreaOfRect(rect);
    }
    
    return result;
}

#pragma mark -

+ (NSScreen *)nextOrPreviousScreenToFrameOfScreen: (CGRect)frameOfScreen inDirectionOfAction: (SpectacleWindowAction)action {
    NSArray *screens = [NSScreen screens];
    NSScreen *result = nil;
    NSInteger lastDelta = 0;
    
    if ([screens count] <= 1) {
        return result;
    }
    
    for (NSInteger i = 0; i < [screens count]; i++) {
        NSScreen *currentScreen = screens[i];
        CGRect currentFrameOfScreen = NSRectToCGRect([currentScreen frame]);
        
        if (CGRectEqualToRect(currentFrameOfScreen, frameOfScreen)) {
            continue;
        }

        NSInteger screenDelta = (frameOfScreen.origin.x - currentFrameOfScreen.origin.x) ;
        NSInteger dir = (action == SpectacleWindowActionNextDisplay) ? -1 : 1;

        if (screenDelta * dir > 0 &&
            (result == nil || (screenDelta * dir) < lastDelta)) {
            result = [screens objectAtIndex: i];
            lastDelta = screenDelta * dir;
        }
    }
    
    return result;
}

@end
