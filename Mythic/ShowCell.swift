//
//  TVCell.swift
//  Mythic
//
//  Created by Doug Goldstein on 11/15/15.
//  Copyright © 2015 Doug Goldstein. All rights reserved.
//

import UIKit

class ShowCell: UICollectionViewCell {
    @IBOutlet weak var tvImg: UIImageView!
    @IBOutlet weak var tvLbl: UILabel!
    
    func configureCell(show: Show) {
        if let title = show.title {
            tvLbl.text = title
        }
        
        if let path = show.posterPath {
            let urlEncodedPath = path.stringByAddingPercentEncodingWithAllowedCharacters(
                NSCharacterSet.URLQueryAllowedCharacterSet())
            if urlEncodedPath == nil {
                print("unable to URL encode path: \(path)")
                return
            }
            
            let url = NSURL(string: urlEncodedPath!)
            
            if url == nil {
                print("Invalid poster path: \(path)")
                return
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: url!)
                
                if data == nil {
                    print("Failed to get \(path)")
                    return
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    let img = UIImage(data: data!)
                    self.tvImg.image = img
                }
            }
        }
        
    }
    
}