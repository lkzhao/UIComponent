//  Created by Luke Zhao on 2/15/20.

import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    return [
      testCase(UIComponentTests.allTests)
    ]
  }
#endif
