import UIKit
import AVKit

class SelectedVideoView: UIView {
    var pickVideoTapped: (() -> Void)?
    public let playerViewController = AVPlayerViewController()
    public let videoURL: URL

    override init(frame: CGRect) {
        self.videoURL = URL(fileURLWithPath: "")
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
    }
    
    @objc private func pickVideoTappedAction() {
        pickVideoTapped?()
    }
}

class SelectedVideoViewController: UIViewController {
    var videoURL: URL?

    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let videoURL else {
            return
        }
        view = SelectedVideoView(videoURL: videoURL)
        guard let playerViewController = (view as? SelectedVideoView)?.playerViewController else {
            return
        }
        
        addChild(playerViewController)
    }
}
