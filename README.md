# GPSProj
### Demo how to use coreLocation to locate user's location

It's easy to monitor user's location by using CoreLocation

Step1 : Set what region you want to monitor

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

Step2 : Start tracking user's path

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
      showAlert("Enter \(region.identifier)")
        
      monitoredRegions[region.identifier] = NSDate()
    }
    
    // 偵測離開區域範圍
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        showAlert("Exit \(region.identifier)")
        
        monitoredRegions.removeValue(forKey: region.identifier)
    }
