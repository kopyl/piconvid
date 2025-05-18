import UIKit
import AVKit
import Photos

func getVideoAspectRatio(from playerViewController: AVPlayerViewController) -> CGFloat? {
    guard let asset = playerViewController.player?.currentItem?.asset else { return nil }
    let tracks = asset.tracks(withMediaType: .video)
    guard let track = tracks.first else { return nil }
    
    let size = track.naturalSize
    return size.width / size.height
}

class SelectedVideoView: UIView {
    var pickImageTapped: (() -> Void)?
    var videoSavingStarted: (() -> Void)?
    var videoSavingEnded: (() -> Void)?
    private var playerViewController: AVPlayerViewController
    public var buttonsStack: ButtonStack
    public var imageView: DraggableImageView?
    var changeVideoTapped: (() -> Void)?
    var mainContentContainer = MainContentContainer()
    private let pillButton = PillButton(title: Copy.Buttons.tryDemoPicture)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(playerViewController: AVPlayerViewController) {
        self.playerViewController = playerViewController
        buttonsStack = ButtonStack([])
        super.init(frame: .zero)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .appBackground
        
        let changeVideoButton = Button(title: Copy.Buttons.changeVideo, type: .secondary)
        let pickImageButton = Button(title: Copy.Buttons.selectOverlayImage, type: .secondary, icon: "square.2.layers.3d")
        changeVideoButton.setContentHuggingPriority(.required, for: .horizontal)
        
        pickImageButton.addTarget(self, action: #selector(pickImageTappedAction), for: .touchUpInside)
        changeVideoButton.addTarget(self, action: #selector(pickVideoTappedAction), for: .touchUpInside)
        
        buttonsStack = ButtonStack([changeVideoButton, pickImageButton])
        addSubview(buttonsStack)
        buttonsStack.placeAtTheBottom(of: self)
        
        addSubview(mainContentContainer)
        mainContentContainer.placeAbove(button: buttonsStack, inside: self)
        
        addVideo()
        addPillButton()
    }
    
    private func addVideo() {
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        mainContentContainer.addSubview(playerViewController.view)
        
        guard let videoAspectRatio = getVideoAspectRatio(from: playerViewController) else { return }
        
        NSLayoutConstraint.activate([
            playerViewController.view.centerXAnchor.constraint(equalTo: mainContentContainer.centerXAnchor),
            playerViewController.view.centerYAnchor.constraint(equalTo: mainContentContainer.centerYAnchor),
            playerViewController.view.widthAnchor.constraint(equalTo: mainContentContainer.widthAnchor),
        ])
        
        DispatchQueue.main.async {
            let containerAspectRatio = self.mainContentContainer.frame.width / self.mainContentContainer.frame.height
            
            NSLayoutConstraint.activate([
                self.playerViewController.view.heightAnchor.constraint(
                    equalTo: self.playerViewController.view.widthAnchor,
                    multiplier: 1 / max(videoAspectRatio, containerAspectRatio)
                )
            ])
        }
    }
    
    private func addPillButton() {
        pillButton.addTarget(self, action: #selector(tryDemoPictureTappedAction), for: .touchUpInside)
        mainContentContainer.addSubview(pillButton)
        pillButton.placeAtTheTop(of: mainContentContainer)
    }
    
    public func addImage(image: URL) {
        imageView = DraggableImageView(playerViewController: playerViewController)
        guard let imageView else { return }
        imageView.image = UIImage(contentsOfFile: image.path)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        mainContentContainer.addSubview(imageView)
        
        let videoAR = getVideoAspectRatio(from: playerViewController)
        let imageAR = imageView.intrinsicContentSize.height / imageView.intrinsicContentSize.width
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: playerViewController.view.heightAnchor, multiplier: videoAR ?? 0),
            
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: imageAR),
            
            imageView.centerXAnchor.constraint(equalTo: playerViewController.view.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: playerViewController.view.bottomAnchor)
        ])
    }
    
    public func addSaveButton() {
        let saveButton = Button(title: "Save video", type: .secondary)
        saveButton.addTarget(self, action: #selector(saveButtonTappedAction), for: .touchUpInside)
        addSubview(saveButton)
        saveButton.placeAtTheBottom(of: self)
    }
    
    @objc private func tryDemoPictureTappedAction() {
//        demoVideoPicked?()
        print("try demo picture tapped")
    }
    
    @objc private func pickImageTappedAction() {
        pickImageTapped?()
    }
    
    @objc private func pickVideoTappedAction() {
        self.changeVideoTapped?()
    }
    
    @objc private func saveButtonTappedAction() {
        videoSavingStarted?()
        
        guard let videoAsset = playerViewController.player?.currentItem?.asset as? AVURLAsset else { return }
        
        let mixComposition = AVMutableComposition()
        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else { return }
        
        let compositionVideoTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
        
        do {
            try compositionVideoTrack?.insertTimeRange(
                CMTimeRange(start: .zero, duration: videoAsset.duration),
                of: videoTrack,
                at: .zero
            )
            
            if let audioTrack = videoAsset.tracks(withMediaType: .audio).first {
                let compositionAudioTrack = mixComposition.addMutableTrack(
                    withMediaType: .audio,
                    preferredTrackID: kCMPersistentTrackID_Invalid
                )
                
                try compositionAudioTrack?.insertTimeRange(
                    CMTimeRange(start: .zero, duration: videoAsset.duration),
                    of: audioTrack,
                    at: .zero
                )
            }
        } catch {
            return
        }
        
        let videoSize = videoTrack.naturalSize
        
        let videoComposition = AVMutableVideoComposition()
        
        guard let imageView else { return }
        guard let image = imageView.image else { return }
        
        let originalImageSize = image.size
        
        let finalWidth = max(videoSize.width, originalImageSize.width)
        let aspectRatio = videoSize.width / videoSize.height
        let finalHeight = finalWidth / aspectRatio
        let renderSize = CGSize(width: finalWidth, height: finalHeight)
        
        videoComposition.renderSize = renderSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: videoAsset.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
        
        let scale = CGAffineTransform(scaleX: renderSize.width / videoSize.width,
                                      y: renderSize.height / videoSize.height)
        layerInstruction.setTransform(scale, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        
        parentLayer.frame = CGRect(origin: .zero, size: renderSize)
        videoLayer.frame = CGRect(origin: .zero, size: renderSize)
        parentLayer.addSublayer(videoLayer)
        
        let overlayLayer = CALayer()
        overlayLayer.contents = image.cgImage
        overlayLayer.masksToBounds = false
        overlayLayer.contentsGravity = .resizeAspect
        
        let playerView = playerViewController.view!
        let imageFrameInPlayerView = imageView.convert(imageView.bounds, to: playerView)
        
        let scaleX = renderSize.width / playerView.bounds.width
        let scaleY = renderSize.height / playerView.bounds.height
        
        let centerXInPlayer = imageFrameInPlayerView.midX
        let centerYInPlayer = imageFrameInPlayerView.midY
        
        let centerXInRender = centerXInPlayer * scaleX
        let centerYInRender = (playerView.bounds.height - centerYInPlayer) * scaleY
        
        overlayLayer.frame = CGRect(
            origin: CGPoint(
                x: centerXInRender - originalImageSize.width / 2,
                y: centerYInRender - originalImageSize.height / 2
            ),
            size: originalImageSize
        )
        
        parentLayer.addSublayer(overlayLayer)
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: parentLayer
        )
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("exported.mov")
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        
        exporter.outputURL = outputURL
        exporter.outputFileType = .mov
        exporter.videoComposition = videoComposition
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                guard exporter.status == .completed else { return }
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                }) { success, error in
                    guard success else { return }
                    self.videoSavingEnded?()
                }
            }
        }
    }
}

