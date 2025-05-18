import Foundation

struct Store {
    private static let key = "hasDragMessageBeenShownAtLeastOnce"

    static var hasDragMessageBeenShownAtLeastOnce: Bool {
        get {
            UserDefaults.standard.bool(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
