//  MIT License

//  Copyright (c) 2019 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
  
  private lazy var manager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.delegate = self
    return manager
  }()
  private var hasSentLocation = false
  var completion: CompletionObject<Response>?
  
  func getLocation(_ closure: CompletionObject<Response>? ) {
    completion = closure
    hasSentLocation = false
    if CLLocationManager.authorizationStatus() == .notDetermined {
      manager.requestWhenInUseAuthorization()
    }
    manager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard !hasSentLocation else {
      manager.stopUpdatingLocation()
      return
    }
    if let location = locations.last?.coordinate {
      completion?(.location(location))
      hasSentLocation = true
      manager.stopUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .denied {
      completion?(.denied)
    }
  }
  
  deinit {
    manager.stopUpdatingLocation()
  }
}

extension LocationService {
  
  enum Response {
    case denied
    case location(CLLocationCoordinate2D)
  }
}
