import Foundation

struct UISizes {
    static let buttonHeight: CGFloat = 60
    static let pillButtonHeight: CGFloat = 32
    
    static let mainGridSpacing: CGFloat = 10
    static let pillButtonDistanceFromTop: CGFloat = 31
}

struct Copy {
    static let heroTitle = "Put picture on a vertical video"
    
    class Buttons {
        static let pickVideo = "Pick Video"
        static let tryDemoVideo = "Try demo video"
        static let tryDemoPicture = "Try demo picture"
        static let selectOverlayImage = "Pick picture overlay"
        static let changeVideo = "Change video"
        static let saveVideo = "Save video"
        static let startOver = "Start over"
    }
    
    class Hints {
        static let drag = "You can drag an image overlay vertically"
    }
}

struct IconNames {
    static let video = "video"
}

struct DemoAssetsFiles {
    struct Video {
        static let name = "squirrel-demo-video"
        static let `extension` = "mov"
    }
    struct Image {
        static let name = "squirrel-demo-video"
        static let `extension` = "squirrel-demo-video.png"
    }
}
