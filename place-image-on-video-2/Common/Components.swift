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
        setTitle(title, for: .normal)
        
        var fontSize: CGFloat
        switch type {
        case .primary:
            fontSize = 15
        case .secondary:
            fontSize = 13
        }
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        
        translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(.buttonText, for: .normal)
        backgroundColor = .primaryButtonBackground
        layer.cornerRadius = 4
        
        guard let imageName = systemImageName else { return }
        let image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: fontSize)))
        guard let image else { return }

        setImage(image, for: .normal)
        imageView?.tintColor = .buttonText
        
        let insetAmount: CGFloat = 16
        imageEdgeInsets.right = insetAmount
        titleEdgeInsets.left = insetAmount
    }
    
    public func placeAtTheBottom(of view: UIView) {
        let safeAreaPaddingd = getSafeAreaPadding()
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -safeAreaPaddingd.bottom),
            heightAnchor.constraint(equalToConstant: 70),
            widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20)
        ])
    }
}

class PillButton: UIButton {
    var title: String?
    
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
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
    }

    public func placeAtTheTop(of view: UIView) {        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topAnchor.constraint(equalTo: view.topAnchor, constant: 31),
            heightAnchor.constraint(equalToConstant: 32),
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
