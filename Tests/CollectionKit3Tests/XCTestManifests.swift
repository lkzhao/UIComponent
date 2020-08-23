import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
	return [
		testCase(CollectionKit3Tests.allTests),
	]
}
#endif
