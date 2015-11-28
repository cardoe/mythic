//
//  Show.swift
//  Mythic
//
//  Created by Doug Goldstein on 11/27/15.
//  Copyright © 2015 Doug Goldstein. All rights reserved.
//

import Foundation

class Show {
    
    let URL_BASE = "http://192.168.2.46:6544"
    let GRA = "/Content/GetRecordingArtwork?InetRef="
    
    var title: String!
    var overview: String!
    var inetref: String!
    var season: String!
    var startTime: String!
    var posterPath: String!
    
    init(showDict: Dictionary<String, AnyObject>) {
        if let title = showDict["Title"] as? String {
            self.title = title
        }
        
        if let overview = showDict["Description"] as? String {
            self.overview = overview
        }
        
        if let inetref = showDict["Inetref"] as? String {
            self.inetref = inetref
        }
        
        if let season = showDict["Season"] as? String {
            self.season = season
        }
        
        if let startTime = showDict["StartTime"] as? String {
            self.startTime = startTime
        }
        
        // the best way to get the artwork is if the URL is included
        if let artworkObj = showDict["Artwork"] as? Dictionary<String, AnyObject> {
            if let artworkList = artworkObj["ArtworkInfos"] as? Array<Dictionary<String, String>> {
                for artwork in artworkList {
                    if artwork["Type"] == "coverart" && artwork["URL"] != nil {
                        self.posterPath = URL_BASE + artwork["URL"]!
                    }
                }
            }
        } else if self.inetref.isEmpty == false {
            // fallback if we have an inetref
            self.posterPath = "\(URL_BASE)\(GRA)\(inetref)&Type=coverart"
            // if we have season info, let's use that as well
            if self.season.isEmpty == false {
                self.posterPath = self.posterPath! + "&Season=\(self.season)"
            }
        }
    }
}