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
// import pkgc.oned.rss.expanded.*
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion

abstract class AbstractDecoderTest {
    static let numeric10: String = "..X..XX";
    static let numeric12: String = "..X.X.X";
    static let numeric1FNC1: String = "..XXX.X";

    // static let String numericFNC11                  = "XXX.XXX";
    static let numeric2alpha: String = "....";

    static let alphaA: String = "X.....";
    static let alphaFNC1: String = ".XXXX";
    static let alpha2numeric: String = "...";
    static let alpha2isoiec646: String = "..X..";

    static let i646B: String = "X.....X";
    static let i646C: String = "X....X.";
    static let i646FNC1: String = ".XXXX";
    static let isoiec6462alpha: String = "..X..";

    static let compressedGtin900123456798908: String = ".........X..XXX.X.X.X...XX.XXXXX.XXXX.X.";
    static let compressedGtin900000000000008: String = "........................................";

    static let compressed15bitWeight1750: String = "....XX.XX.X.XX.";
    static let compressed15bitWeight11750: String = ".X.XX.XXXX..XX.";
    static let compressed15bitWeight0: String = "...............";

    static let compressed20bitWeight1750: String = ".........XX.XX.X.XX.";

    static let compressedDateMarch12th2010: String = "....XXXX.X..XX..";
    static let compressedDateEnd: String = "X..X.XX.........";

    static func assertCorrectBinaryString(binaryString: String, expectedNumber: String) {
        try {
            var binary: BitArray = BinaryUtil.buildBitArrayFromStringWithoutSpaces(binaryString);
            var decoder: AbstractExpandedDecoder = AbstractExpandedDecoder.createDecoder(binary);
            var result: String = decoder.parseInformation();
            @Expect(expectedNumber, result)
        } catch (re: Qrcoder4cjNotFoundException) {
            @Expect("Qrcoder4cjNotFoundException: ", re.toString())
        }
    }
}
