//
//  WorldTweetsTests.swift
//  WorldTweetsTests
//
//  Created by David Marmoy on 10/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import XCTest
@testable import WorldTweets

class WorldTweetsParserTests: XCTestCase {

    var parser: WTTweetParser!

    override func setUp() {
        super.setUp()
        parser = WTTweetParser()
    }

    override func tearDown() {
        super.tearDown()
    }

    /**
     Tests the following:
     1. That the parser finds and parses all statuses with coordinates
     2. That the parser accurately extracts the coordinates
     3. That the parser stores a trailing incomplete status
     */
    func testParseValidLocations() {
        let sliceIndex: String.Index = nonGeoEnabledStatus.index(of: ",")!
        let expectedJsonRemainder = String(nonGeoEnabledStatus[...sliceIndex])
        let statusArray: [String] = [nonGeoEnabledStatus, nonGeoEnabledStatus, geoEnabledStatus, geoEnabledStatus, nonGeoEnabledStatus, geoEnabledStatus, expectedJsonRemainder]
        let data = statusArray.joined(separator: "\r\n").data(using: .utf8)!

        parser.parse(input: data, completion: { (tweets) in
            XCTAssert(tweets.count == 3)
            XCTAssert(tweets[2].coordinates.latitude == -31.75527778)
            XCTAssert(tweets[2].coordinates.longitude == 60.5125)
        })
    }

    /**
     Tests the following:
     1. That the parser recognises that there are no statuses with coordinates
     2. That the jsonRemainder is empty when there is no trailing incomplete status
     */
    func testParseNoValidLocations() {
        let statusArray: [String] = [nonGeoEnabledStatus, nonGeoEnabledStatus, nonGeoEnabledStatus]
        let data = statusArray.joined(separator: "\r\n").data(using: .utf8)!

        parser.parse(input: data, completion: { (tweets) in
            XCTAssert(tweets.count == 0)
        })
    }

    /*
     Measurements show that worst-case scenario the didReceive data delegate method is called every 10 milliseconds
     Means that the
     The average data chunk is around 13500 bytes
     */
    func testNewParserPerformance() {
        let data = getDataForParserPerformanceTest(numberOfTweets: 1000)

        // This is the way to measure asynchronous calls
        self.measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
            self.startMeasuring()

            parser.parse(input: data, completion: { (_) in
                self.stopMeasuring()
            })
        }
    }
}

// MARK: Test data
extension WorldTweetsParserTests {
    func getDataForParserPerformanceTest(numberOfTweets: Int) -> Data {
        var statusArray = [String]()
        var shouldHaveGeoLocation = false
        for _ in 0...numberOfTweets {
            statusArray.append(shouldHaveGeoLocation ? geoEnabledStatus : nonGeoEnabledStatus)
            shouldHaveGeoLocation = !shouldHaveGeoLocation
        }

        return statusArray.joined(separator: "\r\n").data(using: .utf8)!
    }

