import UIKit

class Button: UIButton {
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
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(.systemBlue, for: .normal)
    }
    
    public func placeAtTheBottom(of view: UIView) {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
        ])
    }
}
