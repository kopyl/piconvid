import SwiftUI

#Preview {
    let videoURL = Bundle.main.url(
        forResource: DemoAssetsFiles.Video.name,
        withExtension: DemoAssetsFiles.Video.extension
    )
    
    SelectedVideoViewController(videoURL: videoURL!)
}
