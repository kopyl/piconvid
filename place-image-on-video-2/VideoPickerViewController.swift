import UIKit

final class MediaPickerController: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private weak var presenter: UIViewController?
    
    var videoPicked: ((URL) -> Void)?
    var imagePicked: ((URL) -> Void)?

    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    func presentMediaPicker(forType mediaType: String) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
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
            videoPicked?(videoURL)
        }
        else if let imageURL = info[.imageURL] as? URL {
            imagePicked?(imageURL)
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
