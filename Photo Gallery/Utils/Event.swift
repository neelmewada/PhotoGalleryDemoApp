//
//  Event.swift
//  Photo Gallery
//
//  Created by Neel Mewada on 15/05/21.
//

import Foundation

/// Class for handling events.
class Event {
    typealias EventHandler = () -> ()
    
    private var subscribers = [EventHandler]()
    
    /// Adds the given handler as a subscriber. Make sure to pass the handler parameter as a closure with `[weak self]` to avoid retain cycles and memory leaks.
    func addSubscriber(_ subscriber: @escaping EventHandler) {
        subscribers.append(subscriber)
    }
    
    func removeAllSubscribers() {
        subscribers.removeAll()
    }
    
    /// Notifies all the subscribers. In other words: Raises this event.
    func raiseEvent() {
        for subscriber in subscribers {
            subscriber()
        }
    }
}
