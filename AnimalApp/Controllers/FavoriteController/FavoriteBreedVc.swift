//
//  FavoriteBreedVc.swift
//  AnimalApp
//
//  Created by apple on 30/06/24.
//

import UIKit
import SDWebImage
import SVProgressHUD
import RealmSwift

class FavoriteBreedVc: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource{
    
    @IBOutlet weak var collectionVw: UICollectionView!
    var likedImages: Results<DogBreedImage>?
        var breeds: [String] = []
        let realm = try! Realm()
        let networkManager = NetworkManager()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            configureCollectionViewLayout()
            self.navigationController?.navigationBar.isHidden = true
            fetchLikedImages()
            fetchBreeds()
        }
        
        func fetchLikedImages() {
            likedImages = realm.objects(DogBreedImage.self).filter("isLiked == true")
            collectionVw.reloadData()
        }
        
        func fetchBreeds() {
            SVProgressHUD.show()
            networkManager.fetchBreeds { [weak self] breeds, error in
                SVProgressHUD.dismiss()
                
                if let error = error {
                    self?.showAlert(message: error.localizedDescription)
                    return
                }
                
                if let breeds = breeds {
                    self?.breeds = breeds
                }
            }
        }
        
        func configureCollectionViewLayout() {
            let layout = UICollectionViewFlowLayout()
            let width = (view.frame.size.width - 30) / 3
            layout.itemSize = CGSize(width: width, height: width)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            collectionVw.collectionViewLayout = layout
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return likedImages?.count ?? 0
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionVw.dequeueReusableCell(withReuseIdentifier: "FavoriteCollectionCell", for: indexPath) as! FavoriteCollectionCell
            
            guard let likedImages = likedImages else { return cell }
            
            let breedImage = likedImages[indexPath.row]
            if let imageUrl = URL(string: breedImage.imageUrl) {
                cell.imgVw.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "breed_PlaceholderImg"), completed: nil)
            }
            let isLiked = breedImage.isLiked
            let likeImage = isLiked ? UIImage(named: "like_Img") : UIImage(named: "unlike_Img")
            cell.btnFavoriteOutlet.setImage(likeImage, for: .normal)
            
            cell.btnFavoriteOutlet.tag = indexPath.row
            cell.btnFavoriteOutlet.addTarget(self, action: #selector(unlikeButtonTapped(_:)), for: .touchUpInside)
            
            return cell
        }
        
        @objc func unlikeButtonTapped(_ sender: UIButton) {
            let index = sender.tag
            guard let likedImages = likedImages, index < likedImages.count else { return }
            
            let breedImage = likedImages[index]
            
            try? realm.write {
                realm.delete(breedImage)
            }
            
            fetchLikedImages()
        }
    
        
        @IBAction func btnFilterAction(_ sender: Any) {
            // Show filter options based on fetched breeds
            let alertController = UIAlertController(title: "Filter by Breed", message: nil, preferredStyle: .actionSheet)
            
            for breed in breeds {
                let action = UIAlertAction(title: breed, style: .default) { _ in
                    self.filterLikedImages(by: breed)
                }
                alertController.addAction(action)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = sender as? UIView
                popoverController.sourceRect = (sender as AnyObject).bounds
            }
            
            present(alertController, animated: true, completion: nil)
        }
        
        func filterLikedImages(by breed: String) {
            likedImages = realm.objects(DogBreedImage.self).filter("isLiked == true AND breedName == %@", breed)
            collectionVw.reloadData()
        }
    
        
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    }
