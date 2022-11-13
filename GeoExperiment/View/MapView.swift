//
//  MapView.swift
//  GeoExperiment
//
//  Created by Andrew Althage on 11/8/22.
//

import CoreLocationUI
import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var mapViewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $mapViewModel.region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: mapViewModel.locations) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        Circle()
                            .stroke(.red.opacity(0.4), lineWidth: 4)
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                        // 44 is Apple's minimum size for any screen (Magic number)
                    }
                }
                .ignoresSafeArea()
                .accentColor(.accentColor)
                .onAppear {
                    mapViewModel.checkLocationEnabled()
                }

            LocationButton(.currentLocation) {
                print("Current location...")
            }
            .foregroundColor(.white)
            .cornerRadius(10)
            .labelStyle(.iconOnly)
            .padding(.bottom, 10)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
