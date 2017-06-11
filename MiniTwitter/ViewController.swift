//
//  ViewController.swift
//  MiniTwitter
//
//  Created by kkr on 25/03/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa
import Accounts
import Swifter
import FormatterKit

class Tweet: NSObject {
    var name: String!
    var text: NSAttributedString!
    var since: String!
    var createdAt: String!
    
    var favorited: Bool!
    var retweeted: Bool!
}

class ViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    
    let useACAccount = true
    var swifter: Swifter!
    
    dynamic var tweets: [Tweet] = []
    
    private var trackingArea: NSTrackingArea?
    
    static let formatter: TTTTimeIntervalFormatter = {
        let formatter = TTTTimeIntervalFormatter()
        formatter.locale = NSLocale.current
        formatter.usesAbbreviatedCalendarUnits = true
        return formatter
    }()
    
    static let dateConvertFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return formatter
    }()
    

    fileprivate func configureCollectionView(){
//        let flowLayout = NSCollectionViewFlowLayout()
//        flowLayout.itemSize = NSSize(width: 300, height: 40)
//        flowLayout.sectionInset = EdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
//        flowLayout.minimumInteritemSpacing = 20
//        flowLayout.minimumLineSpacing = 10
//        collectionView.collectionViewLayout = flowLayout
        
        collectionView.dataSource = self
        collectionView.delegate = self

        view.wantsLayer = true
        collectionView.backgroundColors = [NSColor.clear]
    }
    
    fileprivate func adjustTrackingArea() {
        if (self.trackingArea != nil) {
            self.view.removeTrackingArea(self.trackingArea!)
        }
        
        self.trackingArea = NSTrackingArea.init(rect: self.view.bounds,
                                           options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways, .inVisibleRect],
                                           owner: self,
                                           userInfo: nil)
        self.view.addTrackingArea(self.trackingArea!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        adjustTrackingArea()

        let failureHandler: (Error) -> Void = { print($0.localizedDescription) }

        if useACAccount {
            let accountStore = ACAccountStore()
            let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
            
            accountStore.requestAccessToAccounts(with: accountType, options: nil) { granted, error in
                guard granted else {
                    print("There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
                    return
                }
                
                guard let twitterAccounts = accountStore.accounts(with: accountType) , !twitterAccounts.isEmpty else {
                    print("There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
                    return
                }
                
                let twitterAccount = twitterAccounts[0] as! ACAccount
                self.swifter = Swifter(account: twitterAccount)
                
                self.swifter.getHomeTimeline(count: 20, success: { statuses in
                    print(statuses)
                    guard let tweets = statuses.array else { return }
                    self.tweets = tweets.map {
                        let tweet = Tweet()
                        tweet.text = self.attributedString($0["text"].string!)
                        tweet.name = $0["user"]["name"].string!
                        tweet.since = $0["id_str"].string!
                        tweet.favorited = $0["favorited"].bool
                        tweet.retweeted = $0["retweeted"].bool
//                        tweet.createdAt = $0["created_at"].string!
                        return tweet
                    }
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(self.tweetActions), name: Notification.Name("TweetAction"), object: nil)
                    
                    self.collectionView.reloadData()
                    Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.update), userInfo: nil, repeats: true);
                    
                }, failure: failureHandler)
            }
        } else {
            let swifter = Swifter(consumerKey: "RErEmzj7ijDkJr60ayE2gjSHT", consumerSecret: "SbS0CHk11oJdALARa7NDik0nty4pXvAxdt7aj0R5y1gNzWaNEx")
            swifter.authorize(with: URL(string: "swifter://success")!, success: { _ in
                swifter.getHomeTimeline(count: 100, success: { statuses in
                    guard let tweets = statuses.array else { return }
                    self.tweets = tweets.map {
                        let tweet = Tweet()
                        tweet.text = self.attributedString($0["text"].string!)
                        tweet.name = $0["user"]["name"].string!
//                        tweet.createdAt = $0["created_at"].string!
                        return tweet
                    }
                }, failure: failureHandler)
            }, failure: failureHandler)
        }
    }

    func tweetActions(_ notification: Notification) {
        let userInfo = notification.userInfo as! Dictionary<String, Any>
        let tweet = userInfo["Tweet"]
        let action = userInfo["Action"] as! String
        
        switch action {
            case "Favorite":
            print("Favorite")
            case "Reply":
            print("Reply")
            case "Retweet":
            print("Retweet")
            case "Share":
            print("Share")
        default:
            print("Unknown tweet action")
        }
    }

    func update(){
        let since = self.tweets.first?.since
        print("update - \(String(describing: since))")
        let failureHandler: (Error) -> Void = { print($0.localizedDescription) }
        
        self.swifter.getHomeTimeline(count: 20, sinceID: since, success: { statuses in
//            print(statuses)
            guard let tweets = statuses.array else { return }
            if tweets.count == 0 {
                return
            }
            
            let temp: [Tweet] = tweets.map {
                let tweet = Tweet()
                tweet.text = self.attributedString($0["text"].string!)
                tweet.name = $0["user"]["name"].string!
                tweet.since = $0["id_str"].string!
//                tweet.createdAt = $0["created_at"].string!
                return tweet
            }
            
            self.tweets = temp + self.tweets

            self.collectionView.reloadData()
            
        }, failure: failureHandler)
    }
    
    fileprivate func attributedString(_ string: String) -> NSAttributedString{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        paragraphStyle.lineHeightMultiple = 0
        paragraphStyle.lineSpacing = 3
        
        let attributes: [String: Any] = [NSFontAttributeName: NSFont.systemFont(ofSize: 13.0),
                                         NSForegroundColorAttributeName: NSColor.darkGray,
                                        NSParagraphStyleAttributeName: paragraphStyle]

        let attributedString = NSMutableAttributedString.init(string: string, attributes: attributes)
        
        let detector = try! NSDataDetector.init(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: string, options: [], range: NSRange(location:0, length:string.utf16.count))
        
        for match in matches {
            let url = (string as NSString).substring(with: match.range)
            let attributes : [String : Any] = ["CUSTOM": url,
                                               NSFontAttributeName: NSFont.systemFont(ofSize: 13.0),
                                               NSForegroundColorAttributeName: NSColor.darkGray,
                                               NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
                                               NSParagraphStyleAttributeName: paragraphStyle,
                                               NSCursorAttributeName: NSCursor.pointingHand()]
            
            attributedString.setAttributes(attributes, range:match.range)
        }
        
        return attributedString
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        
        collectionView.collectionViewLayout?.invalidateLayout()
    }

    override func mouseEntered(with event: NSEvent) {
        print("mouseEntered - \(self.view.frame), \(self.collectionView.frame)")
        var mouseOverItemIndex = NSNotFound
        let point = self.collectionView.convert(event.locationInWindow, from: nil)
        for index in 0 ..< self.tweets.count {
            let itemFrame = self.collectionView .frameForItem(at: index)
            if(NSMouseInRect(point, itemFrame, self.view.isFlipped)){
                mouseOverItemIndex = index
                break;
            }
        }
        
        let item = self.collectionView.item(at: mouseOverItemIndex)
        guard let collectionViewItem = item as? CollectionViewItem else {return}
        
        collectionViewItem.showMenu()
        showSystemButtons(show: true)
    }

    override func mouseMoved(with event: NSEvent) {
        var mouseOverItemIndex = NSNotFound
        let point = self.collectionView.convert(event.locationInWindow, from: nil)
        for index in 0 ..< self.tweets.count {
            let itemFrame = self.collectionView .frameForItem(at: index)
            if(NSMouseInRect(point, itemFrame, self.view.isFlipped)){
                mouseOverItemIndex = index
                break;
            }
        }

        for index in 0 ..< self.tweets.count {
            let item = self.collectionView.item(at: index)
            if item == nil {
                continue
            }
            
            guard let collectionViewItem = item as? CollectionViewItem else { continue }
        
            if mouseOverItemIndex != index {
                collectionViewItem.hideMenu()
            }
        }
        
        mouseEntered(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        print("mouseExited")
        
        var mouseOverItemIndex = NSNotFound
        let point = self.collectionView.convert(event.locationInWindow, from: nil)
        for index in 0 ..< self.tweets.count {
            let itemFrame = self.collectionView .frameForItem(at: index)
            if(NSMouseInRect(point, itemFrame, self.view.isFlipped)){
                mouseOverItemIndex = index
                break;
            }
        }
        
        for index in 0 ..< self.tweets.count {
            let item = self.collectionView.item(at: index)
            if item == nil {
                continue
            }
            
            guard let collectionViewItem = item as? CollectionViewItem else { continue }
            
            collectionViewItem.hideMenu()
        }

        showSystemButtons(show: false)
    }
    
    fileprivate func showSystemButtons(show: Bool) {
        self.view.window!.standardWindowButton(NSWindowButton.closeButton)?.isHidden = !show
        self.view.window!.standardWindowButton(NSWindowButton.miniaturizeButton)?.isHidden = !show
        self.view.window!.standardWindowButton(NSWindowButton.zoomButton)?.isHidden = !show
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    @IBAction func selectFavoriteButton(_ sender: AnyObject) {
        print("selected favorite button : \(sender.tag)")
    }
    @IBAction func selectReplyButton(_ sender: AnyObject) {
        print("selected reply button : \(sender.tag)")
    }
    @IBAction func selectRetweetButton(_ sender: AnyObject) {
        print("selected retweet button : \(sender.tag)")
    }
    @IBAction func selectShareButton(_ sender: AnyObject) {
        print("selected share button : \(sender.tag)")
    }
}

extension ViewController : NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "CollectionViewItem", for: indexPath)
//        guard let collectionViewItem = item as? CollectionViewItem else {return item}

        let tweet = tweets[indexPath.item];
        item.representedObject = tweet

//        collectionViewItem.representedObject = tweet
        
//        let createdDate = ViewController.dateConvertFormatter.date(from: tweets[indexPath.item].createdAt)
//        let timeInterval = createdDate?.timeIntervalSince(Date())
//
//        collectionViewItem.createdAt?.stringValue = ViewController.formatter.string(forTimeInterval: timeInterval!)
//        collectionViewItem.createdAt?.sizeToFit()
        return item
    }
    
}

extension ViewController : NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        let string = tweets[indexPath.item].text
        
        let textSize = NSMakeSize(collectionView.bounds.width, 500)
        let textStorage = NSTextStorage.init(attributedString: string!)
        let layoutManager = NSLayoutManager.init()
        let textContainer = NSTextContainer.init(size: textSize)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0
        layoutManager.backgroundLayoutEnabled = true
        
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        var bounds = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        bounds.size.height += 28
        bounds.size.width = collectionView.bounds.width
        return  bounds.size
    }
}
