//
//  FlickerClient.swift
//  FlickerSearchApp
//
//  Created by santosh chaurasia on 17/05/19.
//  Copyright © 2019 santosh104. All rights reserved.
//

//API key created by me for flicker
//dbbabda39d25fd6b983013f06cc3088c     and secret = 3806eca1bad3d80f

import Foundation

class FlickerClient: NSObject {
    
    static let shared = FlickerClient()
    typealias JsonDictionary = [String : Any]
    
    override init()
    {
        
    }
    
    func sendRequestForImagesData(searchText:String,pageNo:Int, complete: @escaping (PhotoSearchRootResponse?)->(Void)){
        
        let urlString = flickerApi.getPhotosPathFor(searchString: searchText, pageNo: String(pageNo)).path
        
        guard let url = URL(string: urlString) else {
            complete(nil)
            return
        }
        let dataTask = URLSession.shared.dataTask(with: url){ (data , response ,error) in
            
            guard error == nil,
                let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options:[]),
                let json = jsonData as? JsonDictionary,
                let status = json["stat"] as? String else {
                    complete(nil)
                    return
            }
            if( status == "ok") {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let rootResponse = try jsonDecoder.decode(PhotoSearchRootResponse.self, from: data)
                        complete(rootResponse)
                    } catch {
                        complete(nil)
                    }
            } else {
                complete(nil)
            }
        }
        dataTask.resume()
        //return dataTask
    }
}

enum flickerApi  {
    //   "http://farm{farm}.static.flickr.com/{server}/{id}_{secret}.jpg"
    static let imagePath = "http://farm%@.static.flickr.com/%@/%@_%@.jpg"
    //https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(AppCredentials.API_KEY)&format=json&nojsoncallback=1&safe_search=1&text=\(searchfield)&page=\(pageNo)"
    static let photosPath = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=28fec7cfe2bc3ceea532200f43540aa2&format=json&nojsoncallback=1&safe_search=1&text=%@&page=%@"
    
    case getPhotosPathFor(searchString:String, pageNo:String)
    case getFLickerImagePathFor(farm:String,server:String,id:String,secret:String)
   
    var path : String {
        switch self {
        case let .getPhotosPathFor(searchString,pageNo):
            return String(format: flickerApi.photosPath, searchString,pageNo)
        case let .getFLickerImagePathFor(farm,server,id,secret):
            return String(format: flickerApi.imagePath, farm,server,id,secret)
        }
    }
}

