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
    var mediaURL: URL?
    private var imagePicker: MediaPickerController!
    public let playerViewController = AVPlayerViewController()
    
    init(mediaURL: URL) {
        self.mediaURL = mediaURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mediaURL else { return }
        
        let selectedVideoView = SelectedVideoView(playerView: playerViewController.view)
        
        selectedVideoView.pickImageTapped = { [weak self] in
            self?.imagePicker.presentMediaPicker(forType: .image)
        }
        
        view = selectedVideoView
        
        imagePicker = MediaPickerController(presenter: self)
        
        imagePicker.imagePicked = { [weak self] url in
            print(self?.mediaURL ?? "")
        }
        
        addChild(playerViewController)
        
        playerViewController.player = AVPlayer(url: mediaURL)
        playerViewController.player?.play()
    }
}
