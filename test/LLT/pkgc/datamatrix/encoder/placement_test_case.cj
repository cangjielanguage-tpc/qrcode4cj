// DEPENDENCE: ./debug_placement.cj
// EXEC: cjc %import-path %L %l %f ./debug_placement.cj
// EXEC: ./main

import QRCode4cj.datamatrix.encoder.*
import std.unittest.*
import std.unittest.testmacro.*
import std.convert.*
import std.regex.*
import std.collection.*
import QRCode4cj.tools.UTF32String


main(): Int64 {
    let tester = PlacementTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Tests the DataMatrix placement algorithm.
 */
@Test
public class PlacementTestCase {
    private static let SPACE: String = " ";

    @TestCase
    public func testPlacement(): Unit {
        let codewords: String = unvisualize("66 74 78 66 74 78 129 56 35 102 192 96 226 100 156 1 107 221");
        //"AIMAIM" encoded
        let placement: DebugPlacement = DebugPlacement(codewords, 12, 12);
        placement.place();
        let expected = [
            "011100001111",
            "001010101000",
            "010001010100",
            "001010100010",
            "000111000100",
            "011000010100",
            "000100001101",
            "011000010000",
            "001100001101",
            "100010010111",
            "011101011010",
            "001011001010"
        ]
        let actual: Array<String> = placement.toBitFieldStringArray();
        for (i in 0..actual.size) {
            @Assert(expected[i], actual[i])
        }
    }

    private static func unvisualize(visualized: String): String {
        let sb: ArrayList<Rune> = ArrayList<Rune>()
        for (token in visualized.split(SPACE)) {
            sb.append(Rune(Int64.parse(token)));
        }
        return String(sb);
    }
}
