//
//  File.swift
//  UIComponent
//
//  Created by Luke Zhao on 11/8/24.
//

import Testing
@testable import UIComponent
import UIKit

@Suite("Data Caching")
@MainActor
struct DataCachingTest {

    class DataHolder<T> {
        var data: T
        init(data: T) {
            self.data = data
        }
    }

    @Test func testCachingData() throws {
        var view: UIView! = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        var callCount = 0
        weak var holder: DataHolder<String>?
        view.componentEngine.component = CachingItem(key: "1", itemGenerator: {
            callCount += 1
            let h = DataHolder(data: "1")
            holder = h
            return h
        }, componentBuilder: { (data: DataHolder<String>) in
            Text(data.data)
        })
        view.componentEngine.reloadData()
        #expect(callCount == 1)
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel?.text == "1")
        #expect(holder != nil)

        view.componentEngine.component = CachingItem(key: "1", itemGenerator: {
            callCount += 1
            let h = DataHolder(data: "1")
            holder = h
            return h
        }, componentBuilder: { (data: DataHolder<String>) in
            Text(data.data)
        })
        view.componentEngine.reloadData()
        #expect(callCount == 1)
        #expect(holder != nil)

        view.componentEngine.component = Text("2")
        view.componentEngine.reloadData()
        #expect(callCount == 1)
        #expect(holder != nil)

        // data should be released
        view = nil
        #expect(callCount == 1)
        #expect(holder == nil)
    }

    @Test func testCachingDataWithWrappedView() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        var callCount = 0
        view.componentEngine.component = CachingItem(key: "1", itemGenerator: {
            callCount += 1
            return "1"
        }, componentBuilder: {
            Text($0)
        }).view()
        view.componentEngine.reloadData()
        #expect(callCount == 1)
        #expect(view.subviews.count == 1)

        view.componentEngine.component = CachingItem(key: "1", itemGenerator: {
            callCount += 1
            return "1"
        }, componentBuilder: {
            Text($0)
        }).view()
        view.componentEngine.reloadData()
        #expect(callCount == 1)
    }

    @Test func testCachingDataScrolling() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        var callCount = 0

        view.componentEngine.component = CachingItem(key: "1", itemGenerator: {
            callCount += 1
            return "1"
        }, componentBuilder: {
            Text($0)
        }).view()
        view.componentEngine.reloadData()
        #expect(callCount == 1)
        #expect(view.subviews.count == 1)

        view.componentEngine.component = VStack {
            Space(height: 5000)
            CachingItem(key: "1", itemGenerator: {
                callCount += 1
                return "1"
            }, componentBuilder: {
                Text($0)
            }).view()
        }
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 0)
        #expect(callCount == 1)

        view.bounds.origin = CGPoint(x: 0, y: 5000)
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        #expect(callCount == 1)
    }

    @Test func testCachingDataWithFixedSizeScrolling() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        var callCount = 0
        view.componentEngine.component = VStack {
            Space(height: 5000)
            CachingItem(key: "1", itemGenerator: {
                callCount += 1
                return "1"
            }, componentBuilder: {
                Text($0)
            }).size(width: 100, height: 100)
        }
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 0)
        #expect(callCount == 0)

        view.componentEngine.component = CachingItem(key: "1", itemGenerator: {
            callCount += 1
            return "1"
        }, componentBuilder: {
            Text($0)
        }).size(width: 100, height: 100)
        view.componentEngine.reloadData()
        #expect(callCount == 1)
        #expect(view.subviews.count == 1)

        view.componentEngine.component = VStack {
            Space(height: 5000)
            CachingItem(key: "1", itemGenerator: {
                callCount += 1
                return "1"
            }, componentBuilder: {
                Text($0)
            }).size(width: 100, height: 100)
        }
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 0)
        #expect(callCount == 1)

        view.bounds.origin = CGPoint(x: 0, y: 5000)
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        #expect(callCount == 1)
    }

    @Test func testCachingDataWithDifferentType() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        var callCount = 0
        view.componentEngine.component = CachingItem(key: "1", itemGenerator: {
            callCount += 1
            return 1
        }, componentBuilder: {
            Text("\($0)")
        })
        view.componentEngine.reloadData()
        #expect(callCount == 1)
        #expect(view.subviews.count == 1)

        view.componentEngine.component = CachingItem(key: "1", itemGenerator: {
            callCount += 1
            return "1"
        }, componentBuilder: {
            Text($0)
        })
        view.componentEngine.reloadData()
        #expect(callCount == 2)
    }
}
