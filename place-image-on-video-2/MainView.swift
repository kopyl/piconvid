import UIKit

class MainView: UIView {
    var pickVideoTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .appBackground
        
        let pickVideoButton = UIButton(type: .system)
        pickVideoButton.setTitle("Pick Video", for: .normal)
        pickVideoButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        pickVideoButton.addTarget(self, action: #selector(pickVideoTappedAction), for: .touchUpInside)
        pickVideoButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(pickVideoButton)

        NSLayoutConstraint.activate([
            pickVideoButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            pickVideoButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    @objc private func pickVideoTappedAction() {
        pickVideoTapped?()
    }
}

class MainViewController: UIViewController {
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
        
        videoPicker = VideoPickerController(
            presenter: self,
            mediaType: "public.movie"
        )
        
        videoPicker.videoPicked = { [weak self] url in
            let selectedVideoViewController = SelectedVideoViewController(videoURL: url)
            self?.navigationController?.pushViewController(selectedVideoViewController, animated: true)
        }
    }

    func pickVideo() {
        videoPicker.presentVideoPicker()
    }
}
