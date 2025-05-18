import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UIGestureRecognizerDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController(rootViewController: MainViewController())
        navigationController.interactivePopGestureRecognizer?.delegate = self
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        window.backgroundColor = .appBackground
        self.window = window
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if window?.rootViewController?.presentedViewController != nil {
            return false /// A sheet is currently presented
        }
        
        return window?.rootViewController?.children.count ?? 0 > 1
    }
        
    /// Allows interactivePopGestureRecognizer to work simultaneously with other gestures.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        window?.rootViewController?.children.count ?? 0 > 1
    }
    
    /// Blocks other gestures when interactivePopGestureRecognizer begins (my TabView scrolled together with screen swiping back)
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        window?.rootViewController?.children.count ?? 0 > 1
    }
}
