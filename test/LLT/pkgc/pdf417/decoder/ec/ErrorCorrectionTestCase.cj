/*
 * Copyright 2012 ZXing authors
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

// DEPENDENCE: ./info.txt
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from QRCode4cj import zxing.code.common.Qrcoder4cjChecksumException
from QRCode4cj import zxing.code.pdf417.decoder.ec.*
from std import random.*
from std import collection.*
from std import convert.*
from std import fs.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion

main(): Int64 {
    let tester = ErrorCorrectionTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author Sean Owen
 */
@Test
public class ErrorCorrectionTestCase {
    static var fileNum = 0;

    static var testOneError_1 = ArrayList<Int64>();
    static var testMaxErrors_1 = ArrayList<Int64>();
    static var testTooManyErrors_1 = ArrayList<Int64>();

    private static let PDF417_TEST: Array<Int64> = [
        48,
        901,
        56,
        141,
        627,
        856,
        330,
        69,
        244,
        900,
        852,
        169,
        843,
        895,
        852,
        895,
        913,
        154,
        845,
        778,
        387,
        89,
        869,
        901,
        219,
        474,
        543,
        650,
        169,
        201,
        9,
        160,
        35,
        70,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900
    ]
    private static let PDF417_TEST_WITH_EC: Array<Int64> = [
        48,
        901,
        56,
        141,
        627,
        856,
        330,
        69,
        244,
        900,
        852,
        169,
        843,
        895,
        852,
        895,
        913,
        154,
        845,
        778,
        387,
        89,
        869,
        901,
        219,
        474,
        543,
        650,
        169,
        201,
        9,
        160,
        35,
        70,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        900,
        769,
        843,
        591,
        910,
        605,
        206,
        706,
        917,
        371,
        469,
        79,
        718,
        47,
        777,
        249,
        262,
        193,
        620,
        597,
        477,
        450,
        806,
        908,
        309,
        153,
        871,
        686,
        838,
        185,
        674,
        68,
        679,
        691,
        794,
        497,
        479,
        234,
        250,
        496,
        43,
        347,
        582,
        882,
        536,
        322,
        317,
        273,
        194,
        917,
        237,
        420,
        859,
        340,
        115,
        222,
        808,
        866,
        836,
        417,
        121,
        833,
        459,
        64,
        159
    ]
    private static let ECC_BYTES: Int64 = PDF417_TEST_WITH_EC.size - PDF417_TEST.size
    private static let ERROR_LIMIT: Int64 = ECC_BYTES
    private static let MAX_ERRORS: Int64 = ERROR_LIMIT / 2
    private static let MAX_ERASURES: Int64 = ERROR_LIMIT

    private let ec: ErrorCorrection = ErrorCorrection();

    @TestCase
    public func testNoError(): Unit {
        var received: Array<Int64> = PDF417_TEST_WITH_EC.clone();

        // no errors
        checkDecode(received);
    }

    @TestCase
    public func testOneError(): Unit {
        readFile();
        var random: Random = getRandom();

        for (i in 0..PDF417_TEST_WITH_EC.size) {
            var received: Array<Int64> = PDF417_TEST_WITH_EC.clone();
            received[i] = nextInt("testOneError")
            checkDecode(received);
        }
    }

    @TestCase
    public func testMaxErrors(): Unit {
        readFile();
        var random: Random = getRandom();

        for (testIterations in 0..100) { // # iterations is kind of arbitrary
            var received: Array<Int64> = PDF417_TEST_WITH_EC.clone();
            corrupt(received, MAX_ERRORS, random, "testMaxErrors");
            checkDecode(received);
        }
    }

    @TestCase
    public func testTooManyErrors(): Unit {
        readFile();
        var received: Array<Int64> = PDF417_TEST_WITH_EC.clone();
        var random: Random = getRandom();
        corrupt(received, MAX_ERRORS + 1, random, "testTooManyErrors");
        try {
            checkDecode(received);
            @Assert(false)
        } catch (ce: Qrcoder4cjChecksumException) {
            // good
        }
    }

    private static func getRandom(flag!: Bool = true): Random {
        if (flag) {
            fileNum = 0
        }

        return Random(0xDEADBEEF);
    }

    private func checkDecode(received: Array<Int64>) {
        checkDecode(received, Array<Int64>(0, item: 0));
    }

    private func checkDecode(received: Array<Int64>, erasures: Array<Int64>) {
        ec.decode(received, ECC_BYTES, erasures);
        for (i in 0..PDF417_TEST.size) {
            @Assert(received[i], PDF417_TEST[i])
        }
    }

    public static func corrupt(
        received: Array<Int64>,
        howMany: Int64,
        random: Random,
        fileName: String,
        max!: Int64 = 929
    ) {
        var corrupted: Array<Bool> = Array<Bool>(received.size, item: false);

        var j = 0;
        while (j < howMany) {
            var location: Int64 = nextInt(fileName);

            var value: Int64 = nextInt(fileName);

            if (corrupted[Int64(location)] || received[Int64(location)] == Int64(value)) {
                j--
            } else {
                corrupted[Int64(location)] = true
                received[Int64(location)] = Int64(value)
            }

            j++
        }
    }

    private static func nextInt(fileName: String): Int64 {
        var numItem: Int64 = 0;
        match (fileName) {
            case "testOneError" =>
                numItem = testOneError_1.get(fileNum).getOrThrow()
                fileNum++
            case "testMaxErrors" =>
                numItem = testMaxErrors_1.get(fileNum).getOrThrow()
                fileNum++
            case "testTooManyErrors" =>
                numItem = testTooManyErrors_1.get(fileNum).getOrThrow()
                fileNum++
            case _ => numItem = 0
        }

        return numItem
    }

    private func readFile() {
        testOneError_1.clear();
        testMaxErrors_1.clear();
        testTooManyErrors_1.clear();

        var file: File = File("./info.txt", OpenOption.Open(true, true));
        var info = Array<Byte>(file.length, item: 0);
        var size = file.read(info);
        file.close();
        var item = ArrayList<Char>();
        var str = String();
        var fileName = String();
        for (i in 0..size) {
            if (Char(UInt8(info[i])) == ' ' || Char(UInt8(info[i])) == '\n' || Char(UInt8(info[i])) == '\r') {
                str = String(item)
                if (Int64.tryParse(str) != Option<Int64>.None) {
                    match (fileName) {
                        case "testOneError" => testOneError_1.append(Int64.parse(str));
                        case "testMaxErrors" => testMaxErrors_1.append(Int64.parse(str));
                        case "testTooManyErrors" => testTooManyErrors_1.append(Int64.parse(str));

                        case _ => item.clear();
                    }
                } else if (item.size != 0) {
                    fileName = str
                }
                item.clear();
            } else {
                item.append(Char(UInt8(info[i])));
            }
        }
    }
}
