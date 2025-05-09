import UIKit

final class VideoPickerController: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private weak var presenter: UIViewController?
    private var mediaType: String
    
    var videoPicked: ((URL) -> Void)?

    init(presenter: UIViewController, mediaType: String) {
        self.presenter = presenter
        self.mediaType = mediaType
    }

    func presentVideoPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Photo Library not available")
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [mediaType]
        picker.allowsEditing = false
        picker.delegate = self

        presenter?.present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            let selectedVideoViewController = SelectedVideoViewController(videoURL: videoURL)
            videoPicked?(videoURL)
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
