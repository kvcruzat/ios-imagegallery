//
//  CollectionViewController.swift
//  ImageGallery
//
//  Created by Khen Cruzat on 04/01/2018.
//  Copyright © 2018 Khen Cruzat. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate,  UICollectionViewDelegateFlowLayout {
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    @IBOutlet weak var navGalleryItem: UIBarButtonItem!
    
    var imageCollection = [Image]()
    var width = 300.0

    @IBAction func zoomGallery(_ sender: UIPinchGestureRecognizer) {
        let maxWidth = Double(collectionView!.frame.width) * 0.45
        let minWidth = Double(collectionView!.frame.width) * 0.1
        
        if sender.state == .began || sender.state == .changed {
            let newWidth = width * Double(sender.scale)
            if newWidth < minWidth {
                width = minWidth
            }  else if newWidth > maxWidth  {
                width = maxWidth
            } else {
                width = newWidth
                flowLayout?.invalidateLayout()
            }
        
            sender.scale = 1.0
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes        
//        self.collectionView!.addInteraction(UIDropInteraction(delegate: self))
        self.collectionView!.dataSource = self
        self.collectionView!.delegate = self
        self.collectionView!.dragDelegate = self
        self.collectionView!.dropDelegate = self
        // Do any additional setup after loading the view.
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
//            imageCell.loadingView.startAnimating()
            flowLayout?.invalidateLayout()
            imageCell.imageView.imageURL = imageCollection[indexPath.item].url
        }
    
        // Configure the cell
    
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }

    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let image = (collectionView?.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.imageView.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = image
            return [dragItem]
        } else {
            return []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        print("number of Items: \(coordinator.items.count)")
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates({
                    let imageInfo = imageCollection[sourceIndexPath.item]
                    imageCollection.remove(at: sourceIndexPath.item)
                    imageCollection.insert(imageInfo, at: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else {
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "ImageCell"))
                
                let cell = placeholderContext as? ImageCollectionViewCell
                
                var imageURL: URL?
                var aspectRatio: Double?
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? URL {
                            imageURL = url.imageURL
                        }
                    }
                }
                
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            aspectRatio = Double(image.size.width / image.size.height)
                            cell?.frame.size = CGSize(width: self.width, height: self.width/aspectRatio!)
                            print(aspectRatio!)
                            
                            if imageURL != nil, aspectRatio != nil {
                                print("NOTNIL")
                                placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                    self.imageCollection.insert(Image(imageUrl: imageURL!, aspectRatio: aspectRatio!), at: insertionIndexPath.item)
                                })
                            } else {
                                print("NIL")
                                placeholderContext.deletePlaceholder()
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Image" {
            print("SEegue")
            if let imageCell = sender as? UICollectionViewCell {
                print("1")
                if let indexPath = collectionView?.indexPath(for: imageCell) {
                    print("2")
                    if let vc = segue.destination as? ImageViewController {
                        print("3")
                        vc.imageView.imageURL = imageCollection[indexPath.item].url
                    }
                }
            }
        }
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

}
