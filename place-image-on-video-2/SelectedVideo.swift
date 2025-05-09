import UIKit
import AVKit

class SelectedVideoView: UIView {
    var pickImageTapped: (() -> Void)?
    public let playerViewController = AVPlayerViewController()
    public let videoURL: URL

    override init(frame: CGRect) {
        self.videoURL = URL(fileURLWithPath: "")  // likely needs refactoring
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(frame: .zero)
        setupView()
    }

    private func setupView() {
        backgroundColor = .appBackground
        
        let player = AVPlayer(url: videoURL)
        playerViewController.player = player

        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(playerViewController.view)
        
        NSLayoutConstraint.activate([
            playerViewController.view.heightAnchor.constraint(equalToConstant: 500),
            playerViewController.view.widthAnchor.constraint(equalTo: widthAnchor),
            playerViewController.view.centerXAnchor.constraint(equalTo: centerXAnchor),
            playerViewController.view.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        player.play()
        
        let pickImageButton = Button(title: "Pick Image to place on top of this video")
        pickImageButton.addTarget(self, action: #selector(pickImageTappedAction), for: .touchUpInside)
        
        addSubview(pickImageButton)
        NSLayoutConstraint.activate([
            pickImageButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            pickImageButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60),
        ])
    }
    
    @objc private func pickImageTappedAction() {
        pickImageTapped?()
    }
}

class SelectedVideoViewController: UIViewController {
    var mediaURL: URL?
    private var imagePicker: MediaPickerController!

    init(mediaURL: URL) {
        self.mediaURL = mediaURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mediaURL else {
            return
        }
        
        let selectedVideoView = SelectedVideoView(videoURL: mediaURL)
        
        selectedVideoView.pickImageTapped = { [weak self] in
            self?.pickPhoto()
        }
        
        view = selectedVideoView

        
        imagePicker = MediaPickerController(
            presenter: self
        )
        
        imagePicker.imagePicked = { [weak self] url in
            guard let self = self else { return }
        }
        
        addChild(selectedVideoView.playerViewController)
    }
    
    func pickPhoto() {
        imagePicker.presentMediaPicker(forType: "public.image")
    }
}
