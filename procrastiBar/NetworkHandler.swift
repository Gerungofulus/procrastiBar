//
//  NetworkHandler.swift
//  procastiBar
//
//  Created by Pascal Blunk on 07.09.15.
//  Copyright (c) 2015 Codingcave.de. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket
class NetworkHandler: NSObject, GCDAsyncUdpSocketDelegate, NetServiceDelegate, NetServiceBrowserDelegate {

    static let kImageRcvd = "received an image"
    static var sharedInstance = NetworkHandler()
    var BroadcastAddress:String
    var socket:GCDAsyncUdpSocket
    var nsns:NetService
    var nsb:NetServiceBrowser
    var urls:[URL]
    let port:UInt16 = 6000
    let bonjurDomain = "local."
    let bonjurType = "_procrastibar._udp."
    let bonjurHostname = "Procrastibar@\(Host.current().name!)"
    
    var netServices:[NetService] = []
    override init() {

        socket = GCDAsyncUdpSocket()
        BroadcastAddress = "127.0.0.1"
        urls = []
        nsns = NetService(domain: bonjurDomain,
            type: bonjurType, name: bonjurHostname, port: CInt(port))
        
        nsns.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        nsns.publish()
        /// Net service browser.
        nsb = NetServiceBrowser()

        super.init()
        
        nsns.delegate = self
        socket.setDelegate(self)
        socket.setDelegateQueue(DispatchQueue.main)
        socket.setIPv4Enabled(true)
        socket.setIPv6Enabled(false)
        
        do{
            try socket.bind(toPort: port)
            try socket.beginReceiving()
        }
        catch let err as NSError{
            print(err.localizedDescription)
        }
//        else{
//            if(!socket.beginReceiving(&err)){
//                socket.close()
//                print(err?.localizedDescription)
//            }
//        }

        nsb.delegate = self
        nsb.searchForServices(ofType: bonjurType, inDomain: bonjurDomain)
        //NSRunLoop.currentRunLoop().run()

        //socket.delegate = self
        //socket.delegateQueue = dispatch_get_main_queue()
        
    }
    func sendURL(_ url:URL){

        urls.append(url)

        self.sendString(url.absoluteString)
       
        
    }
    
    func sendString(_ msg:String){
        for partner in self.netServices{

            if let adds = partner.addresses{
                for add in adds{
                    if let ipadd = self.dataToIP(add){

                        self.sendStringToAddress(msg, addr: ipadd, port: partner.port)
                        break;
                    }
                }
            }
        }
        
    }
    
    func sendStringToAddress(_ msg:String, addr:String, port:Int){
        if let data = msg.data(using: String.Encoding.utf8, allowLossyConversion: true){
            self.socket.send(data, toHost: addr, port: UInt16(port), withTimeout: 5, tag: urls.count)
            
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        print("did send data")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket!, didReceiveData data: Data!, fromAddress address: Data!, withFilterContext filterContext: AnyObject!) {
        
        if let msg = NSString(data: data, encoding: String.Encoding.utf8.rawValue){
            if let url = URL(string:String(msg)){
                if let img = NSImage(contentsOf: url){
                    let userInf:[AnyHashable: Any] =  ["image": img]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NetworkHandler.kImageRcvd), object: self, userInfo: userInf)
                }
            }
        }
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        print(error.localizedDescription)
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket!, didConnectToAddress address: Data!) {
        print("i did connect")
    }
    
    //MARK: - NEtService Delegate
    //MARK: Publishing
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("fail")
        print(errorDict)
        
    }
    func netServiceDidPublish(_ sender: NetService) {
        print("published")
    }
    func netServiceWillPublish(_ sender: NetService) {
        print("will publish")
    }
    func netServiceDidStop(_ sender: NetService) {
        
        print("stop")
    }
    
    //MARK: Resolving
    func netServiceWillResolve(_ sender: NetService) {
        print("will resolve")

    }
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("fail")
        print(errorDict)
    }
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        print("update")
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("did resolve")
        
    }
    
    
    
    //MARK: - NSNetServiceBrowser Delegate
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
        aNetService.delegate = self
        aNetService.resolve(withTimeout: 5)
        self.netServices.append(aNetService)
        
    }
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
        let index = (self.netServices as NSArray).index(of: aNetService)
        if(index >= 0 && index < self.netServices.count){
            self.netServices.remove(at: index)
        }
        print("remove \(aNetService)")
    }
    //MARK: - Helper Functions
    
    func dataToIP(_ data:Data?)->String?{
        var address:String?
        
        if (data != nil)
        {
            var storage = sockaddr_storage()
            (data! as NSData).getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)
            
            if Int32(storage.ss_family) == AF_INET {
                let addr4 = withUnsafePointer(to: &storage) { UnsafeRawPointer($0).load(as: sockaddr_in.self) }
                

                address = String(cString: inet_ntoa(addr4.sin_addr), encoding: String.Encoding.ascii)
                

            }
            //TODO IPv6 SUpport
            
        }
        
        return address
    }
}
