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
    var screenName: String!
    var text: String!
    var since: String!
    var createdAt: String!
    
    var favorited: Bool! = false
    var retweeted: Bool! = false
    
    var itemHeight: CGFloat! = 0
}

class ViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var tweetsArrayController: NSArrayController!
    
    let useACAccount = true
    var swifter: Swifter!
    
    dynamic var tweets: [Tweet] = []
    
    private var trackingArea: NSTrackingArea?
    
    var headerView: HeaderView? = nil
    
    var loadingMoreData = false
    
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
//        flowLayout.minimumInteritemSpacing = 0
//        flowLayout.minimumLineSpacing = 0
//        collectionView.collectionViewLayout = flowLayout
        
//        collectionView.dataSource = self
        collectionView.delegate = self

        let nib = NSNib(nibNamed: "CollectionViewItem", bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: "CollectionViewItem")

        self.view.wantsLayer = true
        collectionView.backgroundColors = [NSColor.clear]

        let headerNib = NSNib(nibNamed: "HeaderView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: NSCollectionElementKindSectionHeader, withIdentifier: "HeaderView")
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
        
//        tweetsArrayController.managedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
//        tweetsArrayController.entityName = "TweetEntity"
        
        configureCollectionView()
        adjustTrackingArea()
        self.collectionView.enclosingScrollView?.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.boundsDidChange), name: .NSViewBoundsDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.windowDidChange), name: .NSWindowDidResize, object: nil)
        
        self.view.window?.makeFirstResponder(self.collectionView)
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }

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
                    let tweetArray: [Tweet] = tweets.map {
                        let tweet = Tweet()
                        tweet.text = $0["text"].string!
                        tweet.name = $0["user"]["name"].string!
                        tweet.screenName = $0["user"]["screen_name"].string!
                        tweet.since = $0["id_str"].string!
                        tweet.favorited = $0["favorited"].bool
                        tweet.retweeted = $0["retweeted"].bool
//                        tweet.createdAt = $0["created_at"].string!
                        return tweet
                    }
                    
                    self.tweets = tweetArray
                    
                    let view = self.collectionView.makeSupplementaryView(ofKind: NSCollectionElementKindSectionHeader, withIdentifier: "HeaderView", for: IndexPath(item: 0, section: 0))
                    view.wantsLayer = true
                    if let headerView = view as? HeaderView {
                        let options = [NSDisplayNameBindingOption: "predicate", NSPredicateFormatBindingOption: "(self.name contains[cd] $value) OR (self.text contains[cd] $value)"]
                        headerView.searchField?.bind("predicate", to: self.tweetsArrayController, withKeyPath: NSFilterPredicateBinding, options: options)
                        self.headerView = headerView
                    }

                    NotificationCenter.default.addObserver(self, selector: #selector(self.tweetActions), name: Notification.Name("TweetAction"), object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.replyActions), name: Notification.Name("ReplyAction"), object: nil)
                    
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
                        tweet.text = $0["text"].string!
                        tweet.name = $0["user"]["name"].string!
//                        tweet.createdAt = $0["created_at"].string!
                        return tweet
                    }
                }, failure: failureHandler)
            }, failure: failureHandler)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func newTweet(_ sender: Any) {
        let twitterService = NSSharingService(named: NSSharingServiceNamePostOnTwitter)
        twitterService?.delegate = self
        twitterService?.perform(withItems: [""])
    }
    
    lazy var tweetWindowController : NSWindowController = {
        return self.storyboard!.instantiateController(withIdentifier: "TweetWindowController") as! NSWindowController
    }()
    
    func tweetActions(_ notification: Notification) {
        let userInfo = notification.userInfo as! Dictionary<String, Any>
        
        let tweet = userInfo["Tweet"] as! Tweet
        let action = userInfo["Action"] as! String
        let sender = userInfo["Sender"] as! NSControl
        
        switch action {
            case "Favorite":
                if tweet.favorited {
                    swifter.unfavouriteTweet(forID: tweet.since, includeEntities: true, success: { (JSON) in
                        tweet.favorited = !tweet.favorited
                    }, failure: { (Error) in
                    })
                } else {
                    swifter.favouriteTweet(forID: tweet.since, includeEntities: true, success: { (JSON) in
                        tweet.favorited = !tweet.favorited
                    }, failure: { (Error) in
                    })
                }
            case "Reply":
            print("Reply")
//            let twitterService = NSSharingService(named: NSSharingServiceNamePostOnTwitter)
//            twitterService?.delegate = self
//            twitterService?.recipients = [tweet.since]
//            twitterService?.perform(withItems: [tweet.text])
            

            self.performSegue(withIdentifier: "showTweetWindowController", sender: tweet)
//            self.tweetWindowController.contentViewController?.representedObject = tweet
//            self.tweetWindowController.showWindow(self)
//            let tweet = userInfo["Tweet"] as! Tweet
//            let reply = userInfo["Reply"] as! String
//            let sender = userInfo["Sender"] as! NSView
//            
//            swifter.postTweet(status: reply, inReplyToStatusID: tweet.since, coordinate: nil, placeID: nil, displayCoordinates: false, trimUser: nil, media_ids: [], success: { (JSON) in
//                print("succeeded reply")
//                sender.window?.close()
//            }) { (Error) in
//                print("failed reply")
//                sender.window?.close()
//            }

            case "Retweet":
                swifter.retweetTweet(forID: tweet.since, trimUser: false, success: { (JSON) in
                    tweet.retweeted = !tweet.retweeted
                }, failure: { (Error) in
                })
            case "Share":
            print("Share")
            let shareItems : NSArray = [tweet.text]
            let sharingPicker = NSSharingServicePicker(items: shareItems as! [Any])
            sharingPicker.show(relativeTo: NSZeroRect, of: sender, preferredEdge: NSRectEdge.minY)
        default:
            print("Unknown tweet action")
        }
    }
    
    func replyActions(_ notification: Notification) {
        let userInfo = notification.userInfo as! Dictionary<String, Any>
        
        let tweet = userInfo["Tweet"] as! Tweet
        let reply = userInfo["Reply"] as! String
        let sender = userInfo["Sender"] as! NSView

        swifter.postTweet(status: reply, inReplyToStatusID: tweet.since, coordinate: nil, placeID: nil, displayCoordinates: false, trimUser: nil, media_ids: [], success: { (JSON) in
            print("succeeded reply")
            sender.window?.close()
        }) { (Error) in
            print("failed reply")
            sender.window?.close()
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTweetWindowController" {
            guard let windowController = segue.destinationController as? NSWindowController else { return }
            windowController.window?.contentViewController?.representedObject = sender
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
                tweet.text = $0["text"].string!
                tweet.name = $0["user"]["name"].string!
                tweet.screenName = $0["user"]["screen_name"].string!
                tweet.since = $0["id_str"].string!
//                tweet.createdAt = $0["created_at"].string!
                return tweet
            }
            
            self.tweets = temp + self.tweets
        }, failure: failureHandler)
    }
    
    func loadMore(){
        let since = self.tweets.last?.since
        print("loadMore - \(String(describing: since))")
        let failureHandler: (Error) -> Void = {
            self.loadingMoreData = false
            print($0.localizedDescription)
        }
        
        self.swifter.getHomeTimeline(count: 20, sinceID: nil, maxID: since, success: { statuses in
            //            print(statuses)
            guard let tweets = statuses.array else { return }
            if tweets.count == 0 {
                return
            }
            
            var temp: [Tweet] = tweets.map {
                let tweet = Tweet()
                tweet.text = $0["text"].string!
                tweet.name = $0["user"]["name"].string!
                tweet.screenName = $0["user"]["screen_name"].string!
                tweet.since = $0["id_str"].string!
                //                tweet.createdAt = $0["created_at"].string!
                return tweet
            }
            
            temp.removeFirst()
            self.tweets = self.tweets + temp
            self.loadingMoreData = false
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

        self.headerView?.frame.size.width = self.collectionView.frame.size.width
        self.headerView?.needsLayout = true
    }

    func boundsDidChange() {
        if loadingMoreData {
            return
        }
        
        let visibleItems = self.collectionView.indexPathsForVisibleItems()
        for indexPath in visibleItems {
            if self.tweets.count - 1 <= indexPath.item {
                self.loadMore()
                loadingMoreData = true
                break
            }
        }
    }
    
    func windowDidChange() {
        let tweetArray: [Tweet] = self.tweets.map {
            $0.itemHeight = 0
            return $0
        }
        
        self.tweets = tweetArray
    }

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            switch event.keyCode {
            case 126:
                self.collectionView.scrollToItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
            case 125:
                self.collectionView.scrollToItems(at: [IndexPath(item: self.tweets.count-1, section: 0)], scrollPosition: .bottom)
            default:
                break
            }
        }else {
            switch event.keyCode {
            case 126:   // Up
                let indexPaths = self.collectionView.indexPathsForVisibleItems()
                if indexPaths.count == 0 {
                    return
                }
                
                var minIndexPath = indexPaths.first
                for (_, indexPath) in indexPaths.enumerated() {
                    if indexPath.item < (minIndexPath?.item)! {
                        minIndexPath = indexPath
                    }
                }
                
                if minIndexPath?.item == 0 {
                    return
                }
                
                let newIndexPath = IndexPath(item: (minIndexPath?.item)!-1, section: 0)
                self.collectionView.selectItems(at: [newIndexPath], scrollPosition: .top)
                self.collectionView.scrollToItems(at: [newIndexPath], scrollPosition: .top)
            case 125:   // Down
                let indexPaths = self.collectionView.indexPathsForVisibleItems()
                if indexPaths.count == 0 {
                    return;
                }
                
                var maxIndexPath = indexPaths.first
                for (_, indexPath) in indexPaths.enumerated() {
                    if (maxIndexPath?.item)! < indexPath.item{
                        maxIndexPath = indexPath
                    }
                }
                
                if maxIndexPath?.item == self.tweets.count - 1 {
                    return
                }
                
                let newIndexPath = IndexPath(item: (maxIndexPath?.item)!+1, section: 0)
                self.collectionView.selectItems(at: [newIndexPath], scrollPosition: .bottom)
                self.collectionView.scrollToItems(at: [newIndexPath], scrollPosition: .bottom)
            default:
                break
            }
        }
        super.keyUp(with: event)
    }
    
    override func mouseEntered(with event: NSEvent) {
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

        let tweet = tweets[indexPath.item];
        item.representedObject = tweet

        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
        var nibName: String?
        if kind == NSCollectionElementKindSectionHeader {
            nibName = "HeaderView"
        } else if kind == NSCollectionElementKindSectionFooter {
            nibName = "FooterView"
        }
        let view = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: nibName!, for: indexPath)
        
        view.wantsLayer = true
        //        view.layer?.backgroundColor = NSColor.green.cgColor
        
        if let headerView = view as? HeaderView {
            let options = [NSDisplayNameBindingOption: "predicate", NSPredicateFormatBindingOption: "(self.name contains[cd] $value) OR (self.text contains[cd] $value)"]
            headerView.searchField?.bind("predicate", to: self.tweetsArrayController, withKeyPath: NSFilterPredicateBinding, options: options)
        }
        //        } else if let view = view as? FooterView {
        //            view.titleTextField?.stringValue = "Custom Footer"
        //        }
        return view
    }
}

