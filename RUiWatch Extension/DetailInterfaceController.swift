//
//  DetailInterfaceController.swift
//  RutgersBusApp
//
//  Created by Kalu on 1/10/16.
//  Copyright © 2016 Niral. All rights reserved.
//

import WatchKit
import Foundation


class DetailInterfaceController: WKInterfaceController {
    var currentRoute = String ();
    var currentRouteTag = String()
    // var currentInfo :BusStopInformation?
    //var activeRoutes = [BusInfo]()
    var timeResults = [[String: AnyObject]]();
    var busStopInfo = [BusInfo]()

    @IBOutlet var viewTitle: WKInterfaceLabel!

    @IBOutlet var tableView: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print("Check:\(context)")
        self.currentRoute = context![0] as! String
        self.currentRouteTag = context![1] as! String
        viewTitle.setText(currentRoute)
        setupTable(true)
        //countryName.setText(name)
        //capital.setText(capitals[name]!)
        //currency.setText(currencies[name]!)
        //flag.setImage(UIImage(named:flags[name]!))
        // Configure interface objects here.
    }
    
    
    func setupTable(let dataRetrive:Bool) {
        if dataRetrive{
            jsonStopPredictions(currentRouteTag)
        }
        if (!dataRetrive && busStopInfo.count == 0){
            tableView.setNumberOfRows(1, withRowType: "busStopRow")
            
            if let row = tableView.rowControllerAtIndex(0) as? BusStopRow {
                row.busStopName.setText("No Active Routes")
                row.stopPredictions.setText("No Available Predictions")
            }
        }
        else{
            tableView.setNumberOfRows(busStopInfo.count, withRowType: "busStopRow")
            
            for var i = 0; i < busStopInfo.count; ++i {
                if let row = tableView.rowControllerAtIndex(i) as? BusStopRow {
                    print(busStopInfo[i].busRoute)
                    row.busStopName.setText(busStopInfo[i].busRoute)
                    var allPredictions = ""
                    
                    // styling:
                    var count = 1;
                    for pred in busStopInfo[i].prediction  {
                        if count == busStopInfo[i].prediction.count {
                            allPredictions += pred
                        } else{
                            if count == 1 {
                            allPredictions += "In: "+pred + " , "
                            }
                            else{
                               allPredictions += pred + " , "
                            }
                        }
                        count++
                    }
                    print("Predictions:\(allPredictions)")
                    row.stopPredictions.setText(allPredictions)

                }
            }
            
        }
        
    }
    
    
    func parseBusPredictions(let infos: [[String: AnyObject]]) {
        //var routeInfo = [BusInfo]()
        // print("starting to add to array predictions");
        //print(infos)
        // print("Bus Stop Info: \(stopTag)")
        //print("***************");
        
        for data in infos{
            
            // print("Info Data:")
            // print(data)
            //print("")
            if var name = data["title"] as? String where !name.isEmpty {
                //  print("title:\(name)");
                // print("")
                var predictionTimes = [String] ()
                
                
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
                            //print("mins:\(mins)")
                            let secs = time["seconds"] as! String
                            //print("seconds:\(secs)")
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
                    // print("")
                    predictionTimes.append("No Predictions Available")
                }
                
                var newBusInfo = BusInfo(busRoute:name, prediction: predictionTimes)
                busStopInfo.append(newBusInfo);
            }
        }
        // print("Number of Bus Stops")
        //  print(busStopInfo.count)
        // outer for loop
        //var newBusStopInfo = BusStopInformation(busStop:stopTag, busStopInfo:routeInfo)
        //self.busStopInfo.append(newBusStopInfo);
    }// method
    
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    
    
    func jsonStopPredictions(let stopTag:String) {
        let stopTagNoSpaces = stopTag.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let urlPath = "http://runextbus.heroku.com/route/\(stopTagNoSpaces)"
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint"); return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSArray else { throw JSONError.ConversionFailed }
                dispatch_async(dispatch_get_main_queue()) {
                    self.timeResults=json as! [[String : AnyObject]]
                    //  print(json);
                    //print("start parsing details")
                    self.parseBusPredictions(self.timeResults);
                    self.setupTable(false)
                }
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            }.resume()
        
    }
    
    @IBAction func refreshButton() {
        busStopInfo.removeAll();
        timeResults.removeAll();
        setupTable(true);
    }
    


    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
