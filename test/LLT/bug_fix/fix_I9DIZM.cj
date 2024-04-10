// DEPENDENCE: ../test_common.cj
// DEPENDENCE: ../pkgc/common/abstract_back_box_test_case.cj
// DEPENDENCE: ../pkgc/common/test_result.cj
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from std import unittest.*
from std import unittest.testmacro.*

main(): Int64 {
    let tester = Tester()
    tester.execute()
    tester.printResult()
    0
}

@Test
public class Tester {
    var cur_en_hints = Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints = Option<HashMap<DecodeHintType, Any>>.Some(
        HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER, true)]))
    @TestCase
    func Tester01(): Unit {
        var encode_src_legal = Array<String>(["0", "222", "44444", "6666666", "888888888"])
        for (encode_src in encode_src_legal) {
            @Assert(testITFEncodeException(encode_src,120,120,cur_en_hints,"The length of the input should be even number"),0)
        }
    }
}

public func testITFEncodeException(content: String, width: Int64, height: Int64,
    hints: Option<HashMap<EncodeHintType, Any>>, expEn: String): Int64 {
    try {
        var mfw = MultiFormatWriter();
        var encodeBitMatrix: BitMatrix
        encodeBitMatrix = mfw.encode(content, BarcodeFormat.ITF, width, height)
    } catch (e: IllegalArgumentException) {
        println(e.toString())
        if (e.toString().contains(expEn)) {
            return 0
        } else {
            return 1
        }
    }
    return 2
}
