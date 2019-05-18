//
//  FlickerPhotoData.swift
//  FlickerSearchApp
//
//  Created by santosh chaurasia on 17/05/19.
//  Copyright © 2019 santosh104. All rights reserved.
//

import Foundation


struct PhotoSearchRootResponse: Codable {
    let photos : PhotoSearchPageResponse
    let stat: String
}

struct PhotoSearchPageResponse: Codable{
    let page : Int
    let pages : Int
    let perpage : Int
    let total : String
    let photo : [PhotoData]
}

struct PhotoData : Codable {
    
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm : Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    
    
//    init(id:String? , owner:String = "", secret:String?,farm:Int, server: String? , title: String = "", ispublic:String = "",isfriend:String = "",isfamily: String = ""){
//        self.id = id
//        self.owner = owner
//        self.secret = secret
//        self.server = server
//        self.farm = farm
//        self.title = title
//        self.ispublic = ispublic
//        self.isfriend = isfriend
//        self.isfamily = isfamily
//
//    }
}