    var geoEnabledStatus: String {
        return "{\"created_at\":\"Thu Oct 12 12:30:06 +0000 2017\",\"id\":918453724661604352,\"id_str\":\"918453724661604352\",\"text\":\"Wind 11,2 km\\/h SSW. Barometer 1014,1 hPa, Rising slowly. Temperature 11,9 \\u00b0C. Rain today 0,3 mm. Humidity 99%\",\"source\":\"\\u003ca href=\\\"http:\\/\\/sandaysoft.com\\/\\\" rel=\\\"nofollow\\\"\\u003eSandaysoft Cumulus\\u003c\\/a\\u003e\",\"truncated\":false,\"in_reply_to_status_id\":null,\"in_reply_to_status_id_str\":null,\"in_reply_to_user_id\":null,\"in_reply_to_user_id_str\":null,\"in_reply_to_screen_name\":null,\"user\":{\"id\":115758763,\"id_str\":\"115758763\",\"name\":\"Dario Giorgio\",\"screen_name\":\"dardigior\",\"location\":\"Argentina\",\"url\":\"http:\\/\\/www.wunderground.com\\/weatherstation\\/WXDailyHistory.asp?ID=IENTRERO8\",\"description\":null,\"translator_type\":\"none\",\"protected\":false,\"verified\":false,\"followers_count\":242,\"friends_count\":1441,\"listed_count\":3,\"favourites_count\":43,\"statuses_count\":139029,\"created_at\":\"Fri Feb 19 21:01:37 +0000 2010\",\"utc_offset\":null,\"time_zone\":null,\"geo_enabled\":true,\"lang\":\"es\",\"contributors_enabled\":false,\"is_translator\":false,\"profile_background_color\":\"C0DEED\",\"profile_background_image_url\":\"http:\\/\\/abs.twimg.com\\/images\\/themes\\/theme1\\/bg.png\",\"profile_background_image_url_https\":\"https:\\/\\/abs.twimg.com\\/images\\/themes\\/theme1\\/bg.png\",\"profile_background_tile\":false,\"profile_link_color\":\"1DA1F2\",\"profile_sidebar_border_color\":\"C0DEED\",\"profile_sidebar_fill_color\":\"DDEEF6\",\"profile_text_color\":\"333333\",\"profile_use_background_image\":true,\"profile_image_url\":\"http:\\/\\/pbs.twimg.com\\/profile_images\\/661981737086529536\\/l4rFRoDJ_normal.jpg\",\"profile_image_url_https\":\"https:\\/\\/pbs.twimg.com\\/profile_images\\/661981737086529536\\/l4rFRoDJ_normal.jpg\",\"profile_banner_url\":\"https:\\/\\/pbs.twimg.com\\/profile_banners\\/115758763\\/1446663767\",\"default_profile\":true,\"default_profile_image\":false,\"following\":null,\"follow_request_sent\":null,\"notifications\":null},\"geo\":{\"type\":\"Point\",\"coordinates\":[-31.75527778,60.5125]},\"coordinates\":{\"type\":\"Point\",\"coordinates\":[60.5125,-31.75527778]},\"place\":null,\"contributors\":null,\"is_quote_status\":false,\"quote_count\":0,\"reply_count\":0,\"retweet_count\":0,\"favorite_count\":0,\"entities\":{\"hashtags\":[],\"urls\":[],\"user_mentions\":[],\"symbols\":[]},\"favorited\":false,\"retweeted\":false,\"filter_level\":\"low\",\"lang\":\"en\",\"timestamp_ms\":\"1507811406661\"}"
    }

