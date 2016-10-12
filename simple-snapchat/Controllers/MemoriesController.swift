//
//  MemoriesController.swift
//  simple-snapchat
//
//  Created by Jeffrey on 5/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Photos
import Firebase

private let cameraRollCellId = "cameraRollCellId"
private let snapsCellId = "snapsCellId"


class MemoriesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var cameraRollView: UICollectionView?
    var snapsView: UICollectionView?
    var snapsCell: SnapsCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleLable = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 40, height: view.frame.height))
        titleLable.text = "Memories"
        titleLable.font = UIFont.systemFont(ofSize: 20)
        titleLable.textColor = UIColor(r: 255, g: 20, b: 147)
        navigationItem.titleView = titleLable
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        // get rid of the black bar underneath the navbar
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        let checkIcon = UIImage(named: "check-icon")
        // set icon size
        UIGraphicsBeginImageContext(CGSize(width: 25, height: 25))
        checkIcon?.draw(in: CGRect(x: 0, y: 3, width: 20, height: 20))
        let newCheckIcon = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysTemplate)
        UIGraphicsEndImageContext()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newCheckIcon, style: .plain, target: self, action: #selector(handleSelectImage))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(colorLiteralRed: 255/255, green: 20/255, blue: 147/255, alpha: 1)
        
        setupMemoriesView()
        setupMenuBar()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        snapsCell?.grabSnaps()
        snapsCell?.collectionView.reloadData()
    }
    
    func setupMemoriesView() {
        collectionView?.contentInset = UIEdgeInsetsMake(40, 0, 0, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(40, 0, 0, 0)
        
        
        collectionView?.register(SnapsCell.self, forCellWithReuseIdentifier: snapsCellId)
        collectionView?.register(CamerollRollCell.self, forCellWithReuseIdentifier: cameraRollCellId)
        collectionView?.isPagingEnabled = true
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        
    }
    
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.memoriesViewController = self
        return mb
    }()
    
    fileprivate func setupMenuBar() {
        view.addSubview(menuBar)
        menuBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        menuBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        menuBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        menuBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    var didClickSelectButton: Bool = false
    
    let bottomSelectView: UIView = {
        let bs = UIView()
        bs.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 20/255, blue: 147/255, alpha: 1)
        return bs
    }()
    
    lazy var sendButtonView: UIImageView = {
        let sb = UIImageView()
        sb.image = UIImage(named: "send-button")?.withRenderingMode(.alwaysTemplate)
        sb.tintColor = UIColor.white
        sb.isUserInteractionEnabled = true
        sb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSend)))
        return sb
    }()
    
    func handleSend() {
        if let selectedPhotos = cameraRollView?.indexPathsForSelectedItems{
            let sendToController = SendToController()
            
            for i in 0..<selectedPhotos.count {
                let cell = cameraRollView?.cellForItem(at: selectedPhotos[i]) as! PhotoCell
                let photo = SendingPhoto()
                photo.image = cell.imageView.image!
                photo.timer = 3
                sendToController.photos.append(photo)
            }
            self.handleSelectImage()
            self.didClickSelectButton = true
            let navController = UINavigationController(rootViewController: sendToController)
            present(navController, animated: true, completion: nil)
            
            
//            var username = String()
//            
//            // Create story reference
//            let storiesRef = FIRDatabase.database().reference().child("stories")
//            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//                if let dictionary = snapshot.value as? [String: AnyObject] {
//                    
//                    username = dictionary["name"] as! String
//                }
//            })
//            
//            for i in 0..<selectedPhotos.count {
//                let imageName = NSUUID().uuidString
//                let storageRef = FIRStorage.storage().reference().child("stories").child(imageName)
//                let cell = cameraRollView?.cellForItem(at: selectedPhotos[i]) as! PhotoCell
//                let image = cell.imageView.image
//                let uploadData = UIImagePNGRepresentation(image!)
//                
//                storageRef.put(uploadData!, metadata: nil, completion: { (metaData, error) in
//                    
//                    if error != nil {
//                        print(error)
//                        return
//                    } else {
//                        
//                        // update database after successfully uploaded
//                        let storyRef = storiesRef.childByAutoId()
//                        if let imageURL = metaData?.downloadURL()?.absoluteString {
//                            storyRef.updateChildValues(["userID": uid, "username": username, "imageURL": imageURL, "timer": 3], withCompletionBlock: { (error, ref) in
//                                if error != nil {
//                                    print(error)
//                                    return
//                                }
//                                
//                                self.handleSelectImage()
//                                self.didClickSelectButton = true
//                            })
//                        }
//                        
//                    }
//                    
//                })
//            }
        }
        
    }
    
    func handleSelectImage() {
        
        if didClickSelectButton == false {
            
            didClickSelectButton = true
            
            navigationItem.rightBarButtonItem?.tintColor = UIColor(colorLiteralRed: 174/255, green: 2/255, blue: 2/255, alpha: 1)
            
            cameraRollView?.allowsSelection = true
            cameraRollView?.allowsMultipleSelection = true
            if let cells = cameraRollView?.visibleCells {
                for i in 0..<cells.count {
                    let photoCell = cells[i] as? PhotoCell
                    photoCell?.imageView.isUserInteractionEnabled = false
                }
            }
            // Set bottom select view
            view.addSubview(bottomSelectView)
            bottomSelectView.translatesAutoresizingMaskIntoConstraints = false
            bottomSelectView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            bottomSelectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            bottomSelectView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            bottomSelectView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            // Set send button
            bottomSelectView.addSubview(sendButtonView)
            sendButtonView.translatesAutoresizingMaskIntoConstraints = false
            sendButtonView.centerYAnchor.constraint(equalTo: bottomSelectView.centerYAnchor).isActive = true
            sendButtonView.centerXAnchor.constraint(equalTo: bottomSelectView.rightAnchor, constant: -30).isActive = true
            sendButtonView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            sendButtonView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        } else {
            
            didClickSelectButton = false
            
            navigationItem.rightBarButtonItem?.tintColor = UIColor(colorLiteralRed: 255/255, green: 20/255, blue: 147/255, alpha: 1)
            
            if let cells = cameraRollView?.visibleCells {
                for i in 0..<cells.count {
                    let photoCell = cells[i] as? PhotoCell
                    cameraRollView?.deselectItem(at: IndexPath(row: i, section: 0), animated: true)
                    photoCell?.imageView.isUserInteractionEnabled = true
                    photoCell?.imageView.alpha = 1
                }
            }
            cameraRollView?.allowsSelection = false
            cameraRollView?.allowsMultipleSelection = false
            sendButtonView.removeFromSuperview()
            bottomSelectView.removeFromSuperview()
        }
    }
    
    
    
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: snapsCellId, for: indexPath) as! SnapsCell
            snapsView = cell.collectionView
            snapsCell = cell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cameraRollCellId, for: indexPath) as! CamerollRollCell
            cameraRollView = cell.collectionView
            return cell
        }     
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 40)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
    }

    
}
