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
    let tester = BitArrayBuilderTest()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class BitArrayBuilderTest {
    @TestCase
    public func testBuildBitArray1(): Unit {
        let pairValues: Array<Array<Int64>> = [[19], [673, 16]]

        let expected: String = " .......X ..XX..X. X.X....X .......X ....";

        checkBinary(pairValues, expected);
    }

    private static func checkBinary(pairValues: Array<Array<Int64>>, expected: String) {
        var binary: BitArray = buildBitArray(pairValues);
        @Expect(expected, binary.toString())
    }

    private static func buildBitArray(pairValues: Array<Array<Int64>>): BitArray {
        let pairs: ArrayList<ExpandedPair> = ArrayList<ExpandedPair>()
        for (i in 0..pairValues.size) {
            var pair: Array<Int64> = pairValues[i]

            var leftChar: DataCharacter
            if (i == 0) {
                leftChar = DataCharacter()
            } else {
                leftChar = DataCharacter(pair[0], 0)
            }

            var rightChar: DataCharacter
            if (i == 0) {
                rightChar = DataCharacter(pair[0], 0)
            } else if (pair.size == 2) {
                rightChar = DataCharacter(pair[1], 0)
            } else {
                rightChar = DataCharacter()
            }

            var expandedPair: ExpandedPair = ExpandedPair(leftChar, rightChar, FinderPattern());

            pairs.append(expandedPair);
        }

        return BitArrayBuilder.buildBitArray(pairs);
    }
}
