//
//  Show.swift
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

class Show {

    var title: String!
    var posterPath: String!
    var recordings = [Recording]()
    
    init(recording: Recording) {
        self.title = recording.title
        self.posterPath = recording.posterPath
        self.recordings.append(recording)
    }
}

extension Array where Element : Show {
    // attempt to add the show if its not already in our array
    mutating func addShow(show: Element) {
        for item in self {
            // if this show is already in the list, don't add it
            if item.title == show.title {
                // add the recording to the show's recording list
                item.recordings.appendContentsOf(show.recordings)
                
                // if the show doesn't have a poster, we want to add one
                if item.posterPath == nil {
                    item.posterPath = show.posterPath
                }
                return
            }
        }
        append(show)
        sortInPlace { $0.title < $1.title }
    }
}
