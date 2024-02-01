/*
 * Copyright 2006 Jeremias Maerki
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// DEPENDENCE: ./debug_placement.cj
// EXEC: cjc %import-path %L %l %f ./debug_placement.cj
// EXEC: ./main

from QRCode4cj import zxing.code.datamatrix.encoder.*
from std import unittest.*
from std import unittest.testmacro.*
from std import convert.*
from std import regex.*
from std import collection.*
from charset import charset.tools.UTF32String


main(): Int64 {
    let tester = PlacementTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
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
        let sb: ArrayList<Char> = ArrayList<Char>()
        for (token in visualized.split(SPACE)) {
            sb.append(Char(Int64.parse(token)));
        }
        return String(sb);
    }
}
