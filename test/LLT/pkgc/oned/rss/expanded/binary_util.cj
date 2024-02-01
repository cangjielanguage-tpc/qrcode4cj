/*
 * Copyright (C) 2010 ZXing authors
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

/*
 * These authors would like to acknowledge the Spanish Ministry of Industry,
 * Tourism and Trade, for the support in the project TSI020301-2008-2
 * "PIRAmIDE: Personalizable Interactions with Resources on AmI-enabled
 * Mobile Dynamic Environments", led by Treelogic
 * ( http://www.treelogic.com/ ):
 *
 * http://www.piramidepse.com/
 */

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */
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
                if (dotsAndXsUtf.get(i) != ' ') {
                    throw Exception("space expected");
                }
                continue
            }

            var currentChar: Char = dotsAndXsUtf.get(i);
            if (currentChar == 'X' || currentChar == 'x') {
                binary.set(counter);
            }
            counter++
        }
        return binary
    }

    public static func buildBitArrayFromStringWithoutSpaces(data: String): BitArray {
        var sb: ArrayList<Char> = ArrayList<Char>();
        var dotsAndXs: UTF32String = UTF32String(ZERO.matcher(ONE.matcher(data).replaceAll("X")).replaceAll("."));
        var current: Int64 = 0;
        while (current < dotsAndXs.charSize) {
            sb.append(' ');
            for (i in 0..8 where current < dotsAndXs.charSize) {
                sb.append(dotsAndXs.get(current));
                current++
            }
        }
        return buildBitArrayFromString(String(sb));
    }
}
