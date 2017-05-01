#import <UIKit/UIKit.h>
#import "FleetSwizzle.h"

BOOL didSwizzleUITableViewRowAction = NO;

#if TARGET_OS_IOS
@implementation UITableViewRowAction (FleetPrivate)

+ (void)initialize {
    if (self == [UITableViewRowAction class]) {
        if (!didSwizzleUITableViewRowAction) {
            [self objc_swizzleInit];
            didSwizzleUITableViewRowAction = YES;
        }
    }
}

+ (void)objc_swizzleInit {
    memorySafeExecuteSelector(self, NSSelectorFromString(@"swizzleInit"));
}

@end
#endif
