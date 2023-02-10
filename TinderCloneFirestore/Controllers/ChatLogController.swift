import LBTATools
import Firebase

class ChatLogController: LBTAListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout {
    
    var currentUser: User?
    
    fileprivate lazy var customNavBar = ChatViewNavBar(match: match)
    
    fileprivate let navBarHeight: CGFloat = 120
    
    fileprivate let match: Match
    
    lazy var customInputView: CustomInputAccessoryView = {
        let civ = CustomInputAccessoryView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 50))
        civ.sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return civ
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return customInputView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    init(match: Match) {
        self.match = match
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        // scrolling collection view will result in bouncing effect even when there are less number of messages (items)
        collectionView.alwaysBounceVertical = true
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        
        collectionView.contentInset.top = navBarHeight
        
        // here right scroll bar is shown incorrect if top edge inset value is not set
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        // if this is not set, while scrolling messages collection view is visible in status bar
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentUser()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        collectionView.keyboardDismissMode = .interactive
        
        fetchMessages()
        
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Tells you if its being popped off the nav stack
        if isMovingFromParent {
            listener?.remove()
        }
    }
    
    deinit {
        print("Object is destroying itself properly, no retain cycles or any other memory related issues. Memory being reclaimed properly")
    }
    
    fileprivate func fetchCurrentUser() {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (snapshot, error) in
            let data = snapshot?.data() ?? [:]
            self.currentUser = User(dictionary: data)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Here the cell size is estimated based on the constraints set
        let estimatedSizeCell = MessageCell(frame: .init(x: 0, y: 0, width: view.frame.width, height: 1000))
        estimatedSizeCell.item = self.items[indexPath.item]
        estimatedSizeCell.layoutIfNeeded()
        
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(.init(width: view.frame.width, height: 1000))
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func handleKeyboardShow() {
        self.collectionView.scrollToItem(at: [0, items.count - 1], at: .bottom, animated: true)
    }
    
    @objc fileprivate func handleSend() {
        print(customInputView.textView.text ?? "")
        saveToFromMessages()
        saveToFromRecentMessages()
    }
    
    fileprivate func saveToFromMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // save the messages data for current user
        let collection = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid)
        
        let data = ["text": customInputView.textView.text ?? "", "fromId": currentUserId, "toId": match.uid, "timestamp": Timestamp(date: Date())] as [String : Any]
        
        collection.addDocument(data: data) { (error) in
            if let error = error {
                print("Failed to save message:", error)
                return
            }
            
            print("Successfully saved message into firestore")
            self.customInputView.textView.text = nil
            self.customInputView.placeholderLabel.isHidden = false
        }
        
        // save the messages data for matched (recipient) user
        let toCollection = Firestore.firestore().collection("matches_messages").document(match.uid).collection(currentUserId)
        
        toCollection.addDocument(data: data) { (error) in
            if let error = error {
                print("Failed to save message:", error)
                return
            }
            
            print("Successfully saved message into firestore")
            self.customInputView.textView.text = nil
            self.customInputView.placeholderLabel.isHidden = false
        }
    }
    
    fileprivate func saveToFromRecentMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // save the recent messages data for current user
        let data = ["text": customInputView.textView.text ?? "", "name": match.name, "profileImageUrl": match.profileImageUrl, "timestamp": Timestamp(date: Date()), "uid": match.uid] as [String : Any]
        
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages").document(match.uid).setData(data) { (error) in
            if let error = error {
                print("Failed to save recent message to Firestore:", error)
                return
            }
            
            print("Saved recent message")
        }
        
        // save the recent messages data for recipient user
        guard let currentUser = self.currentUser else { return }
        let toData = ["text": customInputView.textView.text ?? "", "name": currentUser.name ?? "", "profileImageUrl": currentUser.imageUrl1 ?? "", "timestamp": Timestamp(date: Date()), "uid": currentUserId] as [String : Any]
        
        Firestore.firestore().collection("matches_messages").document(match.uid).collection("recent_messages").document(currentUserId).setData(toData) { (error) in
            if let error = error {
                print("Failed to save recent message to Firestore:", error)
                return
            }
            
            print("Saved recent message")
        }
    }
    
    var listener: ListenerRegistration?
    
    fileprivate func fetchMessages() {
        print("Fetching messages")
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid).order(by: "timestamp")
        
        // This listerner will trigger whenever new message is stored in firestore
        listener = query.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Failed to fetch messages:", error)
                return
            }
            
            querySnapshot?.documentChanges.forEach({ (change) in
                if change.type == .added {
                    let dictionary = change.document.data()
                    self.items.append(.init(dictionary: dictionary))
                }
            })
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.items.count - 1], at: .bottom, animated: true)
        }
    }
    
}


