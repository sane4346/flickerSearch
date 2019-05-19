//
//  FlickerCollectionViewCell.swift
//  FlickerSearchApp
//
//  Created by santosh chaurasia on 17/05/19.
//  Copyright © 2019 santosh104. All rights reserved.
//

import UIKit

class FlickerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var flickerCellImage: customeUIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(photoData : PhotoData) {
            self.flickerCellImage.downloadImageFromUrl(for: photoData)
    }
    
}


let imageCache = NSCache<AnyObject, UIImage>()

class customeUIImageView: UIImageView {
    
    var imageUrlString : String?
    
    func downloadImageFromUrl( for photoData : PhotoData) {
        let id = photoData.id
        let farm = String(photoData.farm)
        let secret = photoData.secret
        let server = photoData.server
        let urlString = flickerApi.getFLickerImagePathFor(farm: farm, server: server, id: id, secret: secret).path
        
        self.imageUrlString = urlString
        //image chache check before hitting server
        DispatchQueue.main.async {
            self.image = UIImage(named: "thumb")
        }
        
        
        if let imageFromChache = imageCache.object(forKey: urlString as AnyObject) {
            self.image = imageFromChache
            return
        }
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url, completionHandler :{ [weak self ] (data , response ,error) in
            guard let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let data = data else { return }
            
            DispatchQueue.main.async {
                if let imageToChache = UIImage(data: data) {
                    if self?.imageUrlString == urlString {
                        self?.image = imageToChache
                    }
                    imageCache.setObject(imageToChache, forKey: urlString as AnyObject)
                }
            }
            
        }).resume()
    }
}

