//
//  Location.swift
//  GeoExperiment
//
//  Created by Andrew Althage on 11/8/22.
//

import CoreLocation
import Foundation

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
