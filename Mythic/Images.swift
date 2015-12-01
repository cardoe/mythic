// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

extension UIImage {
  enum Asset : String {
    case Content = "Content"
    case Top_Shelf_Image = "Top Shelf Image"
    case First = "first"
    case ImageUnavailable = "ImageUnavailable"
    case Second = "second"

    var image: UIImage {
      return UIImage(asset: self)
    }
  }

  convenience init!(asset: Asset) {
    self.init(named: asset.rawValue)
  }
}
