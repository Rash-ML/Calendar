import Foundation
import UIKit

class HeaderView: UICollectionReusableView {
    
    static let identifier: String = "\(HeaderView.self)"
    
    public var text: String? {
        didSet {
            label.text = text
        }
    }
    
    private var label = UILabel() .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 12.0)
        $0.textColor = .black
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        addSubview(label)
        NSLayoutConstraint.activate(
            [
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor),
                label.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14.0),
            ]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HeaderView {
    
    func updateStyle(style: CalendarStyle) {
        label.font = style.headerStyle.font
        label.textColor = style.headerStyle.textColor
    }
}
