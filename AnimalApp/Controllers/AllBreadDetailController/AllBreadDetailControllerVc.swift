//
//  AllBreadDetailControllerVc.swift
//  AnimalApp
//
//  Created by apple on 30/06/24.
//

import UIKit
import SDWebImage
import SVProgressHUD
import RealmSwift

class AllBreadDetailControllerVc: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource{
    
    @IBOutlet weak var collectionVw: UICollectionView!

        var breedName = ""
        var breedImages: Results<DogBreedImage>?
        let networkManager = NetworkManager()
        let realm = try! Realm()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            configureCollectionViewLayout()
            self.navigationController?.navigationBar.isHidden = false
            
            // Check if images exist in the local database
            breedImages = realm.objects(DogBreedImage.self).filter("breedName = %@", breedName)
            
            if breedImages?.isEmpty == false {
                // Images exist in local database
                DispatchQueue.main.async {
                    self.collectionVw.reloadData()
                }
            } else {
                // Fetch images from API
                SVProgressHUD.show()
                networkManager.fetchBreedImages(breed: breedName) { [weak self] images, error in
                    SVProgressHUD.dismiss()
                    
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.showAlert(message: error.localizedDescription)
                        }
                        return
                    }
                    
                    guard let images = images else { return }
                    
                    DispatchQueue.main.async {
                        try? self?.realm.write {
                            // Save all images to local database
                            images.forEach { imageUrl in
                                let dogBreedImage = DogBreedImage(url: imageUrl, breedName: self?.breedName ?? "")
                                self?.realm.add(dogBreedImage)
                            }
                            self?.breedImages = self?.realm.objects(DogBreedImage.self).filter("breedName = %@", self?.breedName ?? "")
                            self?.collectionVw.reloadData()
                        }
                    }
                }
            }
        }
        
        // Configure collection view layout
        func configureCollectionViewLayout() {
            let layout = UICollectionViewFlowLayout()
            let width = (view.frame.size.width - 30) / 3 // Adjust the 20 for padding between cells
            layout.itemSize = CGSize(width: width, height: width)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            collectionVw.collectionViewLayout = layout
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return breedImages?.count ?? 0
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionVw.dequeueReusableCell(withReuseIdentifier: "DetailCollectionCell", for: indexPath) as! DetailCollectionCell
            
            if let breedImage = breedImages?[indexPath.row],
               let imageUrl = URL(string: breedImage.imageUrl) {
                cell.imgVw.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "breed_PlaceholderImg"), completed: nil)
                
                let isLiked = breedImage.isLiked
                let likeImage = isLiked ? UIImage(named: "like_Img") : UIImage(named: "unlike_Img")
                cell.btnLikeOutlet.setImage(likeImage, for: .normal)
                cell.btnLikeOutlet.tag = indexPath.row
                cell.btnLikeOutlet.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
            }
            
            return cell
        }
        
        @objc func likeButtonTapped(_ sender: UIButton) {
            let index = sender.tag
            guard let breedImage = breedImages?[index] else { return }
            
            DispatchQueue.main.async {
                try? self.realm.write {
                    breedImage.isLiked.toggle()
                }
                self.collectionVw.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }

    extension UIViewController {
        func showAlert(title: String = "Error", message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    class DogBreedImage: Object {
        @Persisted(primaryKey: true) var id: String = UUID().uuidString
        @Persisted var imageUrl: String = ""
        @Persisted var breedName: String = ""
        @Persisted var isLiked: Bool = false
        
        convenience init(url: String, breedName: String) {
            self.init()
            self.imageUrl = url
            self.breedName = breedName
        }
    }

    extension DogBreedImage: Identifiable { }
