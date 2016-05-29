import XCTest
import Fleet
import Nimble
@testable import FleetTestApp

class UIStoryboard_FleetSpec: XCTestCase {
    var turtleStoryboard: UIStoryboard!
    
    class MockBoxedTurtleViewController: BoxTurtleViewController { }
    class MockCrabViewController: CrabViewController { }
    class MockPuppyListViewController: PuppyListViewController { }
    
    override func setUp() {
        super.setUp()
        
        turtleStoryboard = UIStoryboard.init(name: "TurtlesStoryboard", bundle: nil)
    }
    
    func test_bindingViewControllerToIdentifier_whenSameStoryboard_returnsBoundViewController() {
        let mockBoxedTurtleViewController = MockBoxedTurtleViewController()
        try! turtleStoryboard.bindViewController(mockBoxedTurtleViewController, toIdentifier: "BoxTurtleViewController")
        
        let boxedTurtleViewController = turtleStoryboard.instantiateViewControllerWithIdentifier("BoxTurtleViewController")
        expect(boxedTurtleViewController).to(beIdenticalTo(mockBoxedTurtleViewController))
    }
    
    func test_bindingViewController_whenInvalidIdentifier_throwsError() {
        var pass = false
        let whateverViewController = UIViewController()
        do {
            try turtleStoryboard.bindViewController(whateverViewController, toIdentifier: "WhateverViewController")
        } catch FLTStoryboardBindingError.InvalidViewControllerIdentifier {
            pass = true
        } catch { }
        
        if !pass {
            fail("Expected to throw InvalidViewControllerIdentifier error")
        }
    }
    
    func test_bindingViewControllerToIdentifierReferenceToAnotherStoryboard() {
        let mockCrabViewController = MockCrabViewController()
        try! turtleStoryboard.bindViewController(mockCrabViewController, toIdentifier: "CrabViewController", forReferencedStoryboardWithName: "CrabStoryboard")
        
        let testNavigationController = TestNavigationController()
        
        let animalListViewController = turtleStoryboard.instantiateInitialViewController() as? AnimalListViewController
        testNavigationController.pushViewController(animalListViewController!, animated: false)
        
        animalListViewController?.goToCrab()
        
        expect(testNavigationController.topViewController).to(beIdenticalTo(mockCrabViewController))
    }
    
    func test_bindingViewControllerToIdentifierReferenceToAnotherStoryboard_whenInvalidIdentifier_throwsError() {
        var pass = false
        let whateverViewController = UIViewController()
        do {
            try turtleStoryboard.bindViewController(whateverViewController, toIdentifier: "WhateverViewController", forReferencedStoryboardWithName: "CrabStoryboard")
        } catch FLTStoryboardBindingError.InvalidExternalStoryboardReference {
            pass = true
        } catch { }
        
        if !pass {
            fail("Expected to throw InvalidExternalStoryboardReference error")
        }
    }
    
    func test_bindingViewControllerToInitialViewControllerOfReferenceToAnotherStoryboard() {
        let mockPuppyListViewController = MockPuppyListViewController()
        
        try! turtleStoryboard.bindViewController(mockPuppyListViewController, asInitialViewControllerForReferencedStoryboardWithName: "PuppyStoryboard")
        
        let testNavigationController = TestNavigationController()
        
        let animalListViewController = turtleStoryboard.instantiateInitialViewController() as? AnimalListViewController
        testNavigationController.pushViewController(animalListViewController!, animated: false)
        
        animalListViewController?.goToPuppy()
        
        expect(testNavigationController.topViewController).to(beIdenticalTo(mockPuppyListViewController))
    }
    
    func test_bindingViewControllerToInitialViewControllerOfReferenceToAnotherStoryboard_whenInvalidIdentifier_throwsError() {
        var pass = false
        let whateverViewController = UIViewController()
        do {
            try turtleStoryboard.bindViewController(whateverViewController, asInitialViewControllerForReferencedStoryboardWithName: "WhateverStoryboard")
        } catch FLTStoryboardBindingError.InvalidExternalStoryboardReference {
            pass = true
        } catch { }
        
        if !pass {
            fail("Expected to throw InvalidExternalStoryboardReference error")
        }
    }
}
