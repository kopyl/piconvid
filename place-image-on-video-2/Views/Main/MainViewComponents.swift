import UIKit

class HeroTitle: UILabel {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    func setup() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 37
        paragraphStyle.maximumLineHeight = 37
        
        let attrString = NSMutableAttributedString(string: Copy.heroTitle)
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        attributedText = attrString
        textAlignment = .center
        font = .systemFont(ofSize: 25)
        lineBreakMode = .byWordWrapping
        numberOfLines = 0
        
        translatesAutoresizingMaskIntoConstraints = false
    }

    public func placeAtTheBottom(of view: UIView) {
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -105),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 51),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -51),
        ])
    }
}
