//
//  HealthViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Niral Shah on 4/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
//import Charts

import HealthKit

class HealthViewController: UIViewController {

   /* override func viewDidLoad() {
        super.viewDidLoad()
         drawGraph();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    let healthManager:HealthManager = HealthManager();
    var chartVals:[ChartDataEntry] = []
    var dataPoints = [String]();
    var index = 0;
    let kUnknownString   = "Unknown"
    var healthStore :HKHealthStore = HKHealthStore();
    var calorieGoal = 0.0;
    var weeklyGoal = 0.0;

    @IBOutlet weak var linechartView: LineChartView!
    func plotPoints (){ // plots data Points
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let lineChartDataSet = LineChartDataSet(yVals: self.chartVals, label: "Calories")
            //lineChartDataSet.drawCirclesEnabled = false;
            lineChartDataSet.drawCubicEnabled = true;
            //lineChartDataSet.colors = ChartColorTemplates.colorful();
            
            let lineChartData = LineChartData(xVals: self.dataPoints, dataSet: lineChartDataSet)
            self.linechartView.data = lineChartData
            self.linechartView.data?.setValueTextColor(UIColor.blackColor())
            
            
            
            
            self.linechartView.descriptionText = ""
            var yaxis = ChartYAxis();
            var xaxis = ChartXAxis();
            xaxis = self.linechartView.xAxis;
            xaxis.wordWrapEnabled = true;
            xaxis.spaceBetweenLabels = 1
            // xaxis.labelPosition = .Bottom;
            
            yaxis = self.linechartView.leftAxis;
            yaxis.enabled = true;
            
            var yaxis2 = self.linechartView.rightAxis;
            yaxis2.enabled = false;
            
            
            self.linechartView.animate(xAxisDuration: 0.2, yAxisDuration: 0.2, easingOptionX: .EaseInCubic, easingOptionY: .EaseInCubic)
        });
    }
    var bmi:Double?
    var height, weight:HKQuantitySample?
    var calories: Double?
    var weeklyCalories:Double?
    var currentCalories: Double?
    var weeklyCurrentCalories : Double?
    
    func updateHealthInfo() {
        
        updateProfileInfo();
        updateWeight();
        updateHeight();
        updateCalories();
        updateWeeklyCalories();
        
    }

    func updateHeight()
    {
        // 1. Construct an HKSampleType for Height
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        
        // 2. Call the method to read the most recent Height sample
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentHeight, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading height from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var heightLocalizedString = self.kUnknownString;
            self.height = mostRecentHeight as? HKQuantitySample;
            // 3. Format the height to display it on the screen
            if let meters = self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit()) {
                let heightFormatter = NSLengthFormatter()
                heightFormatter.forPersonHeightUse = true;
                heightLocalizedString = heightFormatter.stringFromMeters(meters);
            }
            
            
            // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.heightLabel.text = heightLocalizedString
                //self.updateBMI()
            });
        })
        
        
    }
    
    func updateCalories() // updates calorie when user opens app.
    { // This method obtains calories burned over past day from midnight of current day to current time
        self.calories = 0;
        // 1. Construct an HKSampleType for Height
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
        
        self.healthManager.readPastDayEnergy(sampleType!, completion: { (mostRecentCalories, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading calories from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            else{
                var calLocalizedString = self.kUnknownString;
                self.calories = mostRecentCalories
                if self.calories > 0{
                    self.currentCalories = mostRecentCalories * 0.000239006; // converts joules to kilocalories
                    let calFomatter = NSEnergyFormatter();
                    calFomatter.forFoodEnergyUse = true;
                    calLocalizedString = calFomatter.stringFromJoules(self.calories!)
                    
                    self.currentUser.setValue(self.currentCalories, forKey: "Calories")
                    self.currentUser.setValue(self.weeklyGoal, forKey: "weeklyGoal")
                    self.currentUser.setValue(self.calorieGoal, forKey: "dailyGoal")
                    self.currentUser.saveInBackground()
                }
                
                
                // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.caloriesLabel.text = calLocalizedString;
                    //self.updateBMI()
                    self.updateCircularProgressBar();
                    if(self.loaded == false){
                        self.updateFitCoins();
                    }
                    self.loaded = true;
                });
                
            }
        })
        
    }
    
    func updateWeeklyCalories()
    { // This method obtains calories burned over past day from midnight of current day to current time
        self.weeklyCalories = 0;
        // 1. Construct an HKSampleType for Height
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
        
        self.healthManager.readPastWeekEnergy(sampleType!, completion: { (mostRecentCalories, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading calories from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            else{
                var calLocalizedString = self.kUnknownString;
                self.weeklyCalories = mostRecentCalories
                
                if self.weeklyCalories > 0 {
                    self.weeklyCurrentCalories = mostRecentCalories * 0.000239006; // converts joules to kilocalories
                    print("weekly current calories");
                    print(self.weeklyCurrentCalories);
                    let calFomatter = NSEnergyFormatter();
                    calFomatter.forFoodEnergyUse = true;
                    calLocalizedString = calFomatter.stringFromJoules(self.weeklyCurrentCalories!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.weeklyCalorie.text = calLocalizedString;
                        //self.updateBMI()
                        self.updateWeeklyCircularProgressBar()
                    });
                } else{
                    self.weeklyCurrentCalories = 1110;
                    let calFomatter = NSEnergyFormatter();
                    calFomatter.forFoodEnergyUse = true;
                    calLocalizedString = calFomatter.stringFromJoules(self.weeklyCurrentCalories!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.weeklyCalorie.text = "1110 cal"
                        //self.updateBMI()
                        self.updateWeeklyCircularProgressBar()
                    });
                }
                
                
                // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
                
            }
        })
        
    }
    
    func drawGraph(){ // draw the graph
        self.getWeeklyData();
        self.plotPoints();
    }
    
    func drawWeeklyGraph()
    { // This method obtains calories burned over past day from midnight of current day to current time
        //self.weeklyCalories = 0;
        // 1. Construct an HKSampleType for Height
        var dataArray = [Double]();
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
        
        self.healthManager.readPastAllEnergy(sampleType!, completion: { (mostRecentCalories, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading calories from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            else{
                var calLocalizedString = self.kUnknownString;
                var chartVals:[ChartDataEntry] = []
                var i = 0;
                var dataPoints = [String]();
                
                if mostRecentCalories.count > 1 {
                    guard let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) else {
                        fatalError("*** This should never fail. ***")
                    }
                    var endDate = NSDate();
                    var startDate = calendar.dateByAddingUnit(.Day, value: -6, toDate: endDate, options: .WrapComponents);
                    for sample in mostRecentCalories {
                        print(sample);
                        var calSample = sample * 0.000239006*1000; // converts joules to kilocalories
                        print(calSample);
                        let dataEntry = ChartDataEntry(value: calSample, xIndex: i)
                        chartVals.append(dataEntry)
                        print(i)
                        var month = "\(calendar.component(.Month, fromDate: startDate!))"
                        dataPoints.append("\(month)/\(calendar.component(.Day, fromDate: startDate!))");
                        
                        ++i
                        startDate = calendar.dateByAddingUnit(.Day, value: 1, toDate: startDate!, options: .WrapComponents);
                    }
                    // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let lineChartDataSet = LineChartDataSet(yVals: chartVals, label: "Calories")
                        //lineChartDataSet.drawCirclesEnabled = false;
                        lineChartDataSet.drawCubicEnabled = true;
                        //lineChartDataSet.colors = ChartColorTemplates.colorful();
                        
                        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
                        self.linechartView.data = lineChartData
                        self.linechartView.data?.setValueTextColor(UIColor.blackColor())
                        
                        
                        
                        
                        self.linechartView.descriptionText = ""
                        var yaxis = ChartYAxis();
                        var xaxis = ChartXAxis();
                        xaxis = self.linechartView.xAxis;
                        xaxis.wordWrapEnabled = true;
                        xaxis.spaceBetweenLabels = 1
                        xaxis.labelPosition = .Top;
                        
                        yaxis = self.linechartView.leftAxis;
                        yaxis.enabled = true;
                        
                        var yaxis2 = self.linechartView.rightAxis;
                        yaxis2.enabled = false;
                        
                        
                        self.linechartView.animate(xAxisDuration: 0.2, yAxisDuration: 0.2, easingOptionX: .EaseInCubic, easingOptionY: .EaseInCubic)
                        
                        
                    });
                }
                
            }
        })
        
    }
    
    /*var dataArray:[Double] = [];
     var chartVals2:[ChartDataEntry] = []
     var dataPoints2 = [String]();
     
     func getCaloriesDay(d:NSDate){
     print("in drawGraph");
     
     var sampleValue = 0.0;
     let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
     var endDate = d;
     
     var x = healthManager.readDayEnergy(sampleType!, date: d, completion: { (mostRecentCalories, error) -> Void in
     
     if( error != nil )
     {
     print("Error reading calories from HealthKit Store: \(error.localizedDescription)")
     return
     }
     else{
     var calVal = mostRecentCalories * 0.000239006
     
     }
     // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
     
     
     
     
     });
     
     
     
     }*/
    
