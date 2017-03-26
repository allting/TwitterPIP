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

class Tweet: NSObject {
    var name: String!
    var text: String!
}

class ViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    
    let useACAccount = true
    dynamic var tweets: [Tweet] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()

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
                let swifter = Swifter(account: twitterAccount)
                
                swifter.getHomeTimeline(count: 20, success: { statuses in
                    print(statuses)
                    guard let tweets = statuses.array else { return }
                    self.tweets = tweets.map {
                        let tweet = Tweet()
                        tweet.text = $0["text"].string!
                        tweet.name = $0["user"]["name"].string!
                        return tweet
                    }
                    
                    self.collectionView.reloadData()
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
                        return tweet
                    }
                }, failure: failureHandler)
            }, failure: failureHandler)
        }
    }

    override func viewWillLayout() {
        super.viewWillLayout()
        
        collectionView.collectionViewLayout?.invalidateLayout()
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
        guard let collectionViewItem = item as? CollectionViewItem else {return item}

        collectionViewItem.textField?.stringValue = tweets[indexPath.item].name
        collectionViewItem.textTweet?.stringValue = tweets[indexPath.item].text
        
        collectionViewItem.textField?.sizeToFit()
        collectionViewItem.textTweet?.sizeToFit()
        return item
    }
    
}

extension ViewController : NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        let string = tweets[indexPath.item].text
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        paragraphStyle.lineHeightMultiple = 0
        paragraphStyle.lineSpacing = 3
        
        let attributes: NSDictionary = [NSFontAttributeName: NSFont.systemFont(ofSize: 13.0),
                                        NSParagraphStyleAttributeName: paragraphStyle];
        
        let textSize = NSMakeSize(260, 500)
        let textStorage = NSTextStorage.init(string: string!, attributes: attributes as? [String : Any])
        let layoutManager = NSLayoutManager.init()
        let textContainer = NSTextContainer.init(size: textSize)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0
        layoutManager.backgroundLayoutEnabled = true
        
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        var bounds = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        bounds.size.height += 40
        bounds.size.width = collectionView.bounds.width
        return  bounds.size
    }
}
