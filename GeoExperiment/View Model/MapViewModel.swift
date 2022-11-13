//
//  MapViewModel.swift
//  GeoExperiment
//
//  Created by Andrew Althage on 11/8/22.
//

import Foundation

import CoreLocation
import MapKit
import SwiftUI

extension MapView {
    // map defaults
    enum mapDefaults {
        static let initialLocation = CLLocationCoordinate2D(latitude: 39.716516, longitude: -104.948321)
        static let initialSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        static let zone02 = CLLocationCoordinate2D(latitude: 39.717839, longitude: -104.946320)
    }

    @MainActor final class ViewModel: NSObject, ObservableObject, CLLocationManagerDelegate, MKMapViewDelegate {
        @Published private(set) var authorizationStatus: UNAuthorizationStatus?
        @Published var distanceInMeter: Double = 0.0
        @Published var region: MKCoordinateRegion = .init(
            center: mapDefaults.initialLocation,
            span: mapDefaults.initialSpan)

        var apiController = Controller()
        var userLatitude = CLLocationCoordinate2D().latitude
        var userLongitude = CLLocationCoordinate2D().longitude

        var initialCoordinate: CLLocationCoordinate2D?
        var movedCoordinate: CLLocationCoordinate2D?

        // draw circle on map
        let locations: [Location] = [
            Location(name: "zone-01", coordinate: mapDefaults.initialLocation),
            Location(name: "zone-02", coordinate: mapDefaults.zone02),
        ]

        // Create Geofence Region with 10 meter radius
        let geofenceRegion = CLCircularRegion(center: mapDefaults.initialLocation,
                                              radius: 10,
                                              identifier: "SafeArea")

        var circle = MKCircle(center: mapDefaults.initialLocation, radius: 10)
        var circle02 = MKCircle(center: mapDefaults.zone02, radius: 10)

        var locationMangager: CLLocationManager?

        // check if location permission is enabled or not
        func checkLocationEnabled() {
            if CLLocationManager.locationServicesEnabled() {
                locationMangager = CLLocationManager()
                locationMangager!.delegate = self
                locationMangager?.startUpdatingLocation()
                locationMangager?.startMonitoring(for: geofenceRegion)
                print("Location permission enabled")
            }
            else {
                print("Location permission not enabled")
            }
        }

        // Check if user authorized location
        private func checkLocationAuth() {
            guard let locationMangager = locationMangager else {
                return
            }

            switch locationMangager.authorizationStatus {
            case .notDetermined:
                locationMangager.requestWhenInUseAuthorization()
            case .restricted:
                print("User location access is restricted")
            case .denied:
                print("User denied location access")
            case .authorizedAlways, .authorizedWhenInUse:
                region = MKCoordinateRegion(center: locationMangager.location!.coordinate, span: mapDefaults.initialSpan)
            @unknown default:
                break
            }
        }

        // Check if user changed location after first time
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            // check for location authorization
            checkLocationAuth()

            // request for notification access
            requestAuthorization()
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location = locations.last

            userLatitude = location!.coordinate.latitude
            userLongitude = location!.coordinate.longitude

            // Starting position
            initialCoordinate = CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)
            // Updated position
            movedCoordinate = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
            distanceInMeter = Double(movedCoordinate!.distance(to: initialCoordinate!))
            print(distanceInMeter)
        }

        // enter safe area (region)
        func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            apiController.enter()
            triggerLocalNotification(subTitle: "User Entered", body: "You have moved inside safe area")
        }

        // exiting safe area (region)
        func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            apiController.exit()
            triggerLocalNotification(subTitle: "User Exited", body: "You have moved from safe area")
        }

        // request for notification
        func requestAuthorization() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, _ in
                DispatchQueue.main.async {
                    self.authorizationStatus = isGranted ? .authorized : .denied
                }
            }
        }

        // create user notification
        func triggerLocalNotification(subTitle: String, body: String) {
            // configure notification content
            let content = UNMutableNotificationContent()
            content.title = "Alert!"
            content.subtitle = subTitle
            content.body = body
            content.sound = UNNotificationSound.default

            // setup trigger
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            // create request
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            // add notification request
            UNUserNotificationCenter.current().add(request)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tileOverlay = overlay as? MKTileOverlay {
                let renderer = MKTileOverlayRenderer(overlay: tileOverlay)
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

// return distance in meters
extension CLLocationCoordinate2D {
    /// Returns the distance between two coordinates in meters.
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        MKMapPoint(self).distance(to: MKMapPoint(to))
    }
}
