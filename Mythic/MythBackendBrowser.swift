//
//  MythBackendBrowser.swift
//  Mythic
//
//  Created by Doug Goldstein on 11/30/15.
//  Copyright © 2015 Doug Goldstein. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/. */
//

import Foundation

let MYTHBACKEND_MDNS_NAME = "_mythbackend._tcp"
let SEARCH_TIMEOUT = 20.0

class MythBackendBrowser : NSObject, NSNetServiceBrowserDelegate,
        NSNetServiceDelegate {

    let browser = NSNetServiceBrowser()
    var serviceList = [NSNetService]()
    var mythBackendAddr: String?

    override init() {
        super.init()

        self.browser.delegate = self
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        print("Found: \(service)")

        self.serviceList.append(service)

        if !moreComing {
            update()
        }
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Unable to search for MythTV backend: \(errorDict[NSNetServicesErrorCode])")
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        print("removed service")

        if !moreComing {
            update()
        }
    }

    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        print("searching")
    }

    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        print("search stopped")
    }

    func search() {
        print("kicking off search for: \(MYTHBACKEND_MDNS_NAME)")

        // SEARCH_TIMEOUT second timeout finding a MythTV backend before we error
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * SEARCH_TIMEOUT))

        dispatch_after(popTime, dispatch_get_main_queue()) {
            if self.mythBackendAddr == nil {
                SwiftSpinner.show("Unable to find your MythTV backend", animated: false)
            }
        }

        // show the user some progress
        SwiftSpinner.show("Finding your MythTV backend")

        // and now for the actual search
        self.browser.searchForServicesOfType(MYTHBACKEND_MDNS_NAME, inDomain: "local")
    }

    func update() {
        for service in serviceList {
            service.delegate = self
            service.resolveWithTimeout(5)
        }
    }

    func convertSockAddrToString(sockData: NSData) -> String? {
        // cast and chop up sockaddr_in and sockaddr_in6 for fields
        let sockAddr6 = UnsafePointer<sockaddr_in6>(sockData.bytes)
        let sockFamily = Int32(sockAddr6.memory.sin6_family)
        var in6Addr = sockAddr6.memory.sin6_addr
        var inAddr = UnsafePointer<sockaddr_in>(sockData.bytes).memory.sin_addr

        // compute a buffer size to hold the output of inet_ntop()
        let len = Int(max(INET_ADDRSTRLEN, INET6_ADDRSTRLEN))

        // malloc/memset some memory for inet_ntop() output
        var buf = [CChar](count: len, repeatedValue: 0)

        // create our C string
        let cs: UnsafePointer<CChar>;

        switch (sockFamily) {
        case AF_INET:
            cs = inet_ntop(sockFamily, &inAddr, &buf, socklen_t(len));
        case AF_INET6:
            cs = inet_ntop(sockFamily, &in6Addr, &buf, socklen_t(len));
        default:
            return nil;
        }

        return String.fromCString(cs)
    }

    func netServiceDidResolveAddress(sender: NSNetService) {
        if (self.mythBackendAddr == nil) {
            for sockAddr in (sender.addresses?.enumerate())! {
                if let addr = self.convertSockAddrToString(sockAddr.element) {
                    self.mythBackendAddr = addr
                    self.browser.stop()
                    SwiftSpinner.hide()
                    break;
                }
            }
        }
        print("resolved: \(self.mythBackendAddr)")
    }

    func netServiceDidStop(sender: NSNetService) {
        print("resolve stopped")
    }

    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        print("did not resolve: \(errorDict[NSNetServicesErrorCode])")
    }
}
