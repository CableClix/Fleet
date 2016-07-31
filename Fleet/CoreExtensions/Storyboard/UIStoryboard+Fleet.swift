import UIKit
import ObjectiveC

private var storyboardInstanceBindingMap = [String : StoryboardInstanceBinding]()
private var storyboardBindingIdentifierAssociationKey: UInt8 = 0

extension UIStoryboard {
    var storyboardBindingIdentifier: String? {
        get {
            return objc_getAssociatedObject(self, &storyboardBindingIdentifierAssociationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &storyboardBindingIdentifierAssociationKey,
                                     newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIStoryboard {
    private func initializeStoryboardBindings() throws {
        let storyboardName = self.valueForKey("name") as! String
        if storyboardBindingIdentifier == nil {
            storyboardBindingIdentifier = storyboardName + "_" + NSUUID().UUIDString
        }
        
        if let storyboardBindingIdentifier = storyboardBindingIdentifier {
            if storyboardInstanceBindingMap[storyboardBindingIdentifier] == nil {
                let deserializer = StoryboardDeserializer()
                let storyboardReference = try deserializer.deserializeStoryboardWithName(storyboardName, fromBundle: NSBundle.mainBundle())
                storyboardInstanceBindingMap[storyboardBindingIdentifier] = StoryboardInstanceBinding(fromStoryboardName: storyboardName, storyboardReferenceMap: storyboardReference)
            }
        }
    }
    
    public func bindViewController(viewController: UIViewController, toIdentifier identifier: String) throws {
        try initializeStoryboardBindings()
        if let storyboardBindingIdentifier = storyboardBindingIdentifier {
            if let storyboardInstanceBinding = storyboardInstanceBindingMap[storyboardBindingIdentifier] {
                try storyboardInstanceBinding.bindViewController(viewController, toIdentifier: identifier)
            }
        }
    }
    
    public func bindViewController(viewController: UIViewController, toIdentifier identifier: String, forReferencedStoryboardWithName referencedStoryboardName: String) throws {
        try initializeStoryboardBindings()
        if let storyboardBindingIdentifier = storyboardBindingIdentifier {
            if let storyboardInstanceBinding = storyboardInstanceBindingMap[storyboardBindingIdentifier] {
                try storyboardInstanceBinding.bindViewController(viewController, toIdentifier: identifier,
                                                                 forReferencedStoryboardWithName: referencedStoryboardName)
            }
        }
    }
    
    public func bindViewController(viewController: UIViewController, asInitialViewControllerForReferencedStoryboardWithName referencedStoryboardName: String) throws {
        try initializeStoryboardBindings()
        if let storyboardBindingIdentifier = storyboardBindingIdentifier {
            if let storyboardInstanceBinding = storyboardInstanceBindingMap[storyboardBindingIdentifier] {
                try storyboardInstanceBinding.bindViewController(viewController, asInitialViewControllerForReferencedStoryboardWithName: referencedStoryboardName)
            }
        }
    }
    
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            swizzleViewControllerInstantiationMethod()
            swizzlePrivateStoryboardReferenceViewControllerInstantiationMethod()
        }
    }

    class func swizzleViewControllerInstantiationMethod() {
        let originalSelector = #selector(UIStoryboard.instantiateViewControllerWithIdentifier(_:))
        let swizzledSelector = #selector(UIStoryboard.fleet_instantiateViewControllerWithIdentifier(_:))
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    func fleet_instantiateViewControllerWithIdentifier(identifier: String) -> UIViewController {
        if let storyboardBindingIdentifier = storyboardBindingIdentifier {
            if let storyboardInstanceBinding = storyboardInstanceBindingMap[storyboardBindingIdentifier] {
                if let boundInstance = storyboardInstanceBinding.viewControllerForIdentifier(identifier) {
                    return boundInstance
                }
            }
        }
        
        let viewController = fleet_instantiateViewControllerWithIdentifier(identifier)
        return viewController
    }
    
    class func swizzlePrivateStoryboardReferenceViewControllerInstantiationMethod() {
        let originalSelector = Selector("instantiateViewControllerReferencedByPlaceholderWithIdentifier:")
        let swizzledSelector = #selector(UIStoryboard.fleet_instantiateViewControllerReferencedByPlaceholderWithIdentifier(_:))
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    func fleet_instantiateViewControllerReferencedByPlaceholderWithIdentifier(identifier: String) -> UIViewController {
        if let storyboardBindingIdentifier = storyboardBindingIdentifier {
            if let storyboardInstanceBinding = storyboardInstanceBindingMap[storyboardBindingIdentifier] {
                if let boundInstance = storyboardInstanceBinding.viewControllerForIdentifier(identifier) {
                    return boundInstance
                }
            }
        }
        
        let viewController = self.fleet_instantiateViewControllerReferencedByPlaceholderWithIdentifier(identifier)
        return viewController
    }
}
