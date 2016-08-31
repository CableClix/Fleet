import UIKit

public extension UINavigationController {
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }

        dispatch_once(&Static.token) {
            swizzlePushViewController()
            swizzlePopViewController()
        }
    }

    private class func swizzlePushViewController() {
        let originalSelector = #selector(UINavigationController.pushViewController(_:animated:))
        let swizzledSelector = #selector(UINavigationController.fleet_pushViewController(_:animated:))

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    func fleet_pushViewController(viewController: UIViewController, animated: Bool) {
        var newViewControllers = self.viewControllers
        newViewControllers.append(viewController)
        let _ = viewController.view
        self.setViewControllers(newViewControllers, animated: false)
    }

    private class func swizzlePopViewController() {
        let originalSelector = #selector(UINavigationController.popViewControllerAnimated(_:))
        let swizzledSelector = #selector(UINavigationController.fleet_popViewControllerAnimated(_:))

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    func fleet_popViewControllerAnimated(animated: Bool) -> UIViewController? {
        var newViewControllers = self.viewControllers
        let poppedViewController = newViewControllers.removeLast()
        self.setViewControllers(newViewControllers, animated: false)
        return poppedViewController
    }
}
