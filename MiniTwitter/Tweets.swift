//
//  Tweets.swift
//  MiniTwitter
//
//  Created by kkr on 24/06/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Foundation
import CoreData

class Tweets {
    static let sharedInstance = Tweets()
    
    var tweets = [Tweet]()
    let context = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
    
    func addTweet(tweet: Tweet) {
        let entity = TweetEntity(context: context)
        entity.name = tweet.name
        entity.screenName = tweet.screenName
        entity.id = tweet.since
        entity.tweet = tweet.text
        entity.createdAt = tweet.createdAt
        entity.favorited = tweet.favorited
        entity.retweeted = tweet.retweeted
        
        (NSApp.delegate as! AppDelegate).saveContext()
    }
    
    func tweetData() -> [Tweet] {
        do {
            tweets = try context.fetch(TweetEntity.fetchRequest()) as! [Tweet]
        }catch {
            print("Error fetching data from CoreData")
        }
        return tweets
    }
}
