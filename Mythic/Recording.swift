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

class Recording {

    let GRA = "/Content/GetRecordingArtwork?InetRef="

    var title: String!
    var overview: String!
    var inetref: String!
    var season: String!
    var startTime: String!
    var recGroup: String!
    var posterPath: String!
    
    init(urlBase: String, recDict: Dictionary<String, AnyObject>) {
        if let title = recDict["Title"] as? String {
            self.title = title
        }
        
        if let inetref = recDict["Inetref"] as? String {
            self.inetref = inetref
        }
        
        if let season = recDict["Season"] as? String {
            self.season = season
        }
        
        if let startTime = recDict["StartTime"] as? String {
            self.startTime = startTime
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

                        // and lastly build up the good full URL
                        if urlToUse != nil {
                            self.posterPath = urlBase + urlToUse!
                        }

                        break
                    }
                }
            }
        } else if self.inetref.isEmpty == false {
            // fallback if we have an inetref
            var urlToUse = "\(urlBase)\(GRA)\(inetref)&Type=coverart"
            // if we have season info, let's use that as well
            if self.season.isEmpty == false {
                urlToUse = urlToUse + "&Season=\(self.season)"
            }

            self.posterPath = urlToUse.stringByAddingPercentEncodingWithAllowedCharacters(
                NSCharacterSet.URLQueryAllowedCharacterSet())
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