    func getWeeklyData () { // statistics
        
        
        let calendar = NSCalendar.currentCalendar()
        
        let interval = NSDateComponents()
        interval.day = 1
        
        // Set the anchor date to Monday at 3:00 a.m.
        let anchorComponents = calendar.components([.Day, .Month, .Year, .Weekday], fromDate: NSDate())
        anchorComponents.hour = 1
        
        //let offset = (7 + anchorComponents.weekday - 2) % 7
        anchorComponents.day = 1;
        anchorComponents.hour = 1
        
        guard let anchorDate = calendar.dateFromComponents(anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .CumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(error?.localizedDescription) ***")
            }
            
            let endDate = NSDate()
            
            guard let startDate = calendar.dateByAddingUnit(.Day, value: -7, toDate: endDate, options: []) else {
                fatalError("*** Unable to calculate the start date ***")
            }
            
            // Plot data over past week
            statsCollection.enumerateStatisticsFromDate(startDate, toDate: endDate) { [unowned self] statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValueForUnit(HKUnit.jouleUnit()) * 0.000239006;
                    
                    // Call a custom method to plot each data point.
                    //self.plotWeeklyStepCount(value, forDate: date)
                    self.addPoints(value, forDate: date)
                }
            }
        }
        healthStore.executeQuery(query)
        plotPoints();
    }
    
    var chartVals:[ChartDataEntry] = []
    var dataPoints = [String]();
    var index = 0;
    
    func addPoints(value:Double, forDate:NSDate ){
        let calendar = NSCalendar.currentCalendar()
        let dataEntry = ChartDataEntry(value: value, xIndex: self.index)
        print(value);
        chartVals.append(dataEntry)
        let month = calendar.component(.Month, fromDate: forDate)
        let day = calendar.component(.Day, fromDate: forDate)
        dataPoints.append("\(month)/\(day)")
        self.index++;
    }
    
    func plotPoints (){ // plots data Points
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let lineChartDataSet = LineChartDataSet(yVals: self.chartVals, label: "Calories")
            //lineChartDataSet.drawCirclesEnabled = false;
            lineChartDataSet.drawCubicEnabled = true;
            //lineChartDataSet.colors = ChartColorTemplates.colorful();
            
            let lineChartData = LineChartData(xVals: self.dataPoints, dataSet: lineChartDataSet)
            self.linechartView.data = lineChartData
            self.linechartView.data?.setValueTextColor(UIColor.blackColor())
            
            
            
            
            self.linechartView.descriptionText = ""
            var yaxis = ChartYAxis();
            var xaxis = ChartXAxis();
            xaxis = self.linechartView.xAxis;
            xaxis.wordWrapEnabled = true;
            xaxis.spaceBetweenLabels = 1
            // xaxis.labelPosition = .Bottom;
            
            yaxis = self.linechartView.leftAxis;
            yaxis.enabled = true;
            
            var yaxis2 = self.linechartView.rightAxis;
            yaxis2.enabled = false;
            
            
            self.linechartView.animate(xAxisDuration: 0.2, yAxisDuration: 0.2, easingOptionX: .EaseInCubic, easingOptionY: .EaseInCubic)
        });
    }
    
    
    func updateWeight()
    {
        // 1. Construct an HKSampleType for weight
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        
        // 2. Call the method to read the most recent weight sample
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var weightLocalizedString = self.kUnknownString;
            // 3. Format the weight to display it on the screen
            self.weight = mostRecentWeight as? HKQuantitySample;
            if let kilograms = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
                let weightFormatter = NSMassFormatter()
                weightFormatter.forPersonMassUse = true;
                weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
                self.weightVal = kilograms;
            }
            
            // 4. Update UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.weightLabel.text = weightLocalizedString
                //  self.updateBMI()
                
            });
        });
    }
    
    
    
    
    // MARK: - utility methods
    func biologicalSexLiteral(biologicalSex:HKBiologicalSex?)->String
    {
        var biologicalSexText = kUnknownString;
        
        if  biologicalSex != nil {
            
            switch( biologicalSex! )
            {
            case .Female:
                biologicalSexText = "Female"
                self.gender = 0;
            case .Male:
                biologicalSexText = "Male"
                self.gender = 1;
            default:
                self.gender = 1;
                break;
            }
            
        }
        return biologicalSexText;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
*/
}
