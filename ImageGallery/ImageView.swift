//
//  ImageView.swift
//  ImageGallery
//
//  Created by Khen Cruzat on 04/01/2018.
//  Copyright © 2018 Khen Cruzat. All rights reserved.
//

import UIKit

class ImageView: UIView {
    
    var imageURL: URL? {
        didSet{
            fetchImage()
        }
    }
    
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
            if let loadingView = subviews.first as? UIActivityIndicatorView {
                loadingView.stopAnimating()
            }
        }
        
    }
    
    private func fetchImage() {
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async {
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents {
                        self.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }

    override func draw(_ rect: CGRect ) {
         image?.draw(in: bounds)
    }

}
