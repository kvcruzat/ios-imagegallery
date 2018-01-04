//
//  ImageView.swift
//  ImageGallery
//
//  Created by Khen Cruzat on 04/01/2018.
//  Copyright © 2018 Khen Cruzat. All rights reserved.
//

import UIKit

class ImageView: UIView {
    
    var image: UIImage? { didSet { setNeedsDisplay()} }

    override func draw(_ rect: CGRect ) {
         image?.draw(in: bounds)
    }

}
