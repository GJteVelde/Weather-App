//
//  NetworkService.swift
//  Weather App
//
//  Created by Gerjan te Velde on 03/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkServiceDelegate {
    func networkService(_ networkService: NetworkService, didFinishDownloading jsonString: String)
    func networkService(_ networkService: NetworkService, didFail error: Error)
    func networkService(_ networkService: NetworkService, didFinishDownloading icon: UIImage)
}

enum Location {
    case city(String)
    case geographicCoordinates(latitude: Double, longitude: Double)
}

/**
 Used to create the API-URL and to download the current weather data from [OpenWeatherMap](https://openweathermap.org).
 
 Start with createCurrentWeatherURL(for location: Location) to build a custom URL before downloading the data with getCurrentWeatherData().
*/
class NetworkService {
    var delegate: NetworkServiceDelegate?
    
    private var currentWeatherUrl: URL?
    
    private func createBaseUrlComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        return components
    }
    
    /**
     Creates an API-URL that can be used to get current weather data.
     - Parameter location: The the city name or geographic coordinates.
    */
    func createCurrentWeatherURL(for location: Location) {
        var components = createBaseUrlComponents()
        var queryItems = [URLQueryItem]()
        
        switch location {
        case let .city(name):
            queryItems.append(URLQueryItem(name: "q", value: name))
        case let .geographicCoordinates(latitude, longitude):
            queryItems.append(URLQueryItem(name: "lat", value: String(latitude)))
            queryItems.append(URLQueryItem(name: "lon", value: String(longitude)))
        }
        
        queryItems.append(URLQueryItem(name: "units", value: "metric"))
        queryItems.append(URLQueryItem(name: "APPID", value: MyOpenWeatherApiKey))
        components.queryItems = queryItems
        
        currentWeatherUrl = components.url
    }
    
    /**
     Can be called after an URL has been created to download current weather data.
     - Precondition: CreateCurrentWeatherURL(for location: Location) should have been called to create the URL used for downloading the current weather data.
    */
    func getCurrentWeatherData() {
        guard let url = currentWeatherUrl else {
            print("CurrentWeatherUrl has not yet been created or is invalid.")
            return
        }
        
        DispatchQueue.global().async {
            do {
                let jsonData = try String(contentsOf: url)
                
                DispatchQueue.main.async {
                    self.delegate?.networkService(self, didFinishDownloading: jsonData)
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.networkService(self, didFail: error)
                }
            }
        }
    }
    
    func getIcon(id: String) {
        DispatchQueue.global().async {
            var components = self.createBaseUrlComponents()
            components.path = "/img/w/\(id).png"
            
            let iconData = try! Data(contentsOf: components.url!)
            let iconImage = UIImage(data: iconData)
            
            DispatchQueue.main.async {
                self.delegate?.networkService(self, didFinishDownloading: iconImage!)
            }
        }
    }
}