class SelectedVideoViewController: UIViewController {
    private var selectedVideoView: SelectedVideoView!
    private var imagePicker: MediaPickerController!
    private var alert = Alert(title: "Saving video...")
    private var videoPicker: MediaPickerController!
    
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
        
        playerViewController.player = AVPlayer(url: videoURL)
        playerViewController.player?.isMuted = true
        selectedVideoView = SelectedVideoView(playerViewController: playerViewController)
        selectedVideoView.pickImageTapped = { [weak self] in
            self?.imagePicker.presentMediaPicker(forType: .image)
        }
        view = selectedVideoView
        
        playerViewController.videoGravity = .resizeAspect
        playerViewController.player?.play()
        addChild(playerViewController)
    }
    
    override func viewDidLoad() {
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        imagePicker = MediaPickerController(presenter: self)
        
        imagePicker.imagePicked = { [weak self] imageURL in
            self?.selectedVideoView.addImage(image: imageURL)
            self?.selectedVideoView.buttonsStack.layer.opacity = 0
            self?.selectedVideoView.addSaveButton()
        }
        
        selectedVideoView.videoSavingStarted = { [weak self] in
            guard let alert = self?.alert else { return }
            self?.present(alert, animated: true)
        }
        
        selectedVideoView.videoSavingEnded = { [weak self] in
            Task {
                guard let alert = self?.alert else { return }
                alert.dismiss(animated: true)
                alert.title = "Video saved"
                self?.present(alert, animated: true)
                try await Task.sleep(nanoseconds: 2_000_000_000)
                alert.dismiss(animated: true)
            }
        }
        
        videoPicker = MediaPickerController(presenter: self)
        
        selectedVideoView.changeVideoTapped = { [weak self] in
            self?.videoPicker.presentMediaPicker(forType: .video)
        }
        
        videoPicker.videoPicked = { [weak self] videoURL in
            self?.playerViewController.player = AVPlayer(url: videoURL)
            self?.playerViewController.player?.play()
        }
    }
}
