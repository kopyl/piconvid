import UIKit
import AVKit

class SelectedVideoView: UIView {
    var pickImageTapped: (() -> Void)?
    public let playerView: UIView
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(playerView: UIView) {
        self.playerView = playerView
        super.init(frame: .zero)
        setupView()
    }
    
    private func setupView() {
        playerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playerView)
        NSLayoutConstraint.activate([
            playerView.heightAnchor.constraint(equalToConstant: 500),
            playerView.widthAnchor.constraint(equalTo: widthAnchor),
            playerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            playerView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        let pickImageButton = Button(title: "Pick Image to place on top of this video")
        pickImageButton.addTarget(self, action: #selector(pickImageTappedAction), for: .touchUpInside)
        addSubview(pickImageButton)
        pickImageButton.placeAtTheBottom(of: self)
    }
    
    @objc private func pickImageTappedAction() {
        pickImageTapped?()
    }
}

class SelectedVideoViewController: UIViewController {
    private var selectedVideoView: SelectedVideoView!
    private var imagePicker: MediaPickerController!
    
    var videoURL: URL?
    let playerViewController = AVPlayerViewController()
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        guard let videoURL else { return }
        
        selectedVideoView = SelectedVideoView(playerView: playerViewController.view)
        selectedVideoView.pickImageTapped = { [weak self] in
            self?.imagePicker.presentMediaPicker(forType: .image)
        }
        view = selectedVideoView
        
        playerViewController.player = AVPlayer(url: videoURL)
        playerViewController.player?.play()
        addChild(playerViewController)
    }
    
    override func viewDidLoad() {
        imagePicker = MediaPickerController(presenter: self)
        
        imagePicker.imagePicked = { [weak self] imageURL in
            print(self?.videoURL ?? "", imageURL)
        }
    }
}
