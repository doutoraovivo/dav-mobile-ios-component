//
//  SessionControl.swift
//  DaV_Consultorio_SDK
//
//  Created by Prime It Services on 16/11/20.
//

import Foundation
import OpenTok

class Control {
    var session:Session;
    var views:[View] = [];
    
    init(session:Session) {
        self.session = session;
    }
//
//    addView(view: View) {
//        views.append(view);
//    }
//
//    removeView(
}

class Session {
    var connection: [String: Connection] = [:];
    var instance: OTSession;
    
    init(instance: OTSession) {
        self.instance = instance;
    }
    
    var id: String {
        return self.instance.sessionId;
    }
}

class Connection {
    var stream: [String: Stream] = [:];
    var instance: OTConnection;

    init(connection: OTConnection) {
        self.instance = connection;
    }
    
    var id: String {
        return self.instance.connectionId;
    }
}

class Stream {
    var instance: OTStream

    init(stream: OTStream) {
        self.instance = stream;
    }
    
    var id: String {
        return self.instance.streamId;
    }
}

class View {
    var pos:Int;
    init(pos:Int) {
        self.pos = pos;
    }
}

class Publisher: View {
    let instance: OTPublisher
    
    init(pos:Int, publisher: OTPublisher) {
        self.instance = publisher
        super.init(pos: pos);
    }
}

class Subscriber: View {
    let instance: OTSubscriber
    
    init(pos:Int, subscriber: OTSubscriber) {
        self.instance = subscriber;
        super.init(pos: pos);
    }
}

