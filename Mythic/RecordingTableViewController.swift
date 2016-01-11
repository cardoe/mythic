//
//  RecordingTableViewController.swift
//  Mythic
//
//  Created by Doug Goldstein on 1/9/16.
//  Copyright © 2016 Doug Goldstein. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import UIKit
import AVKit
import AVFoundation

class RecordingTableViewController: UITableViewController {

    var show: Show!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = show.title

        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.show.recordings.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordedTableCell", forIndexPath: indexPath)
        // Configure the cell...
        let recording = self.show.recordings[indexPath.row]

        // If the show doesn't have a subtitle (episode title) use the show name
        if recording.subtitle.isEmpty {
            cell.textLabel?.text = recording.title
        } else {
            cell.textLabel?.text = recording.subtitle
        }

        if cell.gestureRecognizers?.count == nil {
            let tap = UITapGestureRecognizer(target: self, action: "tapped:")
            tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
            cell.addGestureRecognizer(tap)
        }

        return cell
    }

    func tapped(gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? UITableViewCell {
            print("Tapped: \(cell.textLabel?.text)")
            self.playVideo()
        }
    }

    func playVideo() {
        let videoURL = NSURL(string: "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/earth_night_rotate_1080.mov")
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
