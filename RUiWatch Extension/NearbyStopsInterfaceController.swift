//
//  NearbyStopsInterfaceController.swift
//  RutgersBusApp
//
//  Created by Kalu on 1/11/16.
//  Copyright © 2016 Niral. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

var dataResults = [[String: AnyObject]]();
var timeResults = [[String: AnyObject]]();
var nearbyResults = NSDictionary ();

class NearbyStopsInterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    //busStopRoutes is simply a list of Active Bus Stops
    var busStopRoutes = [String] ()
    
    // nearbyBusStops is simply a list of Nearby Bus Stops (to a certain accuracy)
    var nearbyBusStops = [String] ()
    //busStopInfo simply contains all relevant info (predictions, routes) corresponding to the busStop
    var busStopInfo = [BusStopInformation]()
    
    //used to check if there is no available data
    var noData = false;
    var noNearbyStops = false;
    // used to check current location:
    let locationManager = CLLocationManager();
    var lat = Double();
    var long = Double();
    var loaded = false;
    @IBOutlet var tableView: WKInterfaceTable!
  
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print("Did Awake With Context Nearby Bus Stops")
        //call to retrieve data:
        print("Welcome to Nearby Screen")
       //jsonBusRoutes()
        //Location Services:
        //init location manager
        loaded = true;
        }
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    
    
    func setupTable(let dataRetrive:Bool) {
    
             print("SETTING UP TABLE:\(nearbyBusStops.count)")
        if (nearbyBusStops.count == 0){
            tableView.setNumberOfRows(1, withRowType: "busStopRow")
            
            if let row = tableView.rowControllerAtIndex(0) as? NearbyBusStopRow {
                print("Setting text")
                row.busStopName.setText("Loading...")
            }
        }
        else{
            if (!dataRetrive && nearbyBusStops.count == 0){
                print("Here: No Row")
                tableView.setNumberOfRows(1, withRowType: "busStopRow")
                if let row = tableView.rowControllerAtIndex(0) as? NearbyBusStopRow {
                    print("Setting text")
                    row.busStopName.setText("Loading...")
                }
            }
            else{
            tableView.setNumberOfRows(nearbyBusStops.count, withRowType: "busStopRow")
            for var i = 0; i < nearbyBusStops.count; ++i {
                if let row = tableView.rowControllerAtIndex(i) as? NearbyBusStopRow {
                    //print(busStopInfo[i].busStop)
                    print("Bus Stop Name:\(nearbyBusStops[i])")
                    row.busStopName.setText(nearbyBusStops[i])
                    //let busStop = nearbyBusStops[i]
                }
            }
         print("finished")
        } // else
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        // method to get current location if available
        print("IN UPDATE Locations");
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = Lat:\(locValue.latitude) Long:\(locValue.longitude)")
        self.lat = locValue.latitude
        self.long = locValue.longitude
        //once current lat and long are available, find nearest available bus stops
        nearbyBusStops.removeAll()
        print(("Start Nearest Stop:"))
        jsonNearestStop()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("FAILED");
        print("error:\(error.localizedDescription)")
        //jsonNearestStop()
        print("error:\(error.localizedFailureReason)")
    }
    
    func jsonStopPredictions(let stopTag:String) {
      print("jsonStopPredictions")
        let stopTagNoSpaces = stopTag.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let urlPath = "http://runextbus.heroku.com/stop/\(stopTagNoSpaces)"
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint"); return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSArray else { throw JSONError.ConversionFailed }
                dispatch_async(dispatch_get_main_queue()) {
                    timeResults=json as! [[String : AnyObject]]
                    //  print(json);
                    self.parseBusPredictions(timeResults,stopTag: stopTag);
                   // self.tableView.reloadData();
                }
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            }.resume()
        
    }
    
    
    /*func jsonBusRoutes() {
        print("entered jsonBusRoutes");
        let urlPath = "http://runextbus.heroku.com/active"
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint"); return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData; self.noData = true;}
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                // print(json)
                if let stops = json["stops"] as? [[String: AnyObject]] {
                    dispatch_async(dispatch_get_main_queue()) {
                        //print("entered main thread")
                        dataResults=stops
                        //  print(stops);
                        self.parseBusRoutes(dataResults);
                        //    self.tableView.reloadData();
                      //  self.setupTable(false)
                    }
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            }.resume()
        
    }
    */
    func jsonNearestStop() {
        //let stopTagNoSpaces = stopTag.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: //nil)
        //let urlPath = "http://runextbus.heroku.com/nearby/\(self.lat)/\(self.long)"
        print("In JSON Nearest Path")
        let urlPath = "http://runextbus.heroku.com/nearby/\(self.lat)/\(self.long)"
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint"); return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            //print("Inside")
            do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                dispatch_async(dispatch_get_main_queue()) {
                    nearbyResults = json
                    print(json);
                    self.parseNearbyStops()
                    //self.tableView.reloadData();
                    self.setupTable(false)
                }
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            }.resume()
        
    }
    
    func parseNearbyStops(){
        //stop.value is the accuracy measurement (based upon number of geocache characters that match)
        //stop.key is the corresponding bus stop
        
        for stop in nearbyResults {
            let accuracy = stop.value as? Int
            
            //based on some experiementation, it seems accuracy when >5 provides best results
            if (accuracy! > 4) {
                print(stop.key)
                print("Going into jsonStopPredictions")
                jsonStopPredictions(stop.key as! String)
                nearbyBusStops.append(stop.key as! String);
            }
            
        }
    }

    
    
    /*func parseBusRoutes(let stops: [[String: AnyObject]]){
        print("entered parseBusRoutes")
        for stop in stops{
            if let name = stop["title"] as? String {
                print(name);
                self.busStopRoutes.append(name);
                jsonStopPredictions(name);
            }
        }
        //print(busStopRoutes.count);
    }*/
    
    func parseBusPredictions(let infos: [[String: AnyObject]], let stopTag:String) {
        var routeInfo = [BusInfo]()
       // print("starting to add to array predictions");
        //print(infos)
        // print("Bus Stop Info: \(stopTag)")
        //print("***************");
        
        for data in infos{
            
            // print("Info Data:")
            // print(data)
            //print("")
            if var name = data["title"] as? String where !name.isEmpty {
                //print("title:\(name)");
                //  print("")
                var predictionTimes = [String] ()
                
                if let dir = data["direction"] as? String where !dir.isEmpty {
                    name += " " + "(" + dir + ")";
                    // print("new name \(name)");
                }
                
                if  !(data["predictions"] is NSNull) {
                    //print("predictions not null")
                    let preds = data["predictions"];
                    do {
                        let predictions = try preds as? [[String:AnyObject]]
                        //print(predictions)
                        for time in predictions! {
                            var mins = time["minutes"] as! String
                            if mins.isEqual("0"){
                                mins="<1";
                            }
                            //      print("mins:\(mins)")
                            let secs = time["seconds"] as! String
                            //   print("seconds:\(secs)")
                            predictionTimes.append("\(mins)")
                        }
                        
                        //print("")
                        // print(bPredictions!.count);
                        /*var aObject:AnyObject = preds
                        let anyMirror = Mirror(reflecting: aObject)
                        print(anyMirror.subjectType) */
                    }
                        
                    catch let error as JSONError {
                        print(error.rawValue)
                    } catch {
                        print(error)
                    }
                }
                else {
                    // "No Predictions Available"
                    // print("No Predictions Available");
                    //print("")
                    predictionTimes.append("No Predictions Available")
                }
                var newBusInfo = BusInfo(busRoute:name, prediction: predictionTimes)
                routeInfo.append(newBusInfo);
            }
        } // outer for loop
        var newBusStopInfo = BusStopInformation(busStop: stopTag, busStopInfo: routeInfo)
        self.busStopInfo.append(newBusStopInfo);
    }// method
    



    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("Will activated Nearby Stops")
        if (loaded == true){
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            dispatch_async(dispatch_get_main_queue()) {
                self.locationManager.requestLocation()
                self.setupTable(true)
            }
            
        } else{
            print("Location Services Not Enabled");
        }
        }
        // Configure interface objects here.
        

    }
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        print("Selection:\(rowIndex)")
        
        let selectedStop = nearbyBusStops[rowIndex]
       dispatch_async(dispatch_get_main_queue()) {
       // self.jsonBusRoutes()
       // print("finished jsonBusRoutes")
        //pass on BusStopInformation to the next scene
        
        for stop in self.busStopInfo{
           print("started searching")
            print("So far:\(stop.busStop)")
            if selectedStop.isEqual(stop.busStop){
                let stopInfo = stop
                print("found")
                //cannot pass stopInfo because its not anyobject
                 self.presentControllerWithName("nearbyDetails", context: encode(stopInfo))
               // break;
            }
        }
        }
        
       
    }

    override func didDeactivate() {
        print("Did Deactivate Nearby Stops")
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        loaded = false;
    }

}
