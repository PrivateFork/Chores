import XCTest

class ChoreTests : XCTestCase {
    func testStandardOutput() {
        let result = >["/bin/echo", "#yolo"]

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "#yolo")
        XCTAssertEqual(result.stderr, "")
    }

    func testStandardError() {
        let result = >["/bin/sh", "-c", "echo yolo >&2"]

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "yolo")
    }

    func testResult() {
        let result = >["/usr/bin/false"]

        XCTAssertEqual(result.result, 1)
    }

    func testResolvesCommandPathsIfNotAbsolute() {
        let result = >"true"

        XCTAssertEqual(result.result, 0)
    }

    func testFailsWithNonExistingCommand() {
        let result = >"/bin/yolo"

        XCTAssertEqual(result.result, 255)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "/bin/yolo: launch path not accessible")
    }

    func testFailsToExecuteDirectory() {
        let result = >"/"

        XCTAssertEqual(result.result, 255)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "/: launch path is a directory")
    }

    func testFailsToExecuteNonExecutableFile() {
        let result = >"/etc/passwd"

        XCTAssertEqual(result.result, 255)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "/etc/passwd: launch path not executable")
    }

    func testSimplePipe() {
        let result = >"ls"|"cat"

        XCTAssertEqual(result.result, 0)
        XCTAssertTrue(result.stdout.characters.count > 0)
        XCTAssertEqual(result.stderr, "")
    }

    func testPipeWithArguments() {
        let result = >["ls", "README.md"]|["sed", "s/READ/EAT/"]

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "EATME.md")
        XCTAssertEqual(result.stderr, "")
    }

    func testPipeFail() {
        let result = >["ls", "yolo"]|"cat"

        XCTAssertEqual(result.result, 1)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "ls: yolo: No such file or directory")
    }

    func testPipeToClosure() {
        let result = >["ls", "LICENSE"]|{ String($0.characters.count) }

        XCTAssertEqual(result.stdout, "7")
    }

    func testPipeToClosureFail() {
        let result = >["ls", "yolo"]|{ String($0.characters.count) }

        XCTAssertEqual(result.result, 1)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "ls: yolo: No such file or directory")
    }

    func testPipeClosureIntoCommand() {
        let result = { "yolo" }|"cat"

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "yolo")
        XCTAssertEqual(result.stderr, "")
    }

    func testPipeStringIntoCommand() {
        let result = "yolo"|"cat"

        XCTAssertEqual(result.result, 0)
        XCTAssertEqual(result.stdout, "yolo")
        XCTAssertEqual(result.stderr, "")
    }
}
