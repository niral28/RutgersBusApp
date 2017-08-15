//
//  TableTableViewController.swift
//  RutgersBusApp
//
//  Created by Kalu on 1/1/16.
//  Copyright © 2016 Niral. All rights reserved.
//

import UIKit
import CoreLocation

//[{ var direction: "To Busch Student Center", var title: "A",var predictions: [ '7', '20', '31', '43', '55' ] }]


var dataResults = [[String: AnyObject]]();
var timeResults = [[String: AnyObject]]();
var nearbyResults = NSDictionary ();
//var stopSearchResults:Array<BusStopInformation>?




class TableTableViewController: UITableViewController,CLLocationManagerDelegate, UISearchResultsUpdating  {
        // main data structures
    
        //busStopRoutes is simply a list of Active Bus Stops
            var busStopRoutes = [String] ()

        // nearbyBusStops is simply a list of Nearby Bus Stops (to a certain accuracy)
            var nearbyBusStops = [String] ()
        //busStopInfo simply contains all relevant info (predictions, routes) corresponding to the busStop
            var busStopInfo = [BusStopInformation]()
        
        //data structures required for search bar (which will filter the tableview)
            var filteredBusStopInfo = [String] ()
            var resultSearchController = UISearchController! ()
    
        //used to check if there is no available data
            var noData = false;
            var noNearbyStops = false;
        // used to check current location:
            let locationManager = CLLocationManager();
            var lat = Double();
            var long = Double();
        
    
    override func viewDidLoad(){
        super.viewDidLoad()
    
        //navigationController!.navigationBar.barTintColor = UIColor(red: 206/255, green: 17/255, blue: 38/255, alpha: 1)
        //init pull to refresh controller
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        //call to retrieve data:
        jsonBusRoutes()
        
        //Location Services:
            //init location manager
            self.locationManager.requestAlwaysAuthorization()
            
            // For use in foreground
            self.locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                
            } else{
                print("Location Services Not Enabled");
            }
     
        
        // Stuff for Search Bar:
            self.resultSearchController = UISearchController(searchResultsController: nil)
            self.resultSearchController.searchResultsUpdater = self
            self.resultSearchController.dimsBackgroundDuringPresentation = false
            self.resultSearchController.searchBar.sizeToFit()
            self.resultSearchController.searchBar.placeholder = "Search Stops"
            self.tableView.tableHeaderView = self.resultSearchController.searchBar
            self.resultSearchController.searchBar.tintColor = UIColor(red: 206/255, green: 17/255, blue: 38/255, alpha: 1)
            self.tableView.reloadData()

    }



    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
      // method to get current location if available
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = Lat:\(locValue.latitude) Long:\(locValue.longitude)")
        self.lat = locValue.latitude
        self.long = locValue.longitude
        //once current lat and long are available, find nearest available bus stops
        nearbyBusStops.removeAll()
        jsonNearestStop()
    }
    
    
    func parseBusRoutes(let stops: [[String: AnyObject]]){
        print("entered parseBusRoutes")
            for stop in stops{
                if let name = stop["title"] as? String {
                    //print(name);
                    self.busStopRoutes.append(name);
                    jsonStopPredictions(name);
                }
            }
        //print(busStopRoutes.count);
    }
    
    func parseBusPredictions(let infos: [[String: AnyObject]], let stopTag:String) {
     var routeInfo = [BusInfo]()
       print("starting to add to array predictions");
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
                            predictionTimes.append("\(mins) (mins)")
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
        var newBusStopInfo = BusStopInformation(busStop:stopTag, busStopInfo:routeInfo)
        self.busStopInfo.append(newBusStopInfo);
    }// method
            
    

    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    
   
    func jsonBusRoutes() {
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
                    self.tableView.reloadData();
                    }
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
        }.resume()

    }
    func jsonBusRoutesRefresh() {
        print("entered jsonBusRoutesRefresh");
        let urlPath = "http://runextbus.heroku.com/active"
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint"); return }
        let request = NSMutableURLRequest(URL:endpoint)
       print(request)
        dispatch_async(dispatch_get_main_queue()) {
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData; self.noData = true;}
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                print(json)
                if let stops = json["stops"] as? [[String: AnyObject]] {
                    dispatch_async(dispatch_get_main_queue()) {
                        print("entered main thread")
                        dataResults=stops
                        //  print(stops);
                        self.parseBusRoutes(dataResults);
                        self.tableView.reloadData();
                    }
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            }.resume()
        }
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
                        self.tableView.reloadData();
                    }
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            }.resume()
        
    }
    
    func jsonNearestStop() {
        //let stopTagNoSpaces = stopTag.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: //nil)
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
                    // print(json);
                   self.parseNearbyStops()
                    self.tableView.reloadData();
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
                nearbyBusStops.append(stop.key as! String);
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      // print(busStopRoutes.count);
        
        if section == 0 {
            if nearbyBusStops.count > 0 {
                return nearbyBusStops.count;
            }
            else {
                self.noNearbyStops = true;
                return 1;
            }
        }
        else {
            if self.resultSearchController.active {
                return self.filteredBusStopInfo.count
            }
            else{
                self.title = "Stops"
                if(dataResults.count == 0){
                 //   print("here");
                    return 1;
                }
               // print("\(dataResults.count)")
            return dataResults.count
            }
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stopCell", forIndexPath: indexPath)
       // print("called")
        if (dataResults.count == 0){
        //      print("reached in no active routes");
        cell.textLabel?.text = "No Active Stops";
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel?.textColor = UIColor.grayColor();
        cell.userInteractionEnabled = false;
        cell.detailTextLabel?.text=""
        return cell;
        
         } else{
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            cell.textLabel?.textColor = UIColor.blackColor();
            cell.userInteractionEnabled = true;
        }
        
        if indexPath.section == 1 {
            if self.resultSearchController.active {
                let busStop = filteredBusStopInfo[indexPath.row]
                cell.textLabel?.text = busStop
                
                var prediction = ""
                // search for data associated with corresponding bus stop
                for stop in self.busStopInfo {
                    
                    //execute logic once bus stop is found: (break out of loop once found)
                    if stop.busStop.isEqual(busStop) {
                        
                        // initialize prediction
                        prediction = stop.busStopInfo[0].prediction[0];
                     
                        //if first prediction is "No Predictions Available" then check:
                        if prediction.isEqual("No Predictions Available"){
                            //print("here for \(busStop)");
                            for routes in stop.busStopInfo{
                                for pred in routes.prediction{
                                    if !(pred.isEqual("No Predictions Available")) {
                                        prediction = pred;
                                        break;
                                    }
                                }
                                if !(prediction.isEqual("No Predictions Available")){
                                    break;
                                }
                            }
                        }
                        print("Prediction=\(prediction)")
                        cell.detailTextLabel?.text = prediction;
                        break;
                    }
                    
                }
                
                //prevents selection on cells for which there are no bus time predictions
                //(put into an if else structure due to refreshing, as the prediction data could change
                if prediction.isEqual("No Predictions Available"){
                    // print("here for \(busStop)");
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    cell.textLabel?.textColor = UIColor.grayColor();
                    cell.userInteractionEnabled = false;
                    return cell;
                } else{
                    //   print("here for \(busStop)");
                    cell.selectionStyle = UITableViewCellSelectionStyle.Default
                    cell.textLabel?.textColor = UIColor.blackColor();
                    cell.userInteractionEnabled = true;
                }

            }
                
                
         
        //    print("reached in active routes");
            // Configure the cell...
            else{
                //print("Index:\(indexPath.row)")
            if busStopRoutes.count != 0 {
                let busStop = busStopRoutes[indexPath.row]
                print("Bus Stop: \(busStop)")
               // print("Index:\(indexPath.row)")
                cell.textLabel?.text = busStop
                var prediction = ""
                // search for data associated with corresponding bus stop
                for stop in self.busStopInfo {
                    
                    //execute logic once bus stop is found: (break out of loop once found)
                    if stop.busStop.isEqual(busStop) {
                        
                        // initialize prediction
                         prediction = stop.busStopInfo[0].prediction[0];
                        
                        //if first prediction is "No Predictions Available" then check:
                        if prediction.isEqual("No Predictions Available"){
                            //print("here for \(busStop)");
                            for routes in stop.busStopInfo{
                                    for pred in routes.prediction{
                                        if !(pred.isEqual("No Predictions Available")) {
                                        prediction = pred;
                                         break;
                                        }
                                    }
                                if !(prediction.isEqual("No Predictions Available")){
                                    break;
                                }
                            }
                        }
                        
                        cell.detailTextLabel?.text = prediction;
                        break;
                    }
                    
                }
                
                //prevents selection on cells for which there are no bus time predictions
                //(put into an if else structure due to refreshing, as the prediction data could change
                if prediction.isEqual("No Predictions Available"){
                   // print("here for \(busStop)");
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    cell.textLabel?.textColor = UIColor.grayColor();
                    cell.userInteractionEnabled = false;
                    return cell;
                } else{
                //   print("here for \(busStop)");
                    cell.selectionStyle = UITableViewCellSelectionStyle.Default
                    cell.textLabel?.textColor = UIColor.blackColor();
                    cell.userInteractionEnabled = true;
                }

            
            }
        } // end section 1
        }
        else { // section 0
            if (nearbyBusStops.count == 0 ){
                cell.textLabel!.text = "No Nearby Stops"
                cell.detailTextLabel!.text = "No Available Predictions"
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.textLabel?.textColor = UIColor.grayColor();
                cell.userInteractionEnabled = false;
                return cell;
            }
            else{
            let busStop = nearbyBusStops[indexPath.row];
            cell.textLabel!.text = busStop;
            var prediction = ""
            // search for data associated with corresponding bus stop
            for stop in self.busStopInfo {
                print("cell detail label")
                //execute logic once bus stop is found: (break out of loop once found)
                if stop.busStop.isEqual(busStop) {
                    
                    // initialize prediction
                    prediction = stop.busStopInfo[0].prediction[0];
                    
                    //if first prediction is "No Predictions Available" then check:
                    if prediction.isEqual("No Predictions Available"){
                        //print("here for \(busStop)");
                        for routes in stop.busStopInfo{
                            for pred in routes.prediction{
                                if !(pred.isEqual("No Predictions Available")) {
                                    prediction = pred;
                                    break;
                                }
                            }
                            if !(prediction.isEqual("No Predictions Available")){
                                break;
                            }
                        }
                    }
                    
                    cell.detailTextLabel?.text = prediction;
                    break;
                }
                
            }
            
            //prevents selection on cells for which there are no bus time predictions
            //(put into an if else structure due to refreshing, as the prediction data could change
            if prediction.isEqual("No Predictions Available"){
                // print("here for \(busStop)");
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.textLabel?.textColor = UIColor.grayColor();
                cell.userInteractionEnabled = false;
                return cell;
            } else{
                //   print("here for \(busStop)");
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
                cell.textLabel?.textColor = UIColor.blackColor();
                cell.userInteractionEnabled = true;
            }

        }
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            cell.textLabel?.textColor = UIColor.blackColor();
            cell.userInteractionEnabled = true;
        }
        //cell.detailTextLabel?.text="Arriving in \(busStopRoutesTimes[indexPath.row][0])"
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Nearby Bus Stops:"
        } else {
            return "Active Bus Stops:"
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
         var secondScene = segue.destinationViewController as! BusRoutesTableViewController
       // print("here prepare4Segue!");
    if self.tableView.indexPathForSelectedRow!.section == 1 {
        if self.resultSearchController.active{
         //   print("Search Controller Active")
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let selectedStop = filteredBusStopInfo[indexPath.row]
           //     print("Selected Stop:\(selectedStop)");
                secondScene.currentStop = selectedStop
                
                //pass on BusStopInformation to the next scene
                for stop in busStopInfo{
                    if selectedStop.isEqual(stop.busStop){
                        secondScene.currentInfo = stop
                        self.resultSearchController.active = false;
                    }
                }
            }
        
        }
        else {
           // print("Search Controller Inactive")

            // Pass the selected object to the new view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let selectedStop = busStopRoutes[indexPath.row]
                secondScene.currentStop = selectedStop
               
                //pass on BusStopInformation to the next scene
                for stop in busStopInfo{
                    if selectedStop.isEqual(stop.busStop){
                        secondScene.currentInfo = stop
                    }
                }
            }
        }
    
        } // end section 1
    else{ // section 0 
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let selectedStop = nearbyBusStops[indexPath.row]
            secondScene.currentStop = selectedStop
            
            //pass on BusStopInformation to the next scene
            for stop in busStopInfo{
                if selectedStop.isEqual(stop.busStop){
                    secondScene.currentInfo = stop
                }
            }
        }
        
        }
        
    }
    
    /*func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        self.filterContentForSearchText(searchString!)
        return true;
    } */
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filteredBusStopInfo.removeAll(keepCapacity:false);
        let searchPredicate = NSPredicate(format:"SELF CONTAINS[c] %@", searchController.searchBar.text!);
        let array = (self.busStopRoutes as NSArray).filteredArrayUsingPredicate(searchPredicate)
        self.filteredBusStopInfo = array as! [String]
        self.tableView.reloadData()
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        print("Refresh")
         dispatch_async(dispatch_get_main_queue()) {
        //self.busStopRoutes.removeAll();
        //self.busStopInfo.removeAll();
       // self.nearbyBusStops.removeAll()
        self.jsonBusRoutes()
           self.tableView.reloadData()
        }
      
        sender.endRefreshing()
        
    }
}
