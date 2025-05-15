import UIKit

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

class Alert: UIAlertController {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
}
