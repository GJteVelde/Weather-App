//
//  CurrentWeatherTableViewController.swift
//  Weather App
//
//  Created by Gerjan te Velde on 06/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import MapKit

enum Section: Int {
    case map = 0
    case description = 1
    case temperature = 2
    case pressureHumidityCloudiness = 3
    case rainSnow = 4
    case sun = 5
}

class CurrentWeatherTableViewController: UITableViewController, NetworkServiceDelegate {

    //MARK: - Objects and Properties
    var networkService: NetworkService!
    var activityIndicator: UIActivityIndicatorView!
    var currentWeather: CurrentWeather!
    
    var lastUpdate: Date?
    var lastCity: String?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var parameterCell: UITableViewCell!
    @IBOutlet weak var descriptionCell: UITableViewCell!
    
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var averageTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cloudinessLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var rainLastHourCell: UITableViewCell!
    @IBOutlet weak var rainLast3HoursCell: UITableViewCell!
    @IBOutlet weak var snowLastHourCell: UITableViewCell!
    @IBOutlet weak var snowLast3HoursCell: UITableViewCell!
    
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    var hiddenCells = [UITableViewCell]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        tableView.separatorStyle = .none
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        networkService.delegate = self
        networkService.getCurrentWeatherData()
    }
    
    //MARK: - Methods
    func showCurrentWeather() {
        title = currentWeather.city
        presentMap()
        presentDescription()
        presentTemperature()
        
        pressureLabel.text = "\(currentWeather.main.pressure) hPa"
        humidityLabel.text = "\(currentWeather.main.humidity) %"
        cloudinessLabel.text = "\(currentWeather.clouds.coverage) %"
        windSpeedLabel.text = "\(currentWeather.wind.speed) meter/sec"
        
        presentRainAndSnow()
        presentSunriseAndSunset()
        
        tableView.reloadData()
    }
    
    @objc func willEnterForeground() {
        guard let lastUpdate = lastUpdate else { return }
        if Date().addingTimeInterval(-10*60) > lastUpdate {
            networkService.getCurrentWeatherData()
        } else {
        }
    }
    
    //MARK: - Delegate methods
    func networkService(_ networkService: NetworkService, didFinishDownloading jsonString: String) {
        activityIndicator.stopAnimating()
        
        print(jsonString)
        let decoder = JSONDecoder()
        let jsonData = jsonString.data(using: .utf8)!
        currentWeather = try! decoder.decode(CurrentWeather.self, from: jsonData)
        networkService.getIcon(id: self.currentWeather.weather.first!.icon)
        showCurrentWeather()
        
        lastUpdate = Date()
        lastCity = currentWeather.city
    }
    
    func networkService(_ networkService: NetworkService, didFail error: Error) {
        activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Error downloading data", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func networkService(_ networkService: NetworkService, didFinishDownloading icon: UIImage) {
        parameterCell.imageView?.image = icon
        super.tableView.reloadRows(at: [IndexPath(row: 0, section: Section.description.rawValue)], with: .none)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Section.map.rawValue {
            return 200
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if hiddenCells.contains(cell) {
            return 0
        }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == Section.map.rawValue {
            return 0
        }
        
        if section == Section.rainSnow.rawValue && amountOfRainSnowCellsVisible() == 0 {
            return 0
        }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == Section.rainSnow.rawValue && amountOfRainSnowCellsVisible() == 0 {
            return 0
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    //MARK: - Helper Methods
    func presentMap() {
        let coordinate = CLLocationCoordinate2D(latitude: currentWeather.coordinate.latitude, longitude: currentWeather.coordinate.longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
        mapView.setRegion(region, animated: true)
    }
    
    func presentDescription() {
        var parameter = [String]()
        var description = [String]()
        for weather in currentWeather.weather {
            parameter.append(weather.main)
            description.append(weather.description)
        }
        parameterCell.textLabel?.text = parameter.joined(separator: ", ")
        descriptionCell.textLabel?.text = description.joined(separator: ", ")
    }
    
    func presentTemperature() {
        if let minTemp = currentWeather.main.minTemperature {
            minTemperatureLabel.text = "\(minTemp) ºC"
        } else {
            minTemperatureLabel.text = "- ºC"
        }
        
        averageTemperatureLabel.text = "\(currentWeather.main.temperature) ºC"
        
        if let maxTemp = currentWeather.main.maxTemperature {
            maxTemperatureLabel.text = "\(maxTemp) ºC"
        } else {
            maxTemperatureLabel.text = "- ºC"
        }
    }
    
    func presentRainAndSnow() {
        if let rainLastHour = currentWeather.rain?.lastHour {
            rainLastHourCell.detailTextLabel?.text = "\(rainLastHour) mm"
        } else {
            rainLastHourCell.isHidden = true
            hiddenCells.append(rainLastHourCell)
        }
        
        if let rainLast3Hours = currentWeather.rain?.lastThreeHours {
            rainLastHourCell.detailTextLabel?.text = "\(rainLast3Hours) mm"
        } else {
            rainLast3HoursCell.isHidden = true
            hiddenCells.append(rainLast3HoursCell)
        }
        
        if let snowLastHour = currentWeather.snow?.lastHour {
            snowLastHourCell.detailTextLabel?.text = "\(snowLastHour) mm"
        } else {
            snowLastHourCell.isHidden = true
            hiddenCells.append(snowLastHourCell)
        }
        
        if let snowLast3Hours = currentWeather.snow?.lastThreeHours {
            snowLast3HoursCell.detailTextLabel?.text = "\(snowLast3Hours) mm"
        } else {
            snowLast3HoursCell.isHidden = true
            hiddenCells.append(snowLast3HoursCell)
        }
    }
    
    func presentSunriseAndSunset() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        sunriseLabel.text = dateFormatter.string(from: currentWeather.system.sunrise)
        sunsetLabel.text = dateFormatter.string(from: currentWeather.system.sunset)
    }
    
    func amountOfRainSnowCellsVisible() -> Int {
        var hidden = 0
        
        if hiddenCells.contains(rainLastHourCell) { hidden += 1 }
        if hiddenCells.contains(rainLast3HoursCell) { hidden += 1 }
        if hiddenCells.contains(snowLastHourCell) { hidden += 1 }
        if hiddenCells.contains(snowLast3HoursCell) { hidden += 1 }
        
        return 4 - hidden
    }
}