    var nonGeoEnabledStatus: String {
        return "{\"created_at\":\"Thu Oct 12 12:30:06 +0000 2017\",\"id\":918453724678275072,\"id_str\":\"918453724678275072\",\"text\":\"RT @scjsora146: \\uc6c3\\uc74c \\ud3ed\\ubc1c! \\ud790\\ub9c1 \\ub9cc\\uc810! \\uc2dc~\\uc6d0\\ud558\\ub2e4 \\ud558\\ub298 \\ud31f^^!!\\nhttps:\\/\\/t.co\\/dLb4Zs6gbW\\n#\\ud558\\ub298\\ud31f https:\\/\\/t.co\\/kLNeZXHgyL\",\"source\":\"\\u003ca href=\\\"http:\\/\\/twitter.com\\/download\\/android\\\" rel=\\\"nofollow\\\"\\u003eTwitter for Android\\u003c\\/a\\u003e\",\"truncated\":false,\"in_reply_to_status_id\":null,\"in_reply_to_status_id_str\":null,\"in_reply_to_user_id\":null,\"in_reply_to_user_id_str\":null,\"in_reply_to_screen_name\":null,\"user\":{\"id\":732544229436588036,\"id_str\":\"732544229436588036\",\"name\":\"BADADA\",\"screen_name\":\"joshjojo98\",\"location\":null,\"url\":null,\"description\":\"\\ubba4\\uc9c1 \\uc815\\uce58 \\uc601\\ud654 \\ubbf8\\ub514\\uc5b4 \\uc5b8\\ub860\\uc0ac \\uc544\\ud2b8&\\ubb38\\ud654 Fun\",\"translator_type\":\"none\",\"protected\":false,\"verified\":false,\"followers_count\":4044,\"friends_count\":4998,\"listed_count\":1,\"favourites_count\":32,\"statuses_count\":1496,\"created_at\":\"Tue May 17 12:12:09 +0000 2016\",\"utc_offset\":null,\"time_zone\":null,\"geo_enabled\":false,\"lang\":\"ko\",\"contributors_enabled\":false,\"is_translator\":false,\"profile_background_color\":\"F5F8FA\",\"profile_background_image_url\":\"\",\"profile_background_image_url_https\":\"\",\"profile_background_tile\":false,\"profile_link_color\":\"1DA1F2\",\"profile_sidebar_border_color\":\"C0DEED\",\"profile_sidebar_fill_color\":\"DDEEF6\",\"profile_text_color\":\"333333\",\"profile_use_background_image\":true,\"profile_image_url\":\"http:\\/\\/pbs.twimg.com\\/profile_images\\/732551877737349120\\/W6CEjOMT_normal.jpg\",\"profile_image_url_https\":\"https:\\/\\/pbs.twimg.com\\/profile_images\\/732551877737349120\\/W6CEjOMT_normal.jpg\",\"profile_banner_url\":\"https:\\/\\/pbs.twimg.com\\/profile_banners\\/732544229436588036\\/1463488951\",\"default_profile\":true,\"default_profile_image\":false,\"following\":null,\"follow_request_sent\":null,\"notifications\":null},\"geo\":null,\"coordinates\":null,\"place\":null,\"contributors\":null,\"retweeted_status\":{\"created_at\":\"Sun Oct 01 15:00:52 +0000 2017\",\"id\":914505400535232513,\"id_str\":\"914505400535232513\",\"text\":\"\\uc6c3\\uc74c \\ud3ed\\ubc1c! \\ud790\\ub9c1 \\ub9cc\\uc810! \\uc2dc~\\uc6d0\\ud558\\ub2e4 \\ud558\\ub298 \\ud31f^^!!\\nhttps:\\/\\/t.co\\/dLb4Zs6gbW\\n#\\ud558\\ub298\\ud31f https:\\/\\/t.co\\/kLNeZXHgyL\",\"display_text_range\":[0,57],\"source\":\"\\u003ca href=\\\"http:\\/\\/twitter.com\\/download\\/android\\\" rel=\\\"nofollow\\\"\\u003eTwitter for Android\\u003c\\/a\\u003e\",\"truncated\":false,\"in_reply_to_status_id\":null,\"in_reply_to_status_id_str\":null,\"in_reply_to_user_id\":null,\"in_reply_to_user_id_str\":null,\"in_reply_to_screen_name\":null,\"user\":{\"id\":905371754,\"id_str\":\"905371754\",\"name\":\"sora\",\"screen_name\":\"scjsora146\",\"location\":null,\"url\":null,\"description\":\"\\uc0ac\\ub791\\ud558\\uae30 \\uc88b\\uc740 \\ub0a0~\\ud83c\\udf37\\ud83c\\udf37\\n(100% \\ub9de\\ud314)\",\"translator_type\":\"none\",\"protected\":false,\"verified\":false,\"followers_count\":6617,\"friends_count\":7127,\"listed_count\":18,\"favourites_count\":160,\"statuses_count\":24154,\"created_at\":\"Fri Oct 26 05:43:23 +0000 2012\",\"utc_offset\":28800,\"time_zone\":\"Irkutsk\",\"geo_enabled\":true,\"lang\":\"ko\",\"contributors_enabled\":false,\"is_translator\":false,\"profile_background_color\":\"C0DEED\",\"profile_background_image_url\":\"http:\\/\\/abs.twimg.com\\/images\\/themes\\/theme1\\/bg.png\",\"profile_background_image_url_https\":\"https:\\/\\/abs.twimg.com\\/images\\/themes\\/theme1\\/bg.png\",\"profile_background_tile\":false,\"profile_link_color\":\"1DA1F2\",\"profile_sidebar_border_color\":\"C0DEED\",\"profile_sidebar_fill_color\":\"DDEEF6\",\"profile_text_color\":\"333333\",\"profile_use_background_image\":true,\"profile_image_url\":\"http:\\/\\/pbs.twimg.com\\/profile_images\\/806041819326750720\\/9KrHK_tt_normal.jpg\",\"profile_image_url_https\":\"https:\\/\\/pbs.twimg.com\\/profile_images\\/806041819326750720\\/9KrHK_tt_normal.jpg\",\"profile_banner_url\":\"https:\\/\\/pbs.twimg.com\\/profile_banners\\/905371754\\/1479733106\",\"default_profile\":true,\"default_profile_image\":false,\"following\":null,\"follow_request_sent\":null,\"notifications\":null},\"geo\":null,\"coordinates\":null,\"place\":null,\"contributors\":null,\"is_quote_status\":false,\"quote_count\":0,\"reply_count\":3,\"retweet_count\":179,\"favorite_count\":61,\"entities\":{\"hashtags\":[{\"text\":\"\\ud558\\ub298\\ud31f\",\"indices\":[53,57]}],\"urls\":[{\"url\":\"https:\\/\\/t.co\\/dLb4Zs6gbW\",\"expanded_url\":\"http:\\/\\/bit.ly\\/2vxF5g1\",\"display_url\":\"bit.ly\\/2vxF5g1\",\"indices\":[29,52]}],\"user_mentions\":[],\"symbols\":[],\"media\":[{\"id\":914505396194230273,\"id_str\":\"914505396194230273\",\"indices\":[58,81],\"media_url\":\"http:\\/\\/pbs.twimg.com\\/media\\/DLD50AVVwAE46Fa.jpg\",\"media_url_https\":\"https:\\/\\/pbs.twimg.com\\/media\\/DLD50AVVwAE46Fa.jpg\",\"url\":\"https:\\/\\/t.co\\/kLNeZXHgyL\",\"display_url\":\"pic.twitter.com\\/kLNeZXHgyL\",\"expanded_url\":\"https:\\/\\/twitter.com\\/scjsora146\\/status\\/914505400535232513\\/photo\\/1\",\"type\":\"photo\",\"sizes\":{\"thumb\":{\"w\":150,\"h\":150,\"resize\":\"crop\"},\"large\":{\"w\":599,\"h\":389,\"resize\":\"fit\"},\"small\":{\"w\":599,\"h\":389,\"resize\":\"fit\"},\"medium\":{\"w\":599,\"h\":389,\"resize\":\"fit\"}}}]},\"extended_entities\":{\"media\":[{\"id\":914505396194230273,\"id_str\":\"914505396194230273\",\"indices\":[58,81],\"media_url\":\"http:\\/\\/pbs.twimg.com\\/media\\/DLD50AVVwAE46Fa.jpg\",\"media_url_https\":\"https:\\/\\/pbs.twimg.com\\/media\\/DLD50AVVwAE46Fa.jpg\",\"url\":\"https:\\/\\/t.co\\/kLNeZXHgyL\",\"display_url\":\"pic.twitter.com\\/kLNeZXHgyL\",\"expanded_url\":\"https:\\/\\/twitter.com\\/scjsora146\\/status\\/914505400535232513\\/photo\\/1\",\"type\":\"photo\",\"sizes\":{\"thumb\":{\"w\":150,\"h\":150,\"resize\":\"crop\"},\"large\":{\"w\":599,\"h\":389,\"resize\":\"fit\"},\"small\":{\"w\":599,\"h\":389,\"resize\":\"fit\"},\"medium\":{\"w\":599,\"h\":389,\"resize\":\"fit\"}}}]},\"favorited\":false,\"retweeted\":false,\"possibly_sensitive\":false,\"filter_level\":\"low\",\"lang\":\"ko\"},\"is_quote_status\":false,\"quote_count\":0,\"reply_count\":0,\"retweet_count\":0,\"favorite_count\":0,\"entities\":{\"hashtags\":[{\"text\":\"\\ud558\\ub298\\ud31f\",\"indices\":[69,73]}],\"urls\":[{\"url\":\"https:\\/\\/t.co\\/dLb4Zs6gbW\",\"expanded_url\":\"http:\\/\\/bit.ly\\/2vxF5g1\",\"display_url\":\"bit.ly\\/2vxF5g1\",\"indices\":[45,68]}],\"user_mentions\":[{\"screen_name\":\"scjsora146\",\"name\":\"sora\",\"id\":905371754,\"id_str\":\"905371754\",\"indices\":[3,14]}],\"symbols\":[],\"media\":[{\"id\":914505396194230273,\"id_str\":\"914505396194230273\",\"indices\":[74,97],\"media_url\":\"http:\\/\\/pbs.twimg.com\\/media\\/DLD50AVVwAE46Fa.jpg\",\"media_url_https\":\"https:\\/\\/pbs.twimg.com\\/media\\/DLD50AVVwAE46Fa.jpg\",\"url\":\"https:\\/\\/t.co\\/kLNeZXHgyL\",\"display_url\":\"pic.twitter.com\\/kLNeZXHgyL\",\"expanded_url\":\"https:\\/\\/twitter.com\\/scjsora146\\/status\\/914505400535232513\\/photo\\/1\",\"type\":\"photo\",\"sizes\":{\"thumb\":{\"w\":150,\"h\":150,\"resize\":\"crop\"},\"large\":{\"w\":599,\"h\":389,\"resize\":\"fit\"},\"small\":{\"w\":599,\"h\":389,\"resize\":\"fit\"},\"medium\":{\"w\":599,\"h\":389,\"resize\":\"fit\"}},\"source_status_id\":914505400535232513,\"source_status_id_str\":\"914505400535232513\",\"source_user_id\":905371754,\"source_user_id_str\":\"905371754\"}]},\"extended_entities\":{\"media\":[{\"id\":914505396194230273,\"id_str\":\"914505396194230273\",\"indices\":[74,97],\"media_url\":\"http:\\/\\/pbs.twimg.com\\/media\\/DLD50AVVwAE46Fa.jpg\",\"media_url_https\":\"https:\\/\\/pbs.twimg.com\\/media\\/DLD50AVVwAE46Fa.jpg\",\"url\":\"https:\\/\\/t.co\\/kLNeZXHgyL\",\"display_url\":\"pic.twitter.com\\/kLNeZXHgyL\",\"expanded_url\":\"https:\\/\\/twitter.com\\/scjsora146\\/status\\/914505400535232513\\/photo\\/1\",\"type\":\"photo\",\"sizes\":{\"thumb\":{\"w\":150,\"h\":150,\"resize\":\"crop\"},\"large\":{\"w\":599,\"h\":389,\"resize\":\"fit\"},\"small\":{\"w\":599,\"h\":389,\"resize\":\"fit\"},\"medium\":{\"w\":599,\"h\":389,\"resize\":\"fit\"}},\"source_status_id\":914505400535232513,\"source_status_id_str\":\"914505400535232513\",\"source_user_id\":905371754,\"source_user_id_str\":\"905371754\"}]},\"favorited\":false,\"retweeted\":false,\"possibly_sensitive\":false,\"filter_level\":\"low\",\"lang\":\"ko\",\"timestamp_ms\":\"1507811406665\"}"
    }
}
