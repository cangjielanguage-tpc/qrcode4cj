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

from QRCode4cj import datamatrix.encoder.*
from QRCode4cj import common.*
from std import unittest.*
from std import unittest.testmacro.*
from std import convert.*
from std import regex.*
from std import collection.*
from QRCode4cj import tools.UTF32String


main(): Int64 {
    let tester = SymbolInfoTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * Tests the SymbolInfo class.
 */
@Test
public class SymbolInfoTestCase {
    @TestCase
    public func testSymbolInfo(): Unit {
        var info: ?SymbolInfo = SymbolInfo.lookup(3);
        @Assert(5, info.getOrThrow().getErrorCodewords())
        @Assert(8, info.getOrThrow().matrixWidth)
        @Assert(8, info.getOrThrow().matrixHeight)
        @Assert(10, info.getOrThrow().getSymbolWidth())
        @Assert(10, info.getOrThrow().getSymbolHeight())

        info = SymbolInfo.lookup(3, SymbolShapeHint.FORCE_RECTANGLE)
        @Assert(7, info.getOrThrow().getErrorCodewords())
        @Assert(16, info.getOrThrow().matrixWidth)
        @Assert(6, info.getOrThrow().matrixHeight)
        @Assert(18, info.getOrThrow().getSymbolWidth())
        @Assert(8, info.getOrThrow().getSymbolHeight())

        info = SymbolInfo.lookup(9)
        @Assert(11, info.getOrThrow().getErrorCodewords())
        @Assert(14, info.getOrThrow().matrixWidth)
        @Assert(6, info.getOrThrow().matrixHeight)
        @Assert(32, info.getOrThrow().getSymbolWidth())
        @Assert(8, info.getOrThrow().getSymbolHeight())

        info = SymbolInfo.lookup(9, SymbolShapeHint.FORCE_SQUARE)
        @Assert(12, info.getOrThrow().getErrorCodewords())
        @Assert(14, info.getOrThrow().matrixWidth)
        @Assert(14, info.getOrThrow().matrixHeight)
        @Assert(16, info.getOrThrow().getSymbolWidth())
        @Assert(16, info.getOrThrow().getSymbolHeight())

        try {
            SymbolInfo.lookup(1559);
            @Assert(false)
        } catch (iae: IllegalArgumentException) {
            //expected
        }
        try {
            SymbolInfo.lookup(50, SymbolShapeHint.FORCE_RECTANGLE);
            @Assert(false)
        } catch (iae: IllegalArgumentException) {
            //expected
        }

        info = SymbolInfo.lookup(35)
        @Assert(24, info.getOrThrow().getSymbolWidth())
        @Assert(24, info.getOrThrow().getSymbolHeight())

        let fixedSize: Dimension = Dimension(26, 26);
        info = SymbolInfo.lookup(
            35,
            SymbolShapeHint.FORCE_NONE,
            fixedSize,
            fixedSize,
            false
        )
        if (let Some(i) <- info) {}
        else {
            @Assert(false)
        }
        @Assert(26, info.getOrThrow().getSymbolWidth())
        @Assert(26, info.getOrThrow().getSymbolHeight())

        info = SymbolInfo.lookup(
            45,
            SymbolShapeHint.FORCE_NONE,
            fixedSize,
            fixedSize,
            false
        )
        if (let Some(i) <- info) {
            @Assert(false)
        }

        let minSize: Dimension = fixedSize
        let maxSize: Dimension = Dimension(32, 32);

        info = SymbolInfo.lookup(
            35,
            SymbolShapeHint.FORCE_NONE,
            minSize,
            maxSize,
            false
        )

        @Assert(26, info.getOrThrow().getSymbolWidth())
        @Assert(26, info.getOrThrow().getSymbolHeight())

        info = SymbolInfo.lookup(
            40,
            SymbolShapeHint.FORCE_NONE,
            minSize,
            maxSize,
            false
        )

        @Assert(26, info.getOrThrow().getSymbolWidth())
        @Assert(26, info.getOrThrow().getSymbolHeight())

        info = SymbolInfo.lookup(
            45,
            SymbolShapeHint.FORCE_NONE,
            minSize,
            maxSize,
            false
        )
        if (let Some(i) <- info) {}
        else {
            @Assert(false)
        }
        @Assert(32, info.getOrThrow().getSymbolWidth())
        @Assert(32, info.getOrThrow().getSymbolHeight())

        info = SymbolInfo.lookup(
            63,
            SymbolShapeHint.FORCE_NONE,
            minSize,
            maxSize,
            false
        )
        if (let Some(i) <- info) {
            @Assert(false)
        }
    }
}
