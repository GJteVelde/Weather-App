//
//  CurrentWeather.swift
//  Weather App
//
//  Created by Gerjan te Velde on 03/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import CoreLocation

struct CurrentWeather: Decodable {
    let coordinate: Coordinate
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let clouds: Clouds
    let rain: Rain?
    let snow: Snow?
    let system: System
    let city: String
}

extension CurrentWeather {
    enum CodingKeys: String, CodingKey {
        case coordinate = "coord"
        case weather
        case main
        case wind
        case clouds
        case rain
        case snow
        case system = "sys"
        case city = "name"
    }
}

extension CurrentWeather {
    struct Coordinate: Decodable {
        let longitude: Double
        let latitude: Double
        
        enum CodingKeys: String, CodingKey {
            case longitude = "lon"
            case latitude = "lat"
        }
    }
    
    struct Weather: Decodable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Main: Decodable {
        let temperature: Double
        let pressure: Int
        let humidity: Int
        let minTemperature: Double?
        let maxTemperature: Double?
        
        enum CodingKeys: String, CodingKey {
            case temperature = "temp"
            case pressure
            case humidity
            case minTemperature = "temp_min"
            case maxTemperature = "temp_max"
        }
    }
    
    struct Wind: Decodable {
        let speed: Double
        let degrees: Int
        
        enum CodingKeys: String, CodingKey {
            case speed
            case degrees = "deg"
        }
    }
    
    struct Clouds: Decodable {
        let coverage: Int
        
        enum CodingKeys: String, CodingKey {
            case coverage = "all"
        }
    }
    
    struct Rain: Decodable {
        let lastHour: Double?
        let lastThreeHours: Double?
        
        enum CodingKeys: String, CodingKey {
            case lastHour = "1h"
            case lastThreeHours = "3h"
        }
    }
    
    struct Snow: Decodable {
        let lastHour: Int?
        let lastThreeHours: Int?
        
        enum CodingKeys: String, CodingKey {
            case lastHour = "1h"
            case lastThreeHours = "3h"
        }
    }
    
    struct System: Decodable {
        let countryCode: String
        let sunriseInt: Int
        let sunsetInt: Int
        
        var sunrise: Date {
            let timeInterval = TimeInterval(exactly: Double(sunriseInt))
            return Date(timeIntervalSince1970: timeInterval!)
        }
        
        var sunset: Date {
            let timeInterval = TimeInterval(exactly: Double(sunsetInt))
            return Date(timeIntervalSince1970: timeInterval!)
        }
        
        enum CodingKeys: String, CodingKey {
            case countryCode = "country"
            case sunriseInt = "sunrise"
            case sunsetInt = "sunset"
        }
    }
}
