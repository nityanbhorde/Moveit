//
//  SecondViewController.swift
//  MoveIt
//
//  Created by Lawrence Chen on 1/13/17.
//  Copyright © 2017 Lawrence Chen. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import FirebaseAuth
import FirebaseDatabase

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}



class SecondViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    let regionRadius: CLLocationDistance = 10000
    var json: [String:AnyObject] = ["":"" as AnyObject]
    var protestArray: [NSDictionary] = [["":""]]
    var badIDArray: [String]!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        refresh()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            if let location = self.mapView.userLocation.location{
                print (location)
                self.centerMapOnLocation(location: location)
            }else{
                print("No location yet")
            }
            
        })
        super.viewDidLoad()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapPin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func refresh() -> Void{
        let requestURL: NSURL = NSURL(string: "https://moveit-b6d5d.firebaseio.com/protests.json")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                do{
                    
                    self.json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
                    
                }catch {
                    print("Error with Json: \(error)")
                }
            }
            DispatchQueue.main.async() {
               
                print(self.json.count)
                
   
                for (id, protest) in self.json{
                    let protestobject = protest as! NSDictionary
                    let hostname = protestobject["hostname"]
                    let protestname = protestobject["protestname"]
                    let location = protestobject["location"]
                    let description = protestobject["description"]
                    let longitude = protestobject["longitude"]
                    let latitude = protestobject["latitude"]
                    let attending = protestobject["attending"]
                    let date = protestobject["date"]
                    
                    let point = MapPin(coordinate: CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees),
                                       title: protestname as! String,
                                       subtitle: location as! String)
                    
                    //Check date
                    /*
                    let currentDate = Date()
                    let calendar = NSCalendar.current
                    let hour = calendar.component(.hour, from: currentDate as Date)
                    let minutes = calendar.component(.minute, from: currentDate as Date)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    var s = dateFormatter.string(from: currentDate)
                    var s1 = String(format: "%02d", hour)
                    var s2 = String(format: "%02d", minutes)
                    var s3 = String(format: "%@:%@", s1, s2)
                    var currentDateAsString = s+" at "+s3
                    var dateAsString: String = String(describing: date)
                    */
                    // toInt returns optional that's why we used a:Int?
                    //var i = 0
                    /*while(i < dateAsString.characters.count) {
                        if Int(dateAsString.index(i, offsetBy: 1)) < Int(currentDateAsString.index(i, offsetBy: 1)) {
                            
                        }
                        i += 1
                    }
                    */
                    /*var currentDateAsArray : [Character]!
                    
                    for currentChar in currentDateAsString.characters {
                        currentDateAsArray.append(currentChar)
                    }
                    
                    for char in dateAsString.characters {
                        if Int(char) < Int(currentDateAsArray[i]) {
                            
                        }
                        i += 1
                    }*/
                    /*
                    print(dateAsString)
                    print(currentDateAsString)  // currently prints "Optional(2017-02-01 at 13:45)" Need to get rid of the "Optional" and parentheses
                    print("\n")
                    if currentDateAsString.substring(from: currentDateAsString.startIndex) > dateAsString {
                        self.badIDArray.append(id)
                        print("DEBUGGING CHECK DATE FUNCTIONALITY" + id)    // this id is bad
                    }
                    //print(currentDateAsString)
                    
                    */
                    self.mapView.addAnnotation(point)
                    

                }
                    
                
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    if let location = self.mapView.userLocation.location{
                        print (location)
                        self.centerMapOnLocation(location: location)
                    }else{
                        print("No location yet")
                    }
                    
                })

            }
            
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.json.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "protest", for: indexPath) as! ProtestViewCell
        
        let protestobject = Array(self.json.values)[indexPath.row]
        let hostname = protestobject["hostname"]
        let protestname = protestobject["protestname"]
        let location = protestobject["location"]
        let description = protestobject["description"]
        let longitude = protestobject["longitude"]
        let latitude = protestobject["latitude"]
        let attending = protestobject["attending"]
        let date = protestobject["date"]
        let idString = Array(self.json.keys)[indexPath.row]
    
        if(date != nil){
        
            cell.protestName.text = "\(protestname as! String): "
            cell.date.text = date as! String?
            cell.locationName.text = location as! String?
            print (idString)
            cell.idString = idString
            cell.button.addTarget(self, action: #selector(SecondViewController.makeSegue), for: UIControlEvents.touchUpInside)
        }

        return cell
    }

    override func viewDidAppear(_ animated: Bool) {
        refresh()
    }
    
    ///////////////////////////////////////////////////////////////////////
    // Austin added
    ///////////////////////////////////////////////////////////////////////
    /*
    func deleteBadIDs () {
        //var i = 0
        for i in badIDArray {
            ref.child(i).removeValue()
        }
    }
 */
    
    func makeSegue() {
        self.performSegue(withIdentifier: "moreInfo", sender: self)
    }
    func prepare(for segue: UIStoryboardSegue, sender: UIButton){
        
        if segue.identifier == "moreInfo"{
            let controller = segue.destination as! InfoViewController
            let button = sender as UIButton
            let cell = button.superview?.superview as! ProtestViewCell
            controller.idString = cell.idString
        }
    }

    
}

