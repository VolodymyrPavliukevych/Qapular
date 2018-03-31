//
//  QCCProjectProcessor+Report.swift
//  Qapular
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation


extension QCCProjectProcessor {

    func printReport(report:[String: String]) -> Void {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            guard let themaManager : QCCThemaManager = self.projectDocument().themaManager() else {
                return
            }
            
            guard let outputReportThema : [String : AnyObject] = themaManager.outputReportThema() else {
                return
            }
            
            guard let errorReportThema : [String : AnyObject] = themaManager.errorReportThema() else {
                return
            }
            
            let reportLine : NSMutableAttributedString = NSMutableAttributedString()
            
            
            if let launchComand = report[QCCActionReportType.LaunchComand.identifier()]{
                reportLine.appendAttributedString(NSAttributedString(string: launchComand, attributes: outputReportThema))
                reportLine.appendAttributedString(NSAttributedString(string: "\n", attributes: outputReportThema))
                
            }
            
            if let launchArgs = report[QCCActionReportType.LaunchArgs.identifier()]{
                reportLine.appendAttributedString(NSAttributedString(string: launchArgs, attributes: outputReportThema))
                reportLine.appendAttributedString(NSAttributedString(string: "\n", attributes: outputReportThema))
            }
            
            if let output = report[QCCActionReportType.Output.identifier()]{
                reportLine.appendAttributedString(NSAttributedString(string: output, attributes: outputReportThema))
                reportLine.appendAttributedString(NSAttributedString(string: "\n", attributes: outputReportThema))
            }
            
            if let error = report[QCCActionReportType.Error.identifier()]{
                reportLine.appendAttributedString(NSAttributedString(string: error, attributes: errorReportThema))
                reportLine.appendAttributedString(NSAttributedString(string: "\n", attributes: outputReportThema))
            }
            
            self.processReportDelegate?.insertReportLine(reportLine)
        }
    }
    
    func clearReport() -> Void {
        dispatch_async(dispatch_get_main_queue()) {
            self.processReportDelegate?.clearReport()
        }
    }
}


