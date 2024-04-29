//
//  ViewController.swift
//  411weatherapp
//
//  Created by csuftitan on 4/26/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var LocationInput: UITextField!
    @IBOutlet weak var tempTextC: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var locationText: UILabel!
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var feelsText: UILabel!
    @IBOutlet weak var humidText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        backgroundImg.image = UIImage(named: "weather_background")
        backgroundImg.layer.zPosition = -5
    }
    
    @IBAction func getWeatherClicked(_ sender: Any) {
        let apiKey = "ecc9cb7f382b933014783b687f0b90a0"
        guard let location = LocationInput.text, !location.isEmpty else {
            print("Location is empty")
            return
        }
        
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&q=\(location)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                print(jsonResponse)
                
                DispatchQueue.main.async {
                    if let main = jsonResponse["main"] as? [String: Any] {
                        if let temperature = main["temp"] as? Double {
                            let temperatureC = round(temperature - 273.15)
                            let temperatureF = round((9/5) * (temperature - 273.15) + 32)
                            self.tempTextC.text = "\(temperatureC)°C | \(temperatureF)°F"
                        }
                        
                        if let feels = main["feels_like"] as? Double {
                            let feelsTC = round(feels - 273.15)
                            let feelsTF = round((9/5) * (feels - 273.15) + 32)
                            self.feelsText.text = "Feels like: \(feelsTC)°C | \(feelsTF)°F"
                        }
                        
                        if let humidity = main["humidity"] as? Double {
                            self.humidText.text = "Humidity: \(humidity)"
                        }
                    }
                    
                    
                    if let locationName = jsonResponse["name"] as? String {
                        self.locationText.text = "\(locationName)"
                    }
                    
                    if let weather = jsonResponse["weather"] as? [[String: Any]], let weatherDict = weather.first {
                        if let weatherDescription = weatherDict["description"] as? String {
                            self.descriptionText.text = "\(weatherDescription)"
                        }
                        if let icon = weatherDict["icon"] as? String {
                            let iconUrlString = "https://openweathermap.org/img/wn/\(icon)@2x.png"
                            print(iconUrlString)
                            if let iconUrl = URL(string: iconUrlString) {
                                let session = URLSession.shared
                                let task = session.dataTask(with: iconUrl) { (data, response, error) in
                                    if let error = error {
                                        print("Error downloading image: \(error)")
                                        return
                                    }
                                    guard let data = data else {
                                        print("No image data received")
                                        return
                                    }
                                    if let image = UIImage(data: data) {
                                        DispatchQueue.main.async {
                                            self.weatherImg.image = image
                                        }
                                    } else {
                                        print("Unable to create image from data")
                                    }
                                }
                                task.resume()
                            } else {
                                print("Invalid icon URL")
                            }
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        task.resume()
    }
}
