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

class DraggableImageView: UIImageView {
    private var initialTouchPoint: CGPoint = .zero
    private var playerViewController: AVPlayerViewController?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(playerViewController: AVPlayerViewController) {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        self.playerViewController = playerViewController
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        initialTouchPoint = touch.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let superview = self.superview else { return }

        let locationInSuperview = touch.location(in: superview)
        var centerY: CGFloat = 0
        centerY = locationInSuperview.y - initialTouchPoint.y + self.bounds.size.height / 2

        let bottomLimit = playerViewController?.view.frame.minY ?? 0
        let topLimit = playerViewController?.view.frame.maxY ?? 0
        if centerY < bottomLimit + self.bounds.size.height / 2 {
            centerY = bottomLimit + self.bounds.size.height / 2
        } else if centerY > topLimit - self.bounds.size.height / 2 {
            centerY = topLimit - self.bounds.size.height / 2
        }
        
        self.center.y = centerY
    }
}

class SelectedVideoView: UIView {
    var pickImageTapped: (() -> Void)?
    private var playerViewController: AVPlayerViewController
    public var pickImageButton: Button
    public var imageView: DraggableImageView?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(playerViewController: AVPlayerViewController) {
        self.playerViewController = playerViewController
        pickImageButton = Button(title: "Select overlay image")
        super.init(frame: .zero)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .appBackground
        
        guard let videoAspectRatio = getVideoAspectRatio(from: playerViewController) else { return }
        
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playerViewController.view)
        
        pickImageButton.addTarget(self, action: #selector(pickImageTappedAction), for: .touchUpInside)
        addSubview(pickImageButton)
        pickImageButton.placeAtTheBottom(of: self)
        
        NSLayoutConstraint.activate([
            playerViewController.view.centerXAnchor.constraint(equalTo: centerXAnchor),
            playerViewController.view.centerYAnchor.constraint(equalTo: centerYAnchor),
            playerViewController.view.widthAnchor.constraint(equalTo: widthAnchor, constant: -50),
            playerViewController.view.heightAnchor.constraint(equalTo: playerViewController.view.widthAnchor, multiplier: 1 / videoAspectRatio),
       ])
    }
    
    public func addImage(image: URL) {
        imageView = DraggableImageView(playerViewController: playerViewController)
        guard let imageView else { return }
        imageView.image = UIImage(contentsOfFile: image.path)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        
        let imageRatio = imageView.intrinsicContentSize.height / imageView.intrinsicContentSize.width
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: playerViewController.view.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: playerViewController.view.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: playerViewController.view.bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: imageRatio),
        ])
    }
    
    public func addSaveButton() {
        let saveButton = Button(title: "Save video")
        saveButton.addTarget(self, action: #selector(saveButtonTappedAction), for: .touchUpInside)
        addSubview(saveButton)
        saveButton.placeAtTheBottom(of: self)
    }
    
    @objc private func pickImageTappedAction() {
        pickImageTapped?()
    }
    
    @objc private func saveButtonTappedAction() {
        guard let videoAsset = playerViewController.player?.currentItem?.asset as? AVURLAsset else {
            return
        }
        
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
        guard let overlaySize = imageView.image?.size else { return }
        
        let finalWidth = max(videoSize.width, overlaySize.width)
        let aspectRatio = videoSize.width / videoSize.height
        let finalHeight = finalWidth / aspectRatio
        let renderSize = CGSize(width: finalWidth, height: finalHeight)
        
        videoComposition.renderSize = CGSize(width: finalWidth, height: finalHeight)
        
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: videoAsset.duration)
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
        
        let naturalSize = videoTrack.naturalSize
        let scale = CGAffineTransform(scaleX: renderSize.width / naturalSize.width,
                                      y: renderSize.height / naturalSize.height)

        layerInstruction.setTransform(scale, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        
        parentLayer.frame = CGRect(origin: .zero, size: renderSize)
        videoLayer.frame = CGRect(origin: .zero, size: renderSize)
        parentLayer.addSublayer(videoLayer)
        
        guard let imageView = self.subviews.first(where: { $0 is DraggableImageView }) as? DraggableImageView,
              let image = imageView.image else {
            return
        }

        let overlayLayer = CALayer()
        overlayLayer.contents = image.cgImage
        overlayLayer.contentsGravity = .resizeAspectFill
        overlayLayer.masksToBounds = true
        
        let playerView = playerViewController.view!
        
        let imageFrameInPlayerView = imageView.convert(imageView.bounds, to: playerView)
        
        let scaleX = renderSize.width / playerView.frame.width
        let scaleY = renderSize.height / playerView.frame.height
        
        let flippedY = playerView.frame.height - imageFrameInPlayerView.maxY
        
        overlayLayer.frame = CGRect(
            x: imageFrameInPlayerView.minX * scaleX,
            y: flippedY * scaleY,
            width: imageFrameInPlayerView.width * scaleX,
            height: imageFrameInPlayerView.height * scaleY
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
                        print("✅ Saved to Photos")
                    }
            }
        }
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
        
        playerViewController.player = AVPlayer(url: videoURL)
        playerViewController.player?.isMuted = true
        selectedVideoView = SelectedVideoView(playerViewController: playerViewController)
        selectedVideoView.pickImageTapped = { [weak self] in
            self?.imagePicker.presentMediaPicker(forType: .image)
        }
        view = selectedVideoView
        
        playerViewController.videoGravity = .resize
        playerViewController.player?.play()
        addChild(playerViewController)
    }
    
    override func viewDidLoad() {
        imagePicker = MediaPickerController(presenter: self)
        
        imagePicker.imagePicked = { [weak self] imageURL in
            self?.selectedVideoView.addImage(image: imageURL)
            self?.selectedVideoView.pickImageButton.layer.opacity = 0
            self?.selectedVideoView.addSaveButton()
        }
    }
}
