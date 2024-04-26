// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from QRCode4cj import common.*
from QRCode4cj import common.writer.*
from QRCode4cj import tools.*
from QRCode4cj import common.detector.*
from QRCode4cj import common.ResultPoint
from QRCode4cj import client.result.*
from QRCode4cj import oned.rss.expanded.*
from charset import charset.*
from QRCode4cj import tools.UTF32String
from charset import charset.encoding.*
from charset import charset.exception.*

main(): Int64 {
    let tester = Tester()
    tester.execute()
    tester.printResult()
    0
}

@Test
public class Tester {
    @TestCase
    func t1(): Unit {
        var rgb = RGBLuminanceSource(2, 2, Array<Int64>([5, 9, 45, 7]))
        var bin = GlobalHistogramBinarizer(rgb)
        var source = BinaryBitmap(bin)
        @Assert(source.isCropSupported(),true)
    }

    @TestCase
    func t2(): Unit {
        var rgb = RGBLuminanceSource(2, 2, Array<Int64>([5, 9, 45, 7]))
        var bin = GlobalHistogramBinarizer(rgb)
        var source = BinaryBitmap(bin)
        var flag = false
        try {
            source.rotateCounterClockwise45()
        } catch (e: Exception) {
            flag = true
        }
        @Assert(flag,true)
    }

    @TestCase
    func t3(): Unit {
        var rgb = RGBLuminanceSource(2, 2, Array<Int64>([5, 9, 45, 7]))
        var bin = GlobalHistogramBinarizer(rgb)
        var source = BinaryBitmap(bin)
        var flag = false
        try {
            source.toString()
        } catch (e: Exception) {
            flag = true
        }
        @Assert(flag,true)
    }

    @TestCase
    func t4(): Unit {
        var matrix: BitMatrix = BitMatrix.parse(
            UTF32String(
                "X X X X X     X X X       X X X     X X X     \n" + "X X X     X X X     X X X X     X X X     X X \n" +
                "  X   X X       X   X   X X X X     X     X X \n" + "  X   X X     X X     X     X   X       X   X \n" +
                "  X X   X X         X               X X     X \n" + "  X X   X X X X X X X X X X X X X X X     X   \n" +
                "  X X X X X                       X   X X X   \n" + "  X   X   X   X X X X X X X X X   X X X   X X \n" +
                "  X   X X X   X               X   X X       X \n" + "  X X   X X   X   X X X X X   X   X X X X   X \n" +
                "  X X   X X   X   X       X   X   X   X X X   \n" + "  X   X   X   X   X   X   X   X   X   X   X   \n" +
                "  X X X   X   X   X       X   X   X X   X X   \n" + "  X X X X X   X   X X X X X   X   X X X   X X \n" +
                "X X   X X X   X               X   X   X X   X \n" + "  X       X   X X X X X X X X X   X   X     X \n" +
                "  X X   X X                       X X   X X   \n" + "  X X X   X X X X X X X X X X X X X X   X X   \n" +
                "X     X     X     X X   X X               X X \n" + "X   X X X X X   X X X X X     X   X   X     X \n" +
                "X X X   X X X X           X X X       X     X \n" + "X X     X X X     X X X X     X X X     X X   \n" +
                "    X X X     X X X       X X X     X X X X   \n"),
            UTF32String("X "),
            UTF32String("  ")
        )
        var mrd = MonochromeRectangleDetector(matrix)
        var flag = false
        try {
            mrd.detect()
        } catch (e: Exception) {
            flag = true
        }
        @Assert(flag,true)
    }

    @TestCase
    func t5(): Unit {
        var row = DecoderResult(Array<UInt8>(), "text: String", ArrayList<Array<UInt8>>(), "ecLevel: String", 1, 1)
        row.getErrorsCorrected()
        row.getStructuredAppendParity()
        row.getStructuredAppendSequenceNumber()
        @Assert(row.getErasures(),0)
    }

    @TestCase
    func t6(): Unit {
        var dim = Dimension(120, 120)
        var dim2 = Dimension(12, 12)
        @Assert(dim.hashCode(),3925680)
        @Assert(dim.toString()," 120 x 120")
        @Assert(dim.equals(dim2),false)
    }

