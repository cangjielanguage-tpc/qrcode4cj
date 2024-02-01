/*
 * Copyright 2006 Jeremias Maerki
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

from std import collection.*

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
