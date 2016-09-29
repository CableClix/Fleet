import UIKit
import ObjectiveC

private var presentedViewControllerAssociatedKey: UInt = 0
private var presentingViewControllerAssociatedKey: UInt = 0

fileprivate var didSwizzle = false

extension UIViewController {
    open override class func initialize() {
        super.initialize()
        if !didSwizzle {
            swizzlePresent()
            swizzleDismiss()
            swizzleShow()
            swizzlePresentedViewControllerProperty()
            swizzlePresentingViewControllerProperty()
            didSwizzle = true
        }
    }

    fileprivate class func swizzlePresent() {
        let originalSelector = #selector(UIViewController.present(_:animated:completion:))
        let swizzledSelector = #selector(UIViewController.fleet_presentViewController(_:animated:completion:))

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    func fleet_presentViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        self.fleet_property_presentedViewController = viewController
        viewController.fleet_property_presentingViewController = self

        if let completion = completion {
            completion()
        }

        fleet_presentViewController(viewController, animated: animated, completion: nil)
    }

    fileprivate class func swizzleDismiss() {
        let originalSelector = #selector(UIViewController.dismiss(animated:completion:))
        let swizzledSelector = #selector(UIViewController.fleet_dismiss(animated:completion:))

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    func fleet_dismiss(animated: Bool, completion: (() -> ())?) {
        let viewControllerToDismiss = self.fleet_property_presentedViewController

        self.fleet_property_presentedViewController = nil
        viewControllerToDismiss?.fleet_property_presentingViewController = nil

        if let completion = completion {
            completion()
        }

        fleet_dismiss(animated: animated, completion: nil)
    }

    fileprivate class func swizzleShow() {
        let originalSelector = #selector(UIViewController.show(_:sender:))
        let swizzledSelector = #selector(UIViewController.fleet_showViewController(_:sender:))

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    func fleet_showViewController(_ viewController: UIViewController, sender: AnyObject?) {
        self.fleet_property_presentedViewController = viewController
        viewController.fleet_property_presentingViewController = self

        fleet_showViewController(viewController, sender: sender)
    }

    fileprivate class func swizzlePresentedViewControllerProperty() {
        let originalSelector = #selector(getter: UIViewController.presentedViewController)
        let swizzledSelector = #selector(UIViewController.fleet_presentedViewController)

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    fileprivate var fleet_property_presentedViewController: UIViewController? {
        get {
            return objc_getAssociatedObject(self, &presentedViewControllerAssociatedKey) as? UIViewController
        }
        set {
            objc_setAssociatedObject(self, &presentedViewControllerAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    func fleet_presentedViewController() -> UIViewController? {
        return self.fleet_property_presentedViewController
    }

    fileprivate class func swizzlePresentingViewControllerProperty() {
        let originalSelector = #selector(getter: UIViewController.presentingViewController)
        let swizzledSelector = #selector(UIViewController.fleet_presentingViewController)

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    fileprivate var fleet_property_presentingViewController: UIViewController? {
        get {
            return objc_getAssociatedObject(self, &presentingViewControllerAssociatedKey) as? UIViewController
        }
        set {
            objc_setAssociatedObject(self, &presentingViewControllerAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    func fleet_presentingViewController() -> UIViewController? {
        return fleet_property_presentingViewController
    }
}