    @TestCase
    func t7(): Unit {
        var t1 = ResultMetadataType.OTHER
        var t2 = ResultMetadataType.ORIENTATION
        @Assert(t1 == t2,false)
        @Assert(t1 != t2,true)
        var t3 = ResultMetadataType.BYTE_SEGMENTS
        var t4 = ResultMetadataType.ERROR_CORRECTION_LEVEL
        var t5 = ResultMetadataType.ISSUE_NUMBER
        var t6 = ResultMetadataType.SUGGESTED_PRICE
        var t7 = ResultMetadataType.POSSIBLE_COUNTRY
        var t8 = ResultMetadataType.UPC_EAN_EXTENSION
        var t9 = ResultMetadataType.PDF417_EXTRA_METADATA
        var t10 = ResultMetadataType.STRUCTURED_APPEND_SEQUENCE
        var t11 = ResultMetadataType.STRUCTURED_APPEND_PARITY
        var t12 = ResultMetadataType.SYMBOLOGY_IDENTIFIER
        @Assert(t1.toString(),"OTHER")
        @Assert(t2.toString(),"ORIENTATION")
        @Assert(t3.toString(),"BYTE_SEGMENTS")
        @Assert(t4.toString(),"ERROR_CORRECTION_LEVEL")
        @Assert(t5.toString(),"ISSUE_NUMBER")
        @Assert(t6.toString(),"SUGGESTED_PRICE")
        @Assert(t7.toString(),"POSSIBLE_COUNTRY")
        @Assert(t8.toString(),"UPC_EAN_EXTENSION")
        @Assert(t9.toString(),"PDF417_EXTRA_METADATA")
        @Assert(t10.toString(),"STRUCTURED_APPEND_SEQUENCE")
        @Assert(t11.toString(),"STRUCTURED_APPEND_PARITY")
        @Assert(t12.toString(),"SYMBOLOGY_IDENTIFIER")
    }

    @TestCase
    func t8(): Unit {
        var t1 = ResultMetadataType.OTHER
        @Assert(t1.valueOf("OTHER"),ResultMetadataType.OTHER)
        @Assert(t1.valueOf("ORIENTATION"),ResultMetadataType.ORIENTATION)
        @Assert(t1.valueOf("BYTE_SEGMENTS"),ResultMetadataType.BYTE_SEGMENTS)
        @Assert(t1.valueOf("ERROR_CORRECTION_LEVEL"),ResultMetadataType.ERROR_CORRECTION_LEVEL)
        @Assert(t1.valueOf("ISSUE_NUMBER"),ResultMetadataType.ISSUE_NUMBER)
        @Assert(t1.valueOf("SUGGESTED_PRICE"),ResultMetadataType.SUGGESTED_PRICE)
        @Assert(t1.valueOf("POSSIBLE_COUNTRY"),ResultMetadataType.POSSIBLE_COUNTRY)
        @Assert(t1.valueOf("UPC_EAN_EXTENSION"),ResultMetadataType.UPC_EAN_EXTENSION)
        @Assert(t1.valueOf("PDF417_EXTRA_METADATA"),ResultMetadataType.PDF417_EXTRA_METADATA)
        @Assert(t1.valueOf("STRUCTURED_APPEND_SEQUENCE"),ResultMetadataType.STRUCTURED_APPEND_SEQUENCE)
        @Assert(t1.valueOf("STRUCTURED_APPEND_PARITY"),ResultMetadataType.STRUCTURED_APPEND_PARITY)
        @Assert(t1.valueOf("SYMBOLOGY_IDENTIFIER"),ResultMetadataType.SYMBOLOGY_IDENTIFIER)
    }

    @TestCase
    func t9(): Unit {
        var t1 = MyCharset.forName("ISO-8859-6")
        var t2 = MyCharset.forName("ISO-8859-8")
        var t3 = MyCharset.forName("ISO-8859-10")
        var t4 = MyCharset.forName("ISO-8859-14")
        var t5 = MyCharset.forName("Charsets.BIG5")
        var t6 = MyCharset.forName("EUC_KR")
        var t7 = MyCharset.forName("ISO-8859-60")
        var characterSetECI: CharacterSetECI = CharacterSetECI.getCharacterSetECIByValue(1)
        @Assert(characterSetECI.name(),"ISO-8859-1")



    }
}
