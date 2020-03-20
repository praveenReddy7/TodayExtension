//
//  TodayViewController.swift
//  Activity Tracker
//
//  Created by praveen on 3/18/20.
//  Copyright © 2020 focussoftnet. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate {
    let WIDGET_HEIGHT: CGFloat = 150.0
    let label = UILabel()
    let timeLabel = UILabel()
    let actionButton = UIButton()
    let timerLabel = UILabel()
    let addressLabel = UILabel()
    var trackerState: ETrackerState = .checkIn
    var seconds = 0
    var timer: Timer?
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
        
    enum ETrackerState {
        case checkIn
        case checkOut
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.preferredContentSize = CGSize(width: self.view.frame.width, height: 110)
        
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            var currentSize: CGSize = self.preferredContentSize
            currentSize.height = WIDGET_HEIGHT
            self.preferredContentSize = currentSize
        }

        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
        
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
          
        timeLabel.textColor = .white
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)
        timeLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
        actionButton.layer.cornerRadius = 4
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(actionButton)
        
        actionButton.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
        actionButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        actionButton.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.textAlignment = .center
        timerLabel.textColor = .white
        timerLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        timerLabel.layer.borderWidth = 1.0
        timerLabel.layer.borderColor = UIColor.lightGray.cgColor
        timerLabel.layer.cornerRadius = 40
        timerLabel.numberOfLines = 2
        view.addSubview(timerLabel)
        
        timerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        timerLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        timerLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.textColor = .white
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.numberOfLines = 0
        view.addSubview(addressLabel)
        
        addressLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 4).isActive = true
        addressLabel.leadingAnchor.constraint(equalTo: actionButton.leadingAnchor).isActive = true
        addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        addressLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.checkInState(showTime: false)
    }
    
    private func checkInState(showTime: Bool) {
        actionButton.setTitle("Check In", for: .normal)
        actionButton.backgroundColor = .white
        actionButton.setTitleColor(.orange, for: .normal)
        self.timerLabel.isHidden = true
        self.trackerState = .checkIn
        self.addressLabel.text = nil

        if showTime {
            label.text = "Last check-out: "
            timeLabel.text = getCurrentTime()
        }
    }
    
    private func checkoutState() {
        actionButton.setTitle("Check out", for: .normal)
        actionButton.backgroundColor = .orange
        actionButton.setTitleColor(.white, for: .normal)
        label.text = "Check-In: "
        timeLabel.text = getCurrentTime()
        self.timerLabel.text = "0 \n Min"
        self.timerLabel.isHidden = false
        self.trackerState = .checkOut
        self.setLocationAddress()
       
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
    }
    
    private func updateTimerText(_ seconds: Int) {
        if seconds > 3600 {
            let hr = String(format: "%02d", seconds / 3600)
            let min = String(format: "%02d", seconds / 60 % 60)
            self.timerLabel.text = "\(hr) Hr \n \(min) Min"
        } else {
            let minutes = seconds / 60
            self.timerLabel.text = "\(minutes) \n Min"
        }
    }
    
    @objc func startTimer() {
        self.seconds += 1
        self.updateTimerText(self.seconds)
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"

        return formatter.string(from: Date())
    }
    
    @objc func actionButtonTapped(_ sender: UIButton) {
        
        if self.trackerState == .checkIn {
            self.checkoutState()

        } else {
            self.timer?.invalidate()
            self.seconds = 0
            self.checkInState(showTime: true)
        }
        
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
      let expanded = activeDisplayMode == .expanded
      preferredContentSize = expanded ? CGSize(width: maxSize.width, height: WIDGET_HEIGHT) : maxSize
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0]
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    private func setLocationAddress() {
        if self.currentLocation == nil {
            self.currentLocation = self.locationManager.location
        }
        guard CLLocationManager.locationServicesEnabled() else {
            self.addressLabel.text = "Enable Location"
            return
        }
        guard let location = self.currentLocation else {
            self.addressLabel.text = "Location not found."
            return
        }
        let geocoder = CLGeocoder()
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(location,
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                let firstLocation = placemarks?[0]
                                                self.addressLabel.text = firstLocation?.name
                                            }
                                            else {
                                                // An error occurred during geocoding.
                                                self.addressLabel.text = "Enable Location"
                                            }
        })
    }
    
}
