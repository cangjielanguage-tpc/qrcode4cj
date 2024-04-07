/*
 * Copyright (C) 2014 ZXing authors
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

from QRCode4cj import zxing.code.common.Qrcoder4cjWriterException
from QRCode4cj import zxing.code.common.StandardCharsets
from QRCode4cj import zxing.code.pdf417.encoder.*
from QRCode4cj import zxing.code.pdf417.decoder.*
from QRCode4cj import zxing.code.common.MyCharset
from charset import charset.tools.UTF32String
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import fs.*
from std import math.*
from std import random.*
from std import collection.*
from std import convert.*

main(): Int64 {
    let tester = PDF417EncoderTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * Tests {@link PDF417HighLevelEncoder}.
 */
@Test
public class PDF417EncoderTestCase {
    @TestCase
    public func testEncodeAuto(): Unit {
        let encoded: String = PDF417HighLevelEncoder.encodeHighLevel(
            UTF32String("ABCD"),
            Compaction.AUTO,
            StandardCharsets.UTF_8,
            false
        ).toString();
        @Assert("\u{039f}\u{001A}\u{0385}ABCD", encoded)
    }

    @TestCase
    public func testEncodeAutoWithSpecialChars(): Unit {
        // Just check if this does not throw an exception
        PDF417HighLevelEncoder.encodeHighLevel(UTF32String("1%§s ?aG$"), Compaction.AUTO, StandardCharsets.UTF_8, false
        );
    }

    @TestCase
    public func testEncodeIso88591WithSpecialChars(): Unit {
        // Just check if this does not throw an exception
        PDF417HighLevelEncoder.encodeHighLevel(
            UTF32String("asdfg§asd"),
            Compaction.AUTO,
            StandardCharsets.ISO_8859_1,
            false
        );
    }

    @TestCase
    public func testEncodeText(): Unit {
        let encoded: String = PDF417HighLevelEncoder.encodeHighLevel(
            UTF32String("ABCD"),
            Compaction.TEXT,
            StandardCharsets.UTF_8,
            false
        ).toString();
        @Assert("Ο\u{001A}\u{0001}?", encoded)
    }

    @TestCase
    public func testEncodeNumeric(): Unit {
        let encoded: String = PDF417HighLevelEncoder.encodeHighLevel(
            UTF32String("1234"),
            Compaction.NUMERIC,
            StandardCharsets.UTF_8,
            false
        ).toString();
        @Assert("\u{039f}\u{001A}\u{0386}\f\u{01b2}", encoded)
    }

    @TestCase
    public func testEncodeByte(): Unit {
        let encoded: String = PDF417HighLevelEncoder.encodeHighLevel(
            UTF32String("abcd"),
            Compaction.BYTE,
            StandardCharsets.UTF_8,
            false
        ).toString();
        @Assert("\u{039f}\u{001A}\u{0385}abcd", encoded)
    }

    @TestCase
    public func testEncodeEmptyString(): Unit {
        try {
            PDF417HighLevelEncoder.encodeHighLevel(UTF32String(""), Compaction.AUTO, MyCharset(), false);
            @Assert(false)
        } catch (name: Qrcoder4cjWriterException) {}
    }
}
