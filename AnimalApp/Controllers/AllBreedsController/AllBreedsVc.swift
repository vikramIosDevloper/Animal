//
//  AllBreedsVc.swift
//  AnimalApp
//
//  Created by apple on 30/06/24.
//

import UIKit
import SDWebImage
import SVProgressHUD

class AllBreedsVc: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource{
    
    
    @IBOutlet weak var collectionVw: UICollectionView!
    
    var breeds: [String] = []
    let networkManager = NetworkManager()
        
    
    
    //calling api in view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewLayout()
        SVProgressHUD.show()
        networkManager.fetchBreeds { [weak self] breeds, error in
            SVProgressHUD.dismiss()
            
            if let error = error {
                            
                self?.showAlert(message: error.localizedDescription)
                            return
                        }
            
                    if let breeds = breeds {
                        self?.breeds = breeds
                        DispatchQueue.main.async {
                            self?.collectionVw.reloadData()
                        }
                    }
                }

          
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // configure collection view
    func configureCollectionViewLayout() {
            let layout = UICollectionViewFlowLayout()
            let width = (view.frame.size.width - 30) / 3 // Adjust the 20 for padding between cells
            layout.itemSize = CGSize(width: width, height: width)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            collectionVw.collectionViewLayout = layout
        }
        
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return breeds.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionVw.dequeueReusableCell(withReuseIdentifier: "AllBreadCollectionCell", for: indexPath) as! AllBreadCollectionCell
            
            let breed = breeds[indexPath.row]
            cell.lblTitle?.text = breed
            
            
            
            // Set up cell with image URL
            return cell
        }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let Sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = Sb.instantiateViewController(withIdentifier: "AllBreadDetailControllerVc") as! AllBreadDetailControllerVc
        vc.breedName = breeds[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func btnFavoritePicsAction(_ sender: Any) {
        let Sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = Sb.instantiateViewController(withIdentifier: "FavoriteBreedVc") as! FavoriteBreedVc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}
