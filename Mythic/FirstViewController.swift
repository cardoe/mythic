//
//  FirstViewController.swift
//  Mythic
//
//  Created by Doug Goldstein on 11/11/15.
//  Copyright © 2015 Doug Goldstein. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout {

    let URL_BASE = "http://192.168.2.46:6544/Dvr/GetRecordedList"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var shows = [Show]()
    var recordings = [Recording]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
 
        collectionView.delegate = self
        collectionView.dataSource = self
        
        downloadData()
    }
    
    func downloadData() {
        let url = NSURL(string: URL_BASE)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) ->
            Void in
            
            if error != nil {
                print(error.debugDescription)
            } else {
                do {
                    let dict = try NSJSONSerialization.JSONObjectWithData(data!,
                        options: .AllowFragments) as? Dictionary<String, AnyObject>
                    
                    if let programlist = dict!["ProgramList"] as? Dictionary<String, AnyObject> {
                        if let programs = programlist["Programs"] as? Array<Dictionary<String, AnyObject>> {
                        
                            print(programs)
                            
                            for obj in programs {
                                let recording = Recording(recDict: obj)
                                self.recordings.append(recording)
                                self.shows.addShow(Show(recording: recording))
                            }
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.collectionView.reloadData()
                            }
                        } else {
                            print(programlist)
                            print("no programs")
                        }
                    } else {
                        print("no program list")
                    }
                } catch {
                    print("errors here")
                }
            }
        }
        
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ShowCell",
                forIndexPath: indexPath) as? ShowCell {
            
            let show = shows[indexPath.row]
            cell.configureCell(show)
            
            return cell
        }
        
        return ShowCell()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(320, 440)
    }
}

