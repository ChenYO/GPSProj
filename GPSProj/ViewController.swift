//
//  ViewController.swift
//  GPSProj
//
//  Created by 陳仲堯 on 2018/10/25.
//  Copyright © 2018年 陳仲堯. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    //偵測用戶位置變化
    let locationManager = CLLocationManager()
    var monitoredRegions: Dictionary<String, NSDate> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //監控用戶並最佳化精準度
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //顯示用戶位置
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        setupData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 1. 用戶尚未同意
        if CLLocationManager.authorizationStatus() == .notDetermined {
            
            locationManager.requestAlwaysAuthorization()
        }
        // 2. 用戶不同意
        else if CLLocationManager.authorizationStatus() == .denied {
            showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
        }
        // 3. 用戶同意
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func setupData() {
        
        // 檢察系統是否能夠監控
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let title = "Location"
            let coordinate = CLLocationCoordinate2DMake(37.703026, -121.759735)
            let regionRadius = 300.0
            
            // 設定region相關屬性
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), radius: regionRadius, identifier: title)
            
            locationManager.startMonitoring(for: region)
            
            // 創建大頭釘
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(title)"
            mapView.addAnnotation(annotation)
            
            // 繪製region範圍
            let circle = MKCircle(center: coordinate, radius: regionRadius)
            mapView.add(circle)
        } else {
            print("System can't track regions")
        }
    }
    
    // 繪製圓圈
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
    
    // 偵測進入區域範圍
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        showAlert("Enter \(region.identifier)")
        
        monitoredRegions[region.identifier] = NSDate()
    }
    
    // 偵測離開區域範圍
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        showAlert("Exit \(region.identifier)")
        
        monitoredRegions.removeValue(forKey: region.identifier)
    }
    
    // 更新區域資訊
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateRegions()
    }
    
    // 偵測錯誤
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitor Fail: \(error.localizedDescription)")
    }
    
    // 在區域範圍內停留時間夠多，則顯示訊息
    func updateRegions() {
        let regionMaxVisiting = 10.0
        var regionsToDelete: [String] = []
        
        for regionIdentifier in monitoredRegions.keys {
            if NSDate().timeIntervalSince(monitoredRegions[regionIdentifier]! as Date) > regionMaxVisiting {
                showAlert("Thanks for visiting this place")
                
                regionsToDelete.append(regionIdentifier)
            }
        }
        
        for regionIdentifier in regionsToDelete {
            monitoredRegions.removeValue(forKey: regionIdentifier)
        }
    }
    
    func showAlert(_ message : String) {
        let alertMessage = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alertMessage.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alertMessage, animated: true, completion: nil)
    }
}

