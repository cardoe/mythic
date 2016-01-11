//
//  Recording.swift
//  Mythic
//
//  Created by Doug Goldstein on 11/27/15.
//  Copyright © 2015 Doug Goldstein. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/. */
//

import Foundation

let GRA = "/Content/GetRecordingArtwork?InetRef="

func buildArtworkURL(artwork: Dictionary<String, String>) -> String? {
    // URL escape the URL because MythTV doesn't do this for us
    var urlToUse = artwork["URL"]!.stringByAddingPercentEncodingWithAllowedCharacters(
        NSCharacterSet.URLQueryAllowedCharacterSet())

    /* The issue with not URL escaping the URL you provide is when
    * it uses a query string which then contains '&' in it. I which
    * I could say I was surprised at MythTV.
    */

    // The offending field is 'FileName', which luckily is the last one
    if let filenameRange = urlToUse?.rangeOfString("FileName=") {
        // for the range after 'FileName=' we need to replace '&' with '%26'
        let subrange = Range(start: filenameRange.endIndex, end: urlToUse!.endIndex)
        urlToUse = urlToUse!.stringByReplacingOccurrencesOfString("&", withString: "%26", options: NSStringCompareOptions.LiteralSearch, range: subrange)
    }

    return urlToUse
}

func buildArtworkURLFromInetref(urlBase: String, inetref: String, img: String, season: String) -> String? {
    var urlToUse = "\(urlBase)\(GRA)\(inetref)&Type=\(img)"
    // if we have season info, let's use that as well
    if season.isEmpty == false {
        urlToUse = urlToUse + "&Season=\(season)"
    }

    return urlToUse.stringByAddingPercentEncodingWithAllowedCharacters(
        NSCharacterSet.URLQueryAllowedCharacterSet())
}

class Recording {

    var title: String!
    var subtitle: String!
    var overview: String!
    var inetref: String!
    var season: String!
    var episode: String!
    var airdate: String!
    var startTime: String!
    var endTime: String!
    var chanNum: String!
    var chanName: String!
    var recGroup: String!
    var posterPath: String!
    var backgroundPath: String!
    var bannerPath: String!

    init(urlBase: String, recDict: Dictionary<String, AnyObject>) {
        if let title = recDict["Title"] as? String {
            self.title = title
        }

        if let subtitle = recDict["SubTitle"] as? String {
            self.subtitle = subtitle
        }

        if let overview = recDict["Description"] as? String {
            self.overview = overview
        }

        if let inetref = recDict["Inetref"] as? String {
            self.inetref = inetref
        }

        if let season = recDict["Season"] as? String {
            self.season = season
        }

        if let episode = recDict["Episode"] as? String {
            self.episode = episode
        }

        if let airdate = recDict["Airdate"] as? String {
            self.airdate = airdate
        }

        if let startTime = recDict["StartTime"] as? String {
            self.startTime = startTime
        }

        if let endTime = recDict["EndTime"] as? String {
            self.endTime = endTime
        }

        // get some channel information
        if let chanObj = recDict["Channel"] as? Dictionary<String, AnyObject> {
            if let chanNum = chanObj["ChanNum"] as? String {
                self.chanNum = chanNum
            }

            if let chanName = chanObj["CallSign"] as? String {
                self.chanName = chanName
            }
        }

        /* the RecGroup contains where/why this was recorded on my machine:
         * - "Default"
         * - "Deleted"
         * - "LiveTV"
        */
        if let recordingInfo = recDict["Recording"] as? Dictionary<String, AnyObject> {
            if let recGroup = recordingInfo["RecGroup"] as? String {
                self.recGroup = recGroup
            }
        }

        // the best way to get the artwork is if the URL is included
        if let artworkObj = recDict["Artwork"] as? Dictionary<String, AnyObject> {
            if let artworkList = artworkObj["ArtworkInfos"] as? Array<Dictionary<String, String>> {
                for artwork in artworkList {
                    if artwork["Type"] == "coverart" && artwork["URL"] != nil {
                        if let uri = buildArtworkURL(artwork) {
                            self.posterPath = urlBase + uri
                        }
                    }

                    if artwork["Type"] == "fanart" && artwork["URL"] != nil {
                        if let uri = buildArtworkURL(artwork) {
                            self.backgroundPath = urlBase + uri
                        }
                    }

                    if artwork["Type"] == "banner" && artwork["URL"] != nil {
                        if let uri = buildArtworkURL(artwork) {
                            self.bannerPath = urlBase + uri
                        }
                    }
                }
            }
        } else if self.inetref.isEmpty == false {
            // fallback if we have an inetref
            if self.posterPath.isEmpty == true {
                self.posterPath = buildArtworkURLFromInetref(urlBase, inetref: self.inetref, img: "coverart", season: self.season)
            }
            if self.backgroundPath.isEmpty == true {
                self.backgroundPath = buildArtworkURLFromInetref(urlBase, inetref: self.inetref, img: "fanart", season: self.season)
            }
            if self.posterPath.isEmpty == true {
                self.bannerPath = buildArtworkURLFromInetref(urlBase, inetref: self.inetref, img: "banner", season: self.season)
            }
        }
    }

    var isRecording: Bool {
        get {
            if self.recGroup != "Deleted" && self.recGroup != "LiveTV" {
                return true
            }

            return false
        }
    }
}
