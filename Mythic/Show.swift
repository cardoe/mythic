//
//  Show.swift
//  Mythic
//
//  Created by Doug Goldstein on 11/27/15.
//  Copyright © 2015 Doug Goldstein. All rights reserved.
//

import Foundation

class Show {

    var title: String!
    var posterPath: String!
    
    init(recording: Recording) {
        self.title = recording.title
        self.posterPath = recording.posterPath
    }
}

extension Array where Element : Show {
    // attempt to add the show if its not already in our array
    mutating func addShow(show: Element) {
        for item in self {
            // if this show is already in the list, don't add it
            if item.title == show.title {
                // if the show doesn't have a poster, we want to add one
                if item.posterPath == nil {
                    item.posterPath = show.posterPath
                }
                return
            }
        }
        append(show)
    }
}
