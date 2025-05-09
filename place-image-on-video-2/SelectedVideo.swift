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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(playerViewController: AVPlayerViewController) {
        self.playerViewController = playerViewController
        pickImageButton = Button(title: "Pick Image to place on top of this video")
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
        let imageView = DraggableImageView(playerViewController: playerViewController)
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
            print("Missing video URL")
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
        } catch {
            print("Failed to insert video: \(error)")
            return
        }
        
        let videoSize = videoTrack.naturalSize
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: videoAsset.duration)
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        // Create layers
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: videoSize)
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        parentLayer.addSublayer(videoLayer)

        // Grab draggable image from subview
        guard let imageView = self.subviews.first(where: { $0 is DraggableImageView }) as? DraggableImageView,
              let image = imageView.image else {
            print("No image to overlay")
            return
        }

        let overlayLayer = CALayer()
        overlayLayer.contents = image.cgImage
        overlayLayer.contentsGravity = .resizeAspectFill
        overlayLayer.masksToBounds = true

        // Calculate position relative to video frame
        let playerView = playerViewController.view!
        
        // Convert imageView frame to playerViewController.view
        let imageFrameInPlayerView = imageView.convert(imageView.bounds, to: playerView)
        
        let scaleX = videoSize.width / playerView.frame.width
        let scaleY = videoSize.height / playerView.frame.height
        
        // Final overlay frame (flipped Y)
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

        // Export
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("exported.mov")
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            print("Failed to create exporter")
            return
        }
        exporter.outputURL = outputURL
        exporter.outputFileType = .mov
        exporter.videoComposition = videoComposition

        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                if exporter.status == .completed {
                    // Save to Photos
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                    }) { success, error in
                        DispatchQueue.main.async {
                            if success {
                                print("✅ Saved to Photos")
                            } else {
                                print("❌ Failed saving to Photos: \(error?.localizedDescription ?? "Unknown error")")
                            }
                        }
                    }
                } else {
                    print("❌ Export failed: \(exporter.error?.localizedDescription ?? "Unknown error")")
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
