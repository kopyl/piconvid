import UIKit
import AVKit
import CoreHaptics
import Lottie

class AllButtonStackContainer: UIView {
    public var bottomConstraint = NSLayoutConstraint()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func placeAtTheBottom(of view: UIView) {
        let safeAreaPaddingd = getSafeAreaPadding()
        
        bottomConstraint = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -safeAreaPaddingd.bottom)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomConstraint,
            heightAnchor.constraint(equalToConstant: UISizes.buttonHeight),
            widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20)
        ])
    }
}

class ButtonStack: UIStackView {
    
    init(_ arrangedSubviews: [UIView]) {
        super.init(frame: .zero)
        for arrangedSubview in arrangedSubviews {
            addArrangedSubview(arrangedSubview)
        }
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        spacing = 5
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func placeInTheCenter(of view: UIView) {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
            heightAnchor.constraint(equalTo: view.heightAnchor),
            widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
}

class Alert: UIAlertController {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
}

class DraggableImageView: UIImageView {
    private var initialTouchPoint: CGPoint = .zero
    private var playerViewController: AVPlayerViewController?
    public var isDraggingDisabled: Bool = false {
        didSet {
            isUserInteractionEnabled = !isDraggingDisabled
        }
    }
    
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

class Hint: UIStackView {
    var title: String?
    var systemImageName: String
    var onHintTapped: (() -> Void)?
    
    public let imageView = UIImageView()
    
    init(title: String, icon systemImageName: String) {
        self.title = title
        self.systemImageName = systemImageName
        super.init(frame: .zero)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        spacing = 14
        translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UILabel()
        labelView.text = title
        labelView.font = .systemFont(ofSize: 13)
        labelView.layer.opacity = 0.8
        
        imageView.image = UIImage(systemName: systemImageName)
        imageView.tintColor = .white
        imageView.layer.opacity = 0.8
        
        addArrangedSubview(imageView)
        addArrangedSubview(labelView)
        
        addTapGesture()
    }
    
    public func shakeIcon() {
        let moveDistance: CGFloat = 6
        let duration = 0.3
        
        func animateUpDown() {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [.allowUserInteraction],
                animations: {
                    self.imageView.transform = CGAffineTransform(translationX: 0, y: -moveDistance)
                },
                completion: { _ in
                    UIView.animate(
                        withDuration: duration,
                        delay: 0,
                        options: [.allowUserInteraction],
                        animations: {
                            self.imageView.transform = CGAffineTransform(translationX: 0, y: moveDistance)
                        },
                        completion: { _ in
                            /// Repeat
                            animateUpDown()
                        })
                })
        }
        
        animateUpDown()
    }
    
    public func placeInTheCenter(of view: UIView) {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    public func placeOnTheLeft(of view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    public func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hintTapped))
        self.addGestureRecognizer(tapGesture)
    }
    @objc private func hintTapped() {
        onHintTapped?()
    }
}

class ProgressLabel: UILabel {
    var progress: Float = 0.0 {
        didSet {
            self.text = "\(Int(progress * 100))%"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        textAlignment = .right
        font = .systemFont(ofSize: 13)
        layer.opacity = 0.8
    }
    
    public func placeOnTheRight(of view: UIView) {
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

class ConfettiAnimationView: LottieAnimationView {
    private var name: String
    var hapticEngine: CHHapticEngine?
    
    init(name: String) {
        self.name = name
        
        let animation = LottieAnimation.named(name, bundle: Bundle.main, subdirectory: nil, animationCache: LottieAnimationCache.shared)
        let provider = BundleImageProvider(bundle: Bundle.main, searchPath: nil)
        super.init(animation: animation, imageProvider: provider, configuration: .shared)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    func setup() {
        contentMode = .scaleAspectFill
        translatesAutoresizingMaskIntoConstraints = false
        loopMode = .playOnce
        animationSpeed = 1.5
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        isUserInteractionEnabled = false
    }
    
    public func placeAtTheBottom(of view: UIView) {
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    private func remove(from view: SelectedVideoView) {
        isHidden = true
        stop()
        removeFromSuperview()
        view.confettiAnimation = nil
    }
    
    public func shoot(inside view: SelectedVideoView) {
        isHidden = false
        
        generateHapticPattern()
        
        play() { [weak self, weak view] _ in
            guard let v = view else { return }
            self?.remove(from: v)
            v.addLottieAnimation()
        }
    }
    
    func generateHapticPattern() {
        do {
            if hapticEngine == nil {
                hapticEngine = try CHHapticEngine()
            }
            try hapticEngine?.start()

            var events = [CHHapticEvent]()
            for i in 0..<20 { /// 20 pulses
                let time = Double(i) * 0.025 /// 25ms between pulses
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
                ], relativeTime: time)
                events.append(event)
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)

        } catch {
            print("Haptic pattern failed: \(error)")
        }
    }
}
