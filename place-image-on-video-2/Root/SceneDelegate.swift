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
    
    private func isVideoSaving() -> Bool {
        let selectedVideoVC = window?.rootViewController?.children.first(where: {$0 is SelectedVideoViewController})
        let selectedVideoView = selectedVideoVC?.view as? SelectedVideoView
        if let view = selectedVideoView {
            if view.isVideoSaving {
                return true
            }
        }
        return false
    }
    
    private func isMediaSelectionSheetPresented() -> Bool {
        if window?.rootViewController?.presentedViewController != nil {
            return true
        }
        return false
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {        
        if isMediaSelectionSheetPresented() {
            return false
        }
        if isVideoSaving() {
            return false
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
