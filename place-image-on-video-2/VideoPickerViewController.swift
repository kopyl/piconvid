import UIKit

final class VideoPickerController: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private weak var presenter: UIViewController?
    private weak var navigationController: UINavigationController?
    private var mediaType: String

    init(presenter: UIViewController, navigationController: UINavigationController?, mediaType: String) {
        self.presenter = presenter
        self.navigationController = navigationController
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
            print("Selected video URL: \(videoURL)")
            let selectedVideoViewController = SelectedVideoViewController(videoURL: videoURL)
            navigationController?.pushViewController(selectedVideoViewController, animated: true)
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
