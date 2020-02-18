//
//  APIHandler.swift
//  WeatherRxSwiftProject
//
//  Created by Philip Twal on 2/16/20.
//  Copyright © 2020 Philip Twal. All rights reserved.
//

import Foundation
import RxSwift

class APIHandler{
    
    class func callAPIFromApiHandler(withUrlString : String)
        -> Observable<Data?> {

            Observable<Data?>.create { observer  in
                
                URLSession.shared.dataTask(with: URL(string: withUrlString)!) { (data, response, error) in
                    
                    observer.onNext(data)
                    
                    if error != nil {
                        observer.onError(error!)
                    }
                    
                    observer.onCompleted()
                    
                }.resume()
                
                let disposable = Disposables.create()
                return disposable
                
        }
    }
}
