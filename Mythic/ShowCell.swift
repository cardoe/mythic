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
    var show: Show!
    
    func configureCell(show: Show) {
        // save a reference to the show for later transisions
        self.show = show
        
        if let title = show.title {
            tvLbl.text = title
        }
        
        if let path = show.posterPath {
            let url = NSURL(string: path)
            
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
        } else {
            self.tvImg.image = UIImage(asset: .PofC)
        }
        
    }
    
}
