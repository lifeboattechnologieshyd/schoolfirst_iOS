//
//  ReachabilityManager.swift
//  Pods
//
//  Created by vamshi krishna on 06/06/26.
//

import UIKit
import Network

final class ReachabilityManager {

    static let shared = ReachabilityManager()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "InternetMonitor")

    private(set) var isConnected = true

    private init() {

        monitor.pathUpdateHandler = { path in

            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied

                print("Internet Status: \(self.isConnected)")
            }
        }

        monitor.start(queue: queue)
    }
}
