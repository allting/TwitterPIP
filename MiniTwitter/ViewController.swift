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
    @IBOutlet weak var visualView: NSVisualEffectView?
    
    let useACAccount = true
    dynamic var tweets: [Tweet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.visualView?.blendingMode = NSVisualEffectBlendingMode.behindWindow
        self.visualView?.state = NSVisualEffectState.active

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
//                    guard let tweets = statuses.array else { return }
//                    self.tweets = tweets.map {
//                        let tweet = Tweet()
//                        tweet.text = $0["text"].string!
//                        tweet.name = $0["user"]["name"].string!
//                        return tweet
//                    }
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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

