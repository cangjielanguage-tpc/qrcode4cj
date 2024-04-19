/*
 * Copyright 2006 Jeremias Maerki.
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

// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from QRCode4cj import datamatrix.encoder.*
from std import unittest.*
from std import unittest.testmacro.*
from QRCode4cj import tools.UTF32String

main(): Int64 {
    let tester = ErrorCorrectionTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * Tests for the ECC200 error correction.
 */
@Test
public class ErrorCorrectionTestCase {
    @TestCase
    public func testRS(): Unit {
        //Sample from Annexe R in ISO/IEC 16022:2000(E)
        var cw: Array<Char> = [Char(142), Char(164), Char(186)]
        let symbolInfo: ?SymbolInfo = SymbolInfo.lookup(3);
        var s: String = ErrorCorrection.encodeECC200(UTF32String(cw), symbolInfo.getOrThrow());
        @Assert("142 164 186 114 25 5 88 102", visualize(UTF32String(s)))

        //"A" encoded (ASCII encoding + 2 padding characters)
        cw = [Char(66), Char(129), Char(70)]
        s = ErrorCorrection.encodeECC200(UTF32String(cw), symbolInfo.getOrThrow())
        @Assert("66 129 70 138 234 82 82 95", visualize(UTF32String(s)))
    }
}

func visualize(codewords: UTF32String): String {
    var sb: StringBuilder = StringBuilder();
    for (i in 0..codewords.charSize) {
        if (i > 0) {
            sb.append(' ');
        }
        sb.append(codewords.get(i).hashCode())
    }
    return sb.toString();
}
