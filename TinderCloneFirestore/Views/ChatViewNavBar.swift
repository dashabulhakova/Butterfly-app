import LBTATools

class ChatViewNavBar: UIView {
    
    let userProfileImageView = CircularImageView(width: 44, image: #imageLiteral(resourceName: "photo_placeholder"))
    let nameLabel = UILabel(text: "Ім'я користувача", font: .systemFont(ofSize: 16))
    
    let backButton = UIButton(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal))
    let flagButton = UIButton(image: #imageLiteral(resourceName: "flag").withRenderingMode(.alwaysOriginal))
    
    fileprivate let match: Match
    
    init(match: Match) {
        self.match = match
        
        nameLabel.text = match.name
        userProfileImageView.sd_setImage(with: URL(string: match.profileImageUrl))
        
        super.init(frame: .zero)
        backgroundColor = .white
        
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        

        let middleStack =  hstack(
            stack(userProfileImageView, nameLabel, spacing: 8, alignment: .center),
            alignment: .center
        )

        
        hstack(backButton.withWidth(50),
               middleStack,
               flagButton).withMargins(.init(top: 0, left: 4, bottom: 0, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
