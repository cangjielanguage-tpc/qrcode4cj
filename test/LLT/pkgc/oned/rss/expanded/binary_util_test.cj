// DEPENDENCE: ./binary_util.cj
// EXEC: cjc %import-path %L %l %f binary_util.cj
// EXEC: ./main

import QRCode4cj.tools.*
import QRCode4cj.common.*
import QRCode4cj.oned.*
import QRCode4cj.oned.rss.*
import QRCode4cj.oned.rss.expanded.*
import QRCode4cj.oned.rss.expanded.decoders.*
import QRCode4cj.client.result.*
import QRCode4cj.common.reader.*
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.regex.*
import std.collection.*
import std.convert.*
import std.fs.*
import std.log.*
import std.os.posix.*
import QRCode4cj.tools.UTF32String
import std.unittest.*
import std.unittest.testmacro.*


main(): Int64 {
    let tester = BinaryUtilTest()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class BinaryUtilTest {
    private static let SPACE: Regex = Regex(" ");

    @TestCase
    public func testBuildBitArrayFromString(): Unit {
        var data: String = " ..X..X.. ..XXX... XXXXXXXX ........";
        check(data);

        data = " XXX..X.."
        check(data);

        data = " XX"
        check(data);

        data = " ....XX.. ..XX"
        check(data);

        data = " ....XX.. ..XX..XX ....X.X. ........"
        check(data);
    }

    private static func check(data: String) {
        var binary: BitArray = BinaryUtil.buildBitArrayFromString(data);
        @Expect(data, binary.toString())
    }

    @TestCase
    public func testBuildBitArrayFromStringWithoutSpaces(): Unit {
        var data: String = " ..X..X.. ..XXX... XXXXXXXX ........";
        checkWithoutSpaces(data);

        data = " XXX..X.."
        checkWithoutSpaces(data);

        data = " XX"
        checkWithoutSpaces(data);

        data = " ....XX.. ..XX"
        checkWithoutSpaces(data);

        data = " ....XX.. ..XX..XX ....X.X. ........"
        checkWithoutSpaces(data);
    }

    private static func checkWithoutSpaces(data: String) {
        var dataWithoutSpaces: String = SPACE.matcher(data).replaceAll("");
        var binary: BitArray = BinaryUtil.buildBitArrayFromStringWithoutSpaces(dataWithoutSpaces);
        @Expect(data, binary.toString())
    }
}
