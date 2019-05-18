//
//  FlickerSearchViewModel.swift
//  FlickerSearchApp
//
//  Created by santosh chaurasia on 17/05/19.
//  Copyright © 2019 santosh104. All rights reserved.
//

import Foundation

class FlickerSearchViewModel {
    
    var photosCount : Int = 0
    var photosData = [PhotoData]()
    var totalPages = 1
    init() {
        //self.photosCount = 0
    }
    func setItemCount (items:Int)
    {
        self.photosCount = items
    }
    func getJSONForImagesData(searchtext:String, pageNo:Int,complete:@escaping (Bool)->Void)
    {
        FlickerClient.shared.sendRequestForImagesData(searchText: searchtext,pageNo:pageNo , complete: { [weak self] rootPhotosResponse in
           
            guard let photoResponse = rootPhotosResponse else {
                complete(false)
                return
            }
                self?.photosData.append(contentsOf: photoResponse.photos.photo) 
                self?.totalPages = photoResponse.photos.pages
//            guard let photoData = photo as? [[String:Any]] else {
//                complete(false)
//                return
//            }
//            for imageData in photoData  {
//                let id = imageData["id"] as? String
//                let secret = imageData["secret"] as? String
//                let farm = imageData["farm"] as! Int
//                let server = imageData["server"] as? String
//                let photomodel = FlickerPhotoData(id:id,secret:secret,farm:farm,server:server)
            
            //}
            self?.setItemCount(items: self?.photosData.count ?? 0)
            complete(true)
        })
    }
    
    func photoDataAt(indexPath:IndexPath) -> PhotoData?
    {
        if indexPath.row >= 0 && indexPath.row < photosCount {
            return photosData[indexPath.row]
        }
        return nil
        
    }
}

