import UIKit

struct SafeAreaPadding {
    let top: CGFloat
    let bottom: CGFloat
}

enum ButtonImportance: Int {
    case primary
    case secondary
}

func getSafeAreaPadding() -> SafeAreaPadding {
    let window = UIApplication.shared
        .connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
    
    let insets = window?.safeAreaInsets ?? .zero
    return SafeAreaPadding(top: insets.top, bottom: insets.bottom)
}

class Button: UIButton {
    var title: String?
    var systemImageName: String?
    var type: ButtonImportance = .primary
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    init(title: String, type: ButtonImportance, icon systemImageName: String? = nil) {
        self.title = title
        self.type = type
        self.systemImageName = systemImageName
        super.init(frame: .zero)
        setup()
    }
    
    private func setup() {
        guard let title else { return }
        
        let attributedStringNormal = NSMutableAttributedString(string: title)
        attributedStringNormal.addAttribute(.kern, value: -0.2, range: NSRange(location: 0, length: title.count))
        attributedStringNormal.addAttribute(.foregroundColor, value: UIColor.buttonText, range: NSRange(location: 0, length: title.count))
        setAttributedTitle(attributedStringNormal, for: .normal)
        
        let attributedStringHighlighted = NSMutableAttributedString(string: title)
        attributedStringHighlighted.addAttribute(.kern, value: -0.2, range: NSRange(location: 0, length: title.count))
        attributedStringHighlighted.addAttribute(.foregroundColor, value: UIColor.buttonText.withAlphaComponent(0.5), range: NSRange(location: 0, length: title.count))
        setAttributedTitle(attributedStringHighlighted, for: .highlighted)
        
        var fontSize: CGFloat
        switch type {
        case .primary:
            fontSize = 15
            backgroundColor = .primaryButtonBackground
        case .secondary:
            fontSize = 13
            backgroundColor = .secondaryButtonBackground
        }
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        
        translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(.buttonText, for: .normal)
        layer.cornerRadius = 4
        
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 19)
        
        guard let imageName = systemImageName else { return }
        let image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: fontSize)))
        guard let image else { return }
        
        setImage(image, for: .normal)
        imageView?.tintColor = .buttonText
        
        let insetAmount: CGFloat = 14
        imageEdgeInsets.right = insetAmount
        titleEdgeInsets.left = insetAmount
    }
    
    public func placeAtTheBottom(of view: UIView) {
        let safeAreaPaddingd = getSafeAreaPadding()
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -safeAreaPaddingd.bottom),
            heightAnchor.constraint(equalToConstant: UISizes.buttonHeight),
            widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20)
        ])
    }
}

class PillButton: UIButton {
    var title: String?
    public var topConstraint = NSLayoutConstraint()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setup()
    }
    
    private func setup() {
        guard let title else { return }
        
        let backgroundBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        backgroundBlur.layer.cornerRadius = 16
        backgroundBlur.layer.masksToBounds = true
        backgroundBlur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundBlur)
        NSLayoutConstraint.activate([
            backgroundBlur.topAnchor.constraint(equalTo: topAnchor),
            backgroundBlur.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundBlur.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundBlur.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        backgroundBlur.isUserInteractionEnabled = false
        
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 13)
        translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(.buttonText, for: .normal)
        setTitleColor(.buttonText.withAlphaComponent(0.5), for: .highlighted)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
    }
    
    public func placeAtTheTop(of view: UIView) {
        topConstraint = topAnchor.constraint(equalTo: view.topAnchor, constant: UISizes.pillButtonDistanceFromTop)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topConstraint,
            heightAnchor.constraint(equalToConstant: UISizes.pillButtonHeight),
        ])
    }
}

class MainContentContainer: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    init() {
        super.init(frame: .zero)
        setup()
    }
    func setup() {
        backgroundColor = .heroContainerBackground
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }
    public func placeAbove(button: UIView, inside: UIView) {
        let safeAreaPadding = getSafeAreaPadding()
        let bottomInset = safeAreaPadding.bottom + UISizes.buttonHeight + UISizes.mainGridSpacing
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: inside.topAnchor, constant: safeAreaPadding.top),
            bottomAnchor.constraint(equalTo: inside.bottomAnchor, constant: -bottomInset),
            leadingAnchor.constraint(equalTo: inside.leadingAnchor, constant: UISizes.mainGridSpacing),
            trailingAnchor.constraint(equalTo: inside.trailingAnchor, constant: -UISizes.mainGridSpacing)
        ])
    }
}
