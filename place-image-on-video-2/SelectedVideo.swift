import UIKit
import AVKit

class SelectedVideoView: UIView {
    var pickImageTapped: (() -> Void)?
    public let playerViewController = AVPlayerViewController()
    public let videoURL: URL
    
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
        pickImageButton.placeAtTheBottom(of: self)
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
            self?.imagePicker.presentMediaPicker(forType: .image)
        }
        
        view = selectedVideoView
        
        imagePicker = MediaPickerController(presenter: self)
        
        imagePicker.imagePicked = { [weak self] url in
            print(self?.mediaURL ?? "")
        }
        
        addChild(selectedVideoView.playerViewController)
    }
}
