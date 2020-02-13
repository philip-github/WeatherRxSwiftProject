//
//  ViewController.swift
//  WeatherRxSwiftProject
//
//  Created by Philip Twal on 2/12/20.
//  Copyright © 2020 Philip Twal. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class ViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    let urlFormat = "https://api.darksky.net/forecast/02b2b82d0bcf56f5ea7db14618cdfa80/37.8267,-122.4233"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubsciption()
        setUpTableViewBind()
    }
    
    let disposeBag = DisposeBag()
    
    var dataSource : BehaviorRelay<[Welcome]> = BehaviorRelay(value: [])
    
    
    func setUpTableViewBind(){
        
        dataSource.bind(to: self.tblView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            let currentTime = element.minutely.data
            cell.textLabel?.text = "\(String(describing: currentTime)) @row \(row)"
            
            return cell
        }.disposed(by: disposeBag)
    }
    
    
    func setUpSubsciption(){
        
        callAPIFromApiHandler(withUrlString: urlFormat).subscribe(onNext: { (data) in
            
            if let myData = data{
                
                do{
                    let welcome = try JSONDecoder().decode(Welcome.self, from: myData)
                    self.dataSource.accept([welcome])
                }catch{
                    print(error.localizedDescription)
                }
            }
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        }) {
            print("Disposed")
        }.disposed(by: disposeBag)
    
    }
    
    
     func callAPIFromApiHandler(withUrlString : String)
        -> Observable<Data?> {
            //2
            // observable's create method returns the observer
            // observer.oncompleted calls when the data is done receiving
            Observable<Data?>.create { observer  in
                
                //3
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

