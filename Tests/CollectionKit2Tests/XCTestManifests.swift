import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
	return [
		testCase(CollectionKit2Tests.allTests),
	]
}
#endif
