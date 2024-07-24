import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.regex.*
import std.collection.*
import std.convert.*
import std.fs.*
import std.log.*
import std.os.posix.*
import QRCode4cj.tools.UTF32String
import QRCode4cj.common.*
import std.unittest.*
import std.unittest.testmacro.*

public class BinaryUtil {
    private static let ONE: Regex = Regex("1");
    private static let ZERO: Regex = Regex("0");
    private static let SPACE: Regex = Regex(" ");

    private func BinaryUtil() {}

    /*
     * Constructs a BitArray from a String like the one returned from BitArray.toString()
     */
    public static func buildBitArrayFromString(data: String): BitArray {
        var dotsAndXs: String = ZERO.matcher(ONE.matcher(data).replaceAll("X")).replaceAll(".");
        var dotsAndXsUtf = UTF32String(dotsAndXs)
        var binary: BitArray = BitArray(SPACE.matcher(dotsAndXs).replaceAll("").size);
        var counter: Int64 = 0;

        for (i in 0..dotsAndXsUtf.charSize) {
            if (i % 9 == 0) { // spaces
                if (dotsAndXsUtf.get(i) != r' ') {
                    throw Exception("space expected");
                }
                continue
            }

            var currentChar: Rune = dotsAndXsUtf.get(i);
            if (currentChar == r'X' || currentChar == r'x') {
                binary.set(counter);
            }
            counter++
        }
        return binary
    }

    public static func buildBitArrayFromStringWithoutSpaces(data: String): BitArray {
        var sb: ArrayList<Rune> = ArrayList<Rune>();
        var dotsAndXs: UTF32String = UTF32String(ZERO.matcher(ONE.matcher(data).replaceAll("X")).replaceAll("."));
        var current: Int64 = 0;
        while (current < dotsAndXs.charSize) {
            sb.append(r' ');
            for (i in 0..8 where current < dotsAndXs.charSize) {
                sb.append(dotsAndXs.get(current));
                current++
            }
        }
        return buildBitArrayFromString(String(sb));
    }
}
