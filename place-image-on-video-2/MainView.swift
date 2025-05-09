import UIKit

class MainView: UIView {
    var pickVideoTapped: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {        
        let pickVideoButton = Button(title: "Pick Video")
        pickVideoButton.addTarget(self, action: #selector(pickVideoTappedAction), for: .touchUpInside)
        addSubview(pickVideoButton)
        pickVideoButton.placeAtTheBottom(of: self)
    }
    
    @objc private func pickVideoTappedAction() {
        pickVideoTapped?()
    }
}

class MainViewController: UIViewController {
    private var mainView: MainView!
    private var videoPicker: MediaPickerController!
    
    override func loadView() {
        mainView = MainView()
        mainView.pickVideoTapped = { [weak self] in
            self?.videoPicker.presentMediaPicker(forType: .video)
        }
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPicker = MediaPickerController(presenter: self)
        
        videoPicker.videoPicked = { [weak self] url in
            let selectedVideoViewController = SelectedVideoViewController(mediaURL: url)
            self?.navigationController?.pushViewController(selectedVideoViewController, animated: true)
        }
    }
}
