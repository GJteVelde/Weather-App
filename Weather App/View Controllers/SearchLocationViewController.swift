//
//  SearchLocationViewController.swift
//  Weather App
//
//  Created by Gerjan te Velde on 06/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class SearchLocationViewController: UIViewController {

    //MARK: - Objects and Properties
    @IBOutlet weak var cityNameTextField: UITextField!
    var networkService: NetworkService?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkService = NetworkService()
    }
    
    //MARK: - Actions
    @IBAction func showWeatherButtonTouchUpInside(_ sender: UIButton) {
        guard let city = cityNameTextField.text else { return }
            
        networkService?.createCurrentWeatherURL(for: .city(city))
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "CurrentWeatherTableViewController") as! CurrentWeatherTableViewController
        destinationVC.networkService = networkService
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}
