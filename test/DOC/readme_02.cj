// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.*
import QRCode4cj.common.writer.*
import std.unittest.*
import std.unittest.testmacro.*

main(): Int64 {
    let tester = EncoderTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class EncoderTestCase {
    @TestCase
    public func testEncode(): Unit {
        var mfw = MultiFormatWriter();
        var res: BitMatrix = mfw.encode("ABCDEF", BarcodeFormat.QR_CODE, 21, 21)
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
