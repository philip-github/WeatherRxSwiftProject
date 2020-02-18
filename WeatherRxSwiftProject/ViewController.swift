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
import ViewAnimator


class ViewController: UIViewController {
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    var currentlyDataSoruce : BehaviorRelay<[Currently]> = BehaviorRelay(value: [])
    
    
    let urlFormat = "https://api.darksky.net/forecast/02b2b82d0bcf56f5ea7db14618cdfa80/37.8267,-122.4233"
    
    var currentlyArr : BehaviorRelay<[Currently]> = BehaviorRelay(value: [])

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSubsciption()
        setUpDataSubscribtion()

        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let zoomAnimation = AnimationType.zoom(scale: 0.2)
        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)
        // no array brackets here.
        UIView.animate(views: view.subviews,
                       animations: [zoomAnimation, rotateAnimation],
                       duration: 1.0)
    }
    
}

extension ViewController{
    
//    func setUpTableViewBind(){
//
//        currentlyDataSoruce.bind(to: self.tblView.rx.items) { (tableView, row, element) in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
//
//            cell.textLabel?.text = "\(String(describing: element)) @row \(row)"
//            return cell
//        }.disposed(by: disposeBag)
//    }
    
    
    
    func setUpDataSubscribtion() {
        var temp: Double?
        var hum: Double?
        var windS : Double?
        var mySummary : String?
//        var weatherType : String?
        self.currentlyArr.subscribe(onNext: { (data) in
            print(data)
            for item in data{
                temp = item.temperature!
                hum = item.humidity!
                windS = item.windSpeed!
                mySummary = item.summary!
                DispatchQueue.main.async {
                    self.humidityLabel.text = "Humidity: \(String(describing: hum!))"
                    self.tempLabel.text = "\(String(describing: Int(temp!)))F"
                    self.windSpeedLabel.text = "Wind Speed: \(String(describing: Int(windS!)))"
                    self.summaryLabel.text = mySummary!
                }

//                weatherType = item.precipType
            }
        }, onError: { (error) in
            print(error.localizedDescription)
            
        }, onCompleted: {
                    }) {
            print("disposed")
        }.disposed(by: disposeBag)
    }
    
    func setUpSubsciption() {
       
        var currentlyDict : Currently!
        APIHandler.callAPIFromApiHandler(withUrlString: urlFormat).subscribe(onNext: { (data) in
            if let myData = data{
                do{
                    let welcome = try JSONSerialization.jsonObject(with: myData, options: []) as! [String:Any]
                  
                    for item in welcome{
                        if item.key == "currently" {
                            let myValue = item.value as! [String:Any]
                            currentlyDict = Currently(time: myValue["time"] as? Int,
                                                          summary: myValue["summary"]! as? String,
                                                          icon: myValue["icon"] as? String,
                                                          nearestStormDistsance: myValue["nearestStormDistance"] as? Int,
                                                          precipIntensity: myValue["precipIntensity"] as? Double,
                                                          precipIntensityError: myValue["precipIntensityError"] as? Int,
                                                          precipProbability: myValue["precipProbability"]! as? Double,
                                                          precipType: myValue["precipType"] as? String,
                                                          temperature: myValue["temperature"] as? Double,
                                                          apparentTemperature: myValue["apparentTemperature"]! as? Double,
                                                          dewPoint: myValue["dewPoint"] as? Double,
                                                          humidity: myValue["humidity"] as? Double,
                                                          pressure: myValue["pressure"] as? Double,
                                                          windSpeed: myValue["windSpeed"] as? Double,
                                                          windGust: myValue["windGust"] as? Double,
                                                          windBearing: myValue["windBearing"] as? Int,
                                                          cloudCover: myValue["cloudCover"] as? Double,
                                                          uvIndex: myValue["uvIndex"] as? Int,
                                                          visibility: myValue["visibility"] as? Double,
                                                          ozone: myValue["ozone"] as? Double)
                            
                            self.currentlyDataSoruce.accept([currentlyDict])

                        }
                    }
                }catch{
                    print(error.localizedDescription)
                }
            }
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
           self.currentlyArr.accept([currentlyDict])
        }) {
            print("Disposed")

        }.disposed(by: disposeBag)
    }
}
