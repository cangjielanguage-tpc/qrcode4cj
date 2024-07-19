import std.collection.*
import QRCode4cj.datamatrix.encoder.*

class DebugPlacement <: DefaultPlacement {
    init(codewords: String, numcols: Int64, numrows: Int64) {
        super(codewords, numcols, numrows);
    }

    func toBitFieldStringArray(): Array<String> {
        let bits: Array<Byte> = getBits();
        let numrows = getNumrows();
        let numcols = getNumcols();
        let array: Array<String> = Array<String>(numrows, item: String());
        var startpos = 0;
        for (row in 0..numrows) {
            let sb: StringBuilder = StringBuilder();
            for (i in 0..numcols) {
                if (bits[startpos + i] == 1) {
                    sb.append(1)
                } else {
                    sb.append(0)
                }
            }
            array[row] = sb.toString()
            startpos += numcols
        }
        return array
    }
}
