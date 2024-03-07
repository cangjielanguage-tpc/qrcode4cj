// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from QRCode4cj import zxing.code.common.*
from QRCode4cj import zxing.code.qrcode.*
from std import unittest.*
from std import unittest.testmacro.*

main(): Int64 {
    let tester = EncoderTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
}

@Test
public class EncoderTestCase {
    @TestCase
    public func testEncode(): Unit {
        var res = QRCodeWriter().encode("ABCDEF", BarcodeFormat.QR_CODE, 21, 21)
        var expected = """
                                                          
                                                          
                                                          
                                                          
        X X X X X X X   X   X X X   X X X X X X X         
        X           X       X X     X           X         
        X   X X X   X   X X   X     X   X X X   X         
        X   X X X   X   X X     X   X   X X X   X         
        X   X X X   X   X     X     X   X X X   X         
        X           X     X X X X   X           X         
        X X X X X X X   X   X   X   X X X X X X X         
                              X X                         
        X X X X     X   X X X X X X     X X X   X         
          X   X X X   X X X   X X X X     X X X           
            X X X   X   X   X X           X   X           
            X   X X   X     X X     X X X X   X           
        X         X X   X   X   X     X   X X X X         
                        X X   X     X     X   X X         
        X X X X X X X         X X     X     X X           
        X           X     X X         X X     X X         
        X   X X X   X     X     X X X X X X X   X         
        X   X X X   X   X X   X     X   X     X           
        X   X X X   X   X X     X   X X   X X             
        X           X   X X       X                       
        X X X X X X X   X   X     X     X     X           
                                                          
                                                          
                                                          
                                                          
"""
        @Assert(expected, res.toString())
    }
}
