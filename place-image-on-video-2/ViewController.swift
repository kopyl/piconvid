import UIKit

class ViewController: UIViewController {
    private var mainView: MainView!
    private var videoPicker: VideoPickerController!

    override func loadView() {
        mainView = MainView()
        mainView.pickVideoTapped = { [weak self] in
            self?.pickVideo()
        }
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        videoPicker = VideoPickerController(presenter: self, navigationController: navigationController)
    }

    func pickVideo() {
        videoPicker.presentVideoPicker()
    }
}
