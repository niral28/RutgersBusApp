//
//  NearbyBusRouteInterfaceController.swift
//  RutgersBusApp
//
//  Created by Kalu on 1/12/16.
//  Copyright © 2016 Niral. All rights reserved.
//

import WatchKit
import Foundation


class NearbyBusRouteInterfaceController: WKInterfaceController {
    
    @IBOutlet var tableView: WKInterfaceTable!
    @IBOutlet var currentStopLabel: WKInterfaceLabel!
    var currentStop = String()
    var currentStopInfo : BusStopInformation?
    var activeRoutes = [BusInfo]()
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context as! AnyObject?)
        currentStopInfo = decode(context as! NSData)
        
        currentStopLabel.setText(currentStopInfo!.busStop)
        
        for route in (currentStopInfo?.busStopInfo)!{
            print("\(route.busRoute)")
            for pred in route.prediction{
                if (pred.isEqual("No Predictions Available")){
                    break;
                }
                else{
                    activeRoutes.append(route);
                    break;
                }
            }
        }
        
        setupTable(false)
        //currentStopInfo = context as! BusStopInformation
        //currentStop = (currentStopInfo?.busStop)!
        
        // Configure interface objects here.
    }
    // setup Table method
    
    
    func setupTable(let dataRetrive:Bool) {
        
        print("SETTING UP TABLE:\(activeRoutes.count)")
        if (activeRoutes.count == 0 && dataRetrive==false){
            tableView.setNumberOfRows(1, withRowType: "busRouteRow")
            print("Here: No Row")
            if let row = tableView.rowControllerAtIndex(0) as? NearbyBusStopRow {
                print("Setting text")
                row.busStopName.setText("No Nearby Stops")
            }
        }
        else{
            tableView.setNumberOfRows(activeRoutes.count, withRowType: "busRouteRow")
            for var i = 0; i < activeRoutes.count; ++i {
                if let row = tableView.rowControllerAtIndex(i) as? BusRouteRow {
                    //print(busStopInfo[i].busStop)
                    //print("Bus Stop Name:\(nearbyBusStops[i])")
                    row.busRouteName.setText(activeRoutes[i].busRoute)
                    var allPredictions = ""
                    var count = 1;
                    var route = activeRoutes[i]
                    for pred in route.prediction{
                        if count == 1 {
                            if count == route.prediction.count {
                                allPredictions += "In: " + pred
                            }
                            else {
                                allPredictions += "In:" + pred + " ,"
                            }
                        }else {
                            if count == route.prediction.count {
                                allPredictions += pred
                            } else{
                                allPredictions += pred + " ,"
                            }
                        }
                        count++
                    } // prediction for loop
                    row.predictions.setText(allPredictions)
                }// if let end
            }// outer for loop
        }// else
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
