import UIKit
import AVKit
import Photos
import Lottie

func getVideoAspectRatio(from playerViewController: AVPlayerViewController) -> CGFloat? {
    guard let asset = playerViewController.player?.currentItem?.asset else { return nil }
    guard let track = asset.tracks(withMediaType: .video).first else { return nil }

    let size = track.naturalSize
    let transform = track.preferredTransform
    let transformedSize = size.applying(transform)

    let width = abs(transformedSize.width)
    let height = abs(transformedSize.height)
    return width / height
}

class SelectedVideoView: UIView {
    
    var pickImageTapped: (() -> Void)?
    var pickDemoImageTapped: (() -> Void)?
    var changeVideoTapped: (() -> Void)?
    var startOverButtonTapped: (() -> Void)?
    
    private var playerViewController: AVPlayerViewController
    
    private var initButtonStack = ButtonStack([])
    private var finalButtonStack = ButtonStack([])
    
    private var allButtonStackContainer = AllButtonStackContainer()
    var mainContentContainer = MainContentContainer()
    
    private var imageView: DraggableImageView?
    private let pillButton = PillButton(title: Copy.Buttons.tryDemoPicture)
    
    private let dragHint = Hint(title: Copy.Hints.drag, icon: "arrow.up.and.down")
    private var savingHint: Hint?
    private var successHint: Hint?
    private var notSupportedHint: Hint?
    
    private var progressLabel: ProgressLabel?
    private var exportProgressTimer: Timer?
    public var confettiAnimation: ConfettiAnimationView?
    
    private var dragHintHidingTask: Task<(), Never>?
    public var isVideoSaving = false
    public var videoAspectRatio: CGFloat = 0
    
    public var containerAspectRatio: CGFloat {
        mainContentContainer.frame.width / mainContentContainer.frame.height
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(playerViewController: AVPlayerViewController) {
        self.playerViewController = playerViewController
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
        
        addSubview(allButtonStackContainer)
        allButtonStackContainer.placeAtTheBottom(of: self)
        
        addSubview(mainContentContainer)
        mainContentContainer.placeAbove(button: allButtonStackContainer, inside: self)
        
        addLottieAnimation()
        
        initButtonStack = ButtonStack([changeVideoButton, pickImageButton])
        allButtonStackContainer.addSubview(initButtonStack)
        initButtonStack.placeInTheCenter(of: allButtonStackContainer)
        
        addVideo()
        addPillButton()
        
        dragHint.onHintTapped = { [weak self] in
            self?.dragHintHidingTask?.cancel()
        }
        
    }
    
    public func addLottieAnimation() {
        confettiAnimation = ConfettiAnimationView(name: "confetti-lottie")
        addSubview(confettiAnimation!)
        confettiAnimation?.placeAtTheBottom(of: self)
    }
    
    private func addProgressLabel() {
        progressLabel = ProgressLabel()
        allButtonStackContainer.addSubview(progressLabel!)
        progressLabel?.placeOnTheRight(of: allButtonStackContainer)
    }
    
    func removeProgressLabel() {
        exportProgressTimer?.invalidate()
        exportProgressTimer = nil
        progressLabel?.removeFromSuperview()
    }
    
    private func addVideo() {
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        mainContentContainer.addSubview(playerViewController.view)
        
        videoAspectRatio = getVideoAspectRatio(from: playerViewController) ?? 0
        
        NSLayoutConstraint.activate([
            playerViewController.view.centerXAnchor.constraint(equalTo: mainContentContainer.centerXAnchor),
            playerViewController.view.centerYAnchor.constraint(equalTo: mainContentContainer.centerYAnchor),
            playerViewController.view.widthAnchor.constraint(equalTo: mainContentContainer.widthAnchor),
        ])
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
        
        imageView.layer.opacity = 0
        
        mainContentContainer.addSubview(imageView)
        
        let videoAR = getVideoAspectRatio(from: playerViewController)
        let imageAR = imageView.intrinsicContentSize.height / imageView.intrinsicContentSize.width
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: playerViewController.view.heightAnchor, multiplier: videoAR ?? 0),
            
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: imageAR),
            