extension ViewController : NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        guard let tweets = self.tweetsArrayController.arrangedObjects as? NSArray else {
            return NSSize(width: collectionView.bounds.width, height: 50)
        }
        
        guard let tweet = tweets[indexPath.item] as? Tweet else {
            return NSSize(width: collectionView.bounds.width, height: 50)
        }
        
        if tweet.itemHeight == 0 {
            let string = tweet.text
            
            // TODO: Remove Magic number 24
            let textSize = NSMakeSize(collectionView.bounds.width-24, CGFloat(Float.greatestFiniteMagnitude))
            let textStorage = NSTextStorage.init(attributedString: attributedString(string!))
            let layoutManager = NSLayoutManager.init()
            let textContainer = NSTextContainer.init(size: textSize)
            
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
            textContainer.lineFragmentPadding = 0
            layoutManager.backgroundLayoutEnabled = true
            
            let glyphRange = layoutManager.glyphRange(for: textContainer)
            var bounds = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            // TODO: Optional
            bounds.size.height += (28 + 3)  // 28: title height, 3: space of items
            bounds.size.width = collectionView.bounds.width
            
            tweet.itemHeight = bounds.height
            return  bounds.size
        }else {
            return NSSize(width: collectionView.bounds.width, height: tweet.itemHeight)
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: 0, height: 60)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> NSSize {
        return NSSize(width: 0, height: 44)
    }
}

extension ViewController : NSSharingServiceDelegate {
    func sharingService(_ sharingService: NSSharingService, willShareItems items: [Any]) {
        print("sharingSevice, willShareItems: \(items)")
    }
    func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
        print("sharingSevice, didShareItems: \(items)")
    }
    func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: Error) {
        print("sharingSevice, didFailToShareItems: \(items), error: \(error)")
    }
}
