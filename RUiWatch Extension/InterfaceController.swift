//
//  InterfaceController.swift
//  RUiWatch Extension
//
//  Created by Kalu on 1/10/16.
//  Copyright © 2016 Niral. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    
    var dataResults = [[String: AnyObject]]();
    var busStopRoutes = [String] ()
    var busStopRouteTags = [String]()
    var noData = false;
    var busRouteInfo = [BusRouteInfo] ()
    var loaded = false;
  
    @IBOutlet var tableView: WKInterfaceTable!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        loaded = true;
        // Configure interface objects here.
    }
    
    
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func parseBusRoutes(let stops: [[String: AnyObject]]){
        print("in Parsing")
        for stop in stops{
            var temp = BusRouteInfo(busStop: "",stopTag: "");
            if let name = stop["title"] as? String {
                //print(name);
                self.busStopRoutes.append(name);
                temp.busStop = name;
            }
            if let tag = stop["tag"] as? String{
                self.busStopRouteTags.append(tag)
                temp.stopTag = tag;
            }
            self.busRouteInfo.append(temp);
        }
        //print(busStopRoutes.count);
    }
    
    
    
    func jsonBusRoutes() {
        //print("entered parsing");
        let urlPath = "http://runextbus.heroku.com/active"
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint"); return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData; self.noData = true }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                
                if let stops = json["routes"] as? [[String: AnyObject]] {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dataResults=stops
                        print(stops);
                        self.parseBusRoutes(self.dataResults);
                        self.setupTable(false)
                    }
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            }.resume()
        
    }

    

    func setupTable(let dataRetrive:Bool) {
        if dataRetrive{
            jsonBusRoutes()
        }
        if (!dataRetrive && busStopRoutes.count == 0){
             tableView.setNumberOfRows(1, withRowType: "routeRow")
            
                if let row = tableView.rowControllerAtIndex(0) as? ActiveRoute {
                    row.activeRoute.setText("No Active Routes")
                    
                }
            

        }
        else{
             tableView.setNumberOfRows(busStopRoutes.count, withRowType: "routeRow")
           
            for var i = 0; i < busStopRoutes.count; ++i {
                if let row = tableView.rowControllerAtIndex(i) as? ActiveRoute {
                    print(busStopRoutes[i])
                    row.activeRoute.setText(busStopRoutes[i])
                }
            }

        }
        
    }
    
   /* override func contextForSegueWithIdentifier(segueIdentifier: String) ->
        AnyObject? {
            if segueIdentifier == “hierarchical” {
                return [“segue”: “hierarchical”,
                “data”:“Passed through hierarchical navigation”]
            } else if segueIdentifier == “pagebased” {
                return [“segue”: “pagebased”,
                “data”: “Passed through page-based navigation”]
            } else {
                return [“segue”: "", “data”: ""]
            }
    }*/

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        print("here")
        //print("countries \(countries[rowIndex])")
            self.presentControllerWithName("showDetails", context: [busStopRoutes[rowIndex], busStopRouteTags[rowIndex]])

    }
    @IBAction func refreshButton() {
        dataResults.removeAll();
        busStopRoutes.removeAll();
        busStopRouteTags.removeAll();
        busRouteInfo.removeAll();
        setupTable(true);
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("In Activate Interface Controller")
        if (loaded == true){
            setupTable(true)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("In DeActivate Interface Controller")
        loaded = false;
    }

}