            imageView.centerXAnchor.constraint(equalTo: playerViewController.view.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: playerViewController.view.bottomAnchor)
        ])
        
        layoutIfNeeded()
        
        UIView.animate(withDuration: 0.2) {
            imageView.layer.opacity = 1
        }
    }
    
    private func addFinalButtonStack() {
        let startOverButton = Button(title: Copy.Buttons.startOver, type: .secondary)
        let saveButton = Button(title: Copy.Buttons.saveVideo, type: .secondary, icon: "arrow.down")
        startOverButton.setContentHuggingPriority(.required, for: .horizontal)
        
        startOverButton.addTarget(self, action: #selector(startOverButtonTappedAction), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTappedAction), for: .touchUpInside)
        
        finalButtonStack = ButtonStack([startOverButton, saveButton])
        allButtonStackContainer.addSubview(finalButtonStack)
        finalButtonStack.placeInTheCenter(of: allButtonStackContainer)
    }
    
    public func removePillButton() {
        UIView.animate(withDuration: 0.1) {
            self.pillButton.topConstraint.constant = -UISizes.pillButtonHeight
            self.layoutIfNeeded()
        } completion: { _ in
            self.pillButton.removeFromSuperview()
        }
    }
    
    private func showDragHint() {
        UIView.animate(withDuration: 0.2) {
            self.allButtonStackContainer.bottomConstraint.constant = UISizes.buttonHeight
            self.layoutIfNeeded()
        } completion: { _ in
            self.initButtonStack.removeFromSuperview()
            self.allButtonStackContainer.addSubview(self.dragHint)
            self.dragHint.placeInTheCenter(of: self.allButtonStackContainer)
            self.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.2) {
                self.allButtonStackContainer.bottomConstraint.constant = -getSafeAreaPadding().bottom
                self.layoutIfNeeded()
                self.dragHint.shakeIcon()
            } completion: { _ in
                self.hideDragHint(after: 1_300_000_000)
                self.layoutIfNeeded()
            }
        }
    }
    
    private func hideDragHint(after nanoseconds: UInt64 = 0) {
        dragHintHidingTask = Task {
            try? await Task.sleep(nanoseconds: nanoseconds)
            
            UIView.animate(withDuration: 0.2) {
                self.allButtonStackContainer.bottomConstraint.constant = UISizes.buttonHeight
                self.layoutIfNeeded()
            } completion: { _ in
                self.dragHint.removeFromSuperview()
                self.addFinalButtonStack()
                self.layoutIfNeeded()
                UIView.animate(withDuration: 0.2) {
                    self.allButtonStackContainer.bottomConstraint.constant = -getSafeAreaPadding().bottom
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    private func swapVisibleButtonStacks() {
        UIView.animate(withDuration: 0.2) {
            self.allButtonStackContainer.bottomConstraint.constant = UISizes.buttonHeight
            self.layoutIfNeeded()
        } completion: { _ in
            self.initButtonStack.removeFromSuperview()
            self.addFinalButtonStack()
            self.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.2) {
                self.allButtonStackContainer.bottomConstraint.constant = -getSafeAreaPadding().bottom
                self.layoutIfNeeded()
            }
        }
    }
    
    public func showSecondStageBottomButtons() {
        if Store.hasDragMessageBeenShownAtLeastOnce {
            swapVisibleButtonStacks()
            return
        }
        showDragHint()
        Store.hasDragMessageBeenShownAtLeastOnce = true
    }
    
    private func showSavingIndicator() {
        UIView.animate(withDuration: 0.2) {
            self.allButtonStackContainer.bottomConstraint.constant = UISizes.buttonHeight
            self.layoutIfNeeded()
        } completion: { _ in
            self.savingHint = Hint(title: Copy.Hints.saving, icon: "arrow.down")
            self.allButtonStackContainer.addSubview(self.savingHint!)
            self.savingHint?.placeOnTheLeft(of: self.allButtonStackContainer)
            self.addProgressLabel()
            self.finalButtonStack.removeFromSuperview()
            self.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.2) {
                self.allButtonStackContainer.bottomConstraint.constant = -getSafeAreaPadding().bottom
                self.layoutIfNeeded()
                self.savingHint?.shakeIcon()
            }
        }
    }
    
    private func showSuccessNotification() {
        self.successHint = Hint(title: Copy.Hints.success, icon: "photo.badge.arrow.down")
        self.allButtonStackContainer.addSubview(self.successHint!)
        self.successHint?.placeInTheCenter(of: allButtonStackContainer)
        self.confettiAnimation?.shoot(inside: self)
        self.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.2) {
            self.allButtonStackContainer.bottomConstraint.constant = -getSafeAreaPadding().bottom
            self.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 2) {
                self.allButtonStackContainer.bottomConstraint.constant = UISizes.buttonHeight
                self.layoutIfNeeded()
            } completion: { _ in
                self.successHint?.removeFromSuperview()
                self.successHint = nil
                self.addFinalButtonStack()
                self.removeProgressLabel()
                self.layoutIfNeeded()
                
                UIView.animate(withDuration: 0.2) {
                    self.allButtonStackContainer.bottomConstraint.constant = -getSafeAreaPadding().bottom
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    private func notifyUserAboutSuccessSaving() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.allButtonStackContainer.bottomConstraint.constant = UISizes.buttonHeight
                self.layoutIfNeeded()
            } completion: { _ in
                self.savingHint?.removeFromSuperview()
                self.progressLabel?.removeFromSuperview()
                self.progressLabel = nil
                self.savingHint = nil
                self.showSuccessNotification()
                self.layoutIfNeeded()
            }
        }
    }
    
    private func notifyUserAboutNotSupportedImage() {
        UIView.animate(withDuration: 0.2) {
            self.allButtonStackContainer.bottomConstraint.constant = UISizes.buttonHeight
            self.layoutIfNeeded()
        }  completion: { _ in
            self.notSupportedHint = Hint(title: Copy.Hints.notSupported, icon: "xmark")
            self.allButtonStackContainer.addSubview(self.notSupportedHint!)
            self.notSupportedHint?.placeInTheCenter(of: self.allButtonStackContainer)
            self.finalButtonStack.removeFromSuperview()
            self.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.2) {
                self.allButtonStackContainer.bottomConstraint.constant = -getSafeAreaPadding().bottom
                self.layoutIfNeeded()
            } completion: { _ in
                UIView.animate(withDuration: 0.2, delay: 2) {
                    self.allButtonStackContainer.bottomConstraint.constant = UISizes.buttonHeight
                    self.layoutIfNeeded()
                } completion: { _ in
                    self.addFinalButtonStack()
                    self.notSupportedHint?.removeFromSuperview()
                    self.layoutIfNeeded()
                    
                    UIView.animate(withDuration: 0.2) {
                        self.allButtonStackContainer.bottomConstraint.constant = -getSafeAreaPadding().bottom
                        self.layoutIfNeeded()
                    }
                }
            }
        }
        
    }
    
    @objc private func tryDemoPictureTappedAction() {
        if imageView != nil { return }
        pickDemoImageTapped?()
    }
    
    @objc private func pickImageTappedAction() {
        pickImageTapped?()
    }
    
    @objc private func pickVideoTappedAction() {
        self.changeVideoTapped?()
    }
    
    @objc private func startOverButtonTappedAction() {
        self.startOverButtonTapped?()
    }
    
    @objc private func saveButtonTappedAction() {
        if imageView?.isHigherThanVideo() == true {
            /// Otherwise if an image is larger, the video will be black.
            /// Needs a fix, if i want to allow users to save videos with an image higher than a video
            notifyUserAboutNotSupportedImage()
            return
        }
        
        isVideoSaving = true
        imageView?.isDraggingDisabled = true
        showSavingIndicator()
        
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
        
        #if targetEnvironment(simulator)
        let preset = AVAssetExportPresetPassthrough
        #else
        let preset = AVAssetExportPresetHighestQuality
        #endif
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: preset) else {
            return
        }
        
        exporter.outputURL = outputURL
        exporter.outputFileType = .mov
        exporter.videoComposition = videoComposition
        
        exportProgressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.progressLabel?.progress = exporter.progress
        }
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                self.exportProgressTimer?.invalidate()
                self.exportProgressTimer = nil
                
                guard exporter.status == .completed else { return }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                }) { success, error in
                    guard success else { return }
                    self.notifyUserAboutSuccessSaving()
                    self.isVideoSaving = false
                    imageView.isDraggingDisabled = false
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
        
        imagePicker = MediaPickerController(presenter: self)
        
        imagePicker.imagePicked = { [weak self] imageURL in
            self?.moveToVideoEditor(imageURL: imageURL)
        }
        
        selectedVideoView.pickDemoImageTapped = { [weak self] in
            let demoImageURL = Bundle.main.url(forResource: "comment-demo-picture", withExtension: "png")!
            self?.moveToVideoEditor(imageURL: demoImageURL)
        }
        
        videoPicker = MediaPickerController(presenter: self)
        
        selectedVideoView.changeVideoTapped = { [weak self] in
            self?.videoPicker.presentMediaPicker(forType: .video)
        }
        
        selectedVideoView.startOverButtonTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        videoPicker.videoPicked = { [weak self] videoURL in
            self?.playerViewController.player = AVPlayer(url: videoURL)
            self?.playerViewController.player?.play()
        }
    }
    
    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            self.playerViewController.view.heightAnchor.constraint(
                equalTo: self.playerViewController.view.widthAnchor,
                multiplier: 1 / max(selectedVideoView.videoAspectRatio, selectedVideoView.containerAspectRatio)
                
            )
        ])
    }
    
    private func moveToVideoEditor(imageURL: URL) {
        selectedVideoView.addImage(image: imageURL)
        selectedVideoView.showSecondStageBottomButtons()
        selectedVideoView.removePillButton()
    }
}
