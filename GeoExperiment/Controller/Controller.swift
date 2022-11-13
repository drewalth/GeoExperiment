//
//  Controller.swift
//  GeoExperiment
//
//  Created by Andrew Althage on 11/8/22.
//

import Foundation

extension MapView.ViewModel {
    final class Controller {
        func enter() {
            var request = URLRequest(url: URL(string: "http://localhost:3000/enter")!)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { data, response, error in
                print(response)
                print(data)
                print(error)
            }.resume()
        }

        func exit() {
            var request = URLRequest(url: URL(string: "http://localhost:3000/exit")!)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { data, response, error in
                print(response)
                print(data)
                print(error)
            }.resume()
        }
    }
}
