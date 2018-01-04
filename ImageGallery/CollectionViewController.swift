//
//  CollectionViewController.swift
//  ImageGallery
//
//  Created by Khen Cruzat on 04/01/2018.
//  Copyright © 2018 Khen Cruzat. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController, UIDropInteractionDelegate, UICollectionViewDelegateFlowLayout {
    
    var imageCollection = [(url: URL,ratio: Double)]()
    let width = 500.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes        
        self.collectionView!.addInteraction(UIDropInteraction(delegate: self))

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        var imageURL: URL?
        var aspectRatio: Double?
        
        session.loadObjects(ofClass: NSURL.self) { nsurls in
            if let url = nsurls.first as? URL {
                imageURL = url.imageURL
                print(imageURL!)
            }
        }
            
        session.loadObjects(ofClass: UIImage.self) { images in
            if let image = images.first as? UIImage {
                aspectRatio = Double(image.size.width / image.size.height)
                print(aspectRatio!)
                
                if imageURL != nil, aspectRatio != nil {
                    print("NOTNIL")
                    self.imageCollection.append((url: imageURL!, ratio: aspectRatio!))
                    self.collectionView!.reloadData()
                } else {
                    print("NIL")
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: width/imageCollection[indexPath.item].ratio);
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageCollection.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        print("DQ \(imageCollection.count)")
        
        if let imageCell = cell as? ImageCollectionViewCell {
            print(imageCollection.count, imageCollection[indexPath.item].url)
            imageCell.imageView.frame.size = CGSize(width: width, height: width/imageCollection[indexPath.item].ratio)
            imageCell.imageView.image = fetchImage(url: imageCollection[indexPath.item].url)
        }
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    private func fetchImage(url: URL) -> UIImage? {
        let urlContents = try? Data(contentsOf: url)
        if let imageData = urlContents {
            return UIImage(data: imageData)
        } else {
            return nil
        }
    }

}
