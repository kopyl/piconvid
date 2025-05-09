import UIKit

class ViewController: UIViewController {
    private var videoPicker: VideoPickerController!

    override func loadView() {
        view = MainView()
        (view as? MainView)?.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        videoPicker = VideoPickerController(presenter: self)
    }

    func pickVideo() {
        videoPicker.presentVideoPicker()
    }
}
