//
//  ViewController.swift
//  The Lists
//
//  Created by James Ngari on 2024-03-07.
//

import UIKit
import CoreData


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dataArray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! BookingViewCellTableViewCell
            let data = dataArray[indexPath.row]
            cell.heading.text = data.stationName
            return cell
        }
    
   
    @IBOutlet var tableView: UITableView!
    var dataArray: [StationModel] = []
    var bookingsData: [BookingsModel] = []
    var stationsData: [StationModel] = []
    
    
    var fetchedResultsController: NSFetchedResultsController<Station>?

    override func viewDidLoad() {
            super.viewDidLoad()
            tableView?.dataSource = self
        tableView?.delegate = self
            view.backgroundColor = .link
        fetchServerStationData()
            fetchFromLocal()
        fetchServerBookingsData()
        }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! BookingViewCellTableViewCell
//            let data = dataArray[indexPath.row]
//            // Configure the cell with data
//            cell.heading.text = data.stationName
//            // Add configuration for other UI elements if needed
//            return cell
//        }
    
    func fetchServerStationData() {
        guard let url = URL(string: "http://localhost:8088/api/v1/stations") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                print("Invalid response")
                return
            }
            
            // Parse JSON data
            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode([StationModel].self, from: data)
                
                DispatchQueue.main.async {
                    self.saveDataToCoreData(responseData)
                    self.tableView?.reloadData()
                    self.stationsData = responseData
                    print(responseData)
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    
    func fetchServerBookingsData() {
        guard let url = URL(string: "http://localhost:8088/api/v1/trains/bookings") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                print("Invalid response")
                return
            }
            
            // Parse JSON data
            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode([BookingsModel].self, from: data)
                
                DispatchQueue.main.async {
                    self.saveBookingsToCoreData(responseData)
                    self.tableView?.reloadData()
                    self.bookingsData = responseData
                    print(responseData)
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    
    func saveDataToCoreData(_ data: [StationModel]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Station")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting existing data: \(error)")
        }
        
        // Save new data
        for stationModel in data {
            let entity = NSEntityDescription.entity(forEntityName: "Station", in: context)!
            let station = NSManagedObject(entity: entity, insertInto: context)
            // Populate station with data from stationModel
            station.setValue(stationModel.stationName, forKeyPath: "stationName")
            station.setValue(stationModel.id, forKeyPath: "id")
            
            // Save the changes
            do {
                try context.save()
            } catch {
                print("Error saving data to Core Data: \(error)")
            }}
        }
    
    func saveBookingsToCoreData(_ data: [BookingsModel]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Booking")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting existing data: \(error)")
        }
        
        // Save new data
        for stationModel in data {
            let entity = NSEntityDescription.entity(forEntityName: "Booking", in: context)!
            let station = NSManagedObject(entity: entity, insertInto: context)
            // Populate station with data from stationModel
            station.setValue(stationModel.passengerName, forKeyPath: "passengerName")
            
            station.setValue(stationModel.startStation, forKeyPath: "startStation")
            
            station.setValue(stationModel.exitStation, forKeyPath: "exitStation")
            
            do {
                try context.save()
            } catch {
                print("Error saving data to Core Data: \(error)")
            }}
        }
    
    
//
    
    func fetchFromLocal() {
        // Get a reference to the AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error")
            return
        }

        // Access the persistentContainer from the AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        // Create fetch request
        let fetchRequest: NSFetchRequest<Station> = Station.fetchRequest()
        
        // Add sort descriptor(s) to the fetch request
        let sortDescriptor = NSSortDescriptor(key: "stationName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize fetched results controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        // Perform fetch
        do {
            try fetchedResultsController?.performFetch()
            if let fetchedObjects = fetchedResultsController?.fetchedObjects {
                
                
//                dataArray = fetchedObjects.map { StationModel(id: $0.id, stationName: $0.stationName ?? "") }
                
                let decoder = JSONDecoder()
//                let responseData = try decoder.decode([StationModel].self, from: data)
                
                print(fetchedObjects)

                // Reload table view on the main thread
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }

    
//    bookings per station
    
    func occurrencesPerStation(bookings: [[String: Any]], stations: [[String: Any]]) -> [Int] {
        
        var stationOccurrences: [Int: Int] = [:]
        
        
        for booking in bookings {
            if let startStation = booking["startStation"] as? Int {
                stationOccurrences[startStation, default: 0] += 1
            }
            if let exitStation = booking["exitStation"] as? Int {
                stationOccurrences[exitStation, default: 0] += 1
            }
        }
        
       
        var occurrencesArray: [Int] = []
        
        
        for station in stations {
            if let stationId = station["id"] as? Int {
                let count = stationOccurrences[stationId] ?? 0
                occurrencesArray.append(count)
            } else {
                // If station ID is missing, append 0
                occurrencesArray.append(0)
            }
        }
        
        return occurrencesArray
    }
    


    
  
    
    
    
//    let occurrences = occurrencesPerStation(bookings: bookingsData, stations: stationsData)
//    print(occurrences)
//
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataArray.count
//    }
    
    
}
