/*
 * Copyright 2007 ZXing authors
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

package zxing.code.qrcode.decoder

/**
 * <p>Encapsulates data masks for the data bits in a QR code, per ISO 18004:2006 6.8. Implementations
 * of this class can un-mask a raw BitMatrix. For simplicity, they will unmask the entire BitMatrix,
 * including areas used for finder patterns, timing patterns, etc. These areas should be unused
 * after the point they are unmasked anyway.</p>
 *
 * <p>Note that the diagram in section 6.8.1 is misleading since it indicates that i is column position
 * and j is row position. In fact, as the text says, i is row position and j is column position.</p>
 *
 * @author Sean Owen
 */
let DataMasks = [
    DataMask.DATA_MASK_000,
    DataMask.DATA_MASK_001,
    DataMask.DATA_MASK_010,
    DataMask.DATA_MASK_011,
    DataMask.DATA_MASK_100,
    DataMask.DATA_MASK_101,
    DataMask.DATA_MASK_110,
    DataMask.DATA_MASK_111
]

public enum DataMask {
    // See ISO 18004:2006 6.8.1
    | DATA_MASK_000
    | DATA_MASK_001
    | DATA_MASK_010
    | DATA_MASK_011
    | DATA_MASK_100
    | DATA_MASK_101
    | DATA_MASK_110
    | DATA_MASK_111

    // End of enum constants.

    /**
     * <p>Implementations of this method reverse the data masking process applied to a QR Code and
     * make its bits ready to read.</p>
     *
     * @param bits representation of QR Code bits
     * @param dimension dimension of QR Code, represented by bits, being unmasked
     */
    public func unmaskBitMatrix(bits: BitMatrix, dimension: Int64) {
        for (i in 0..dimension) {
            for (j in 0..dimension) {
                if (isMasked(i, j)) {
                    bits.flip(j, i);
                }
            }
        }
    }

    public func isMasked(i: Int64, j: Int64): Bool {
        let maskResult: Bool = match (this) {
            /**
             * 000: mask bits for which (x + y) mod 2 == 0
             */
            case DATA_MASK_000 => return ((i + j) & 0x01) == 0

            /**
             * 001: mask bits for which x mod 2 == 0
             */
            case DATA_MASK_001 => return (i & 0x01) == 0

            /**
             * 010: mask bits for which y mod 3 == 0
             */
            case DATA_MASK_010 => return j % 3 == 0

            /**
             * 011: mask bits for which (x + y) mod 3 == 0
             */
            case DATA_MASK_011 => return (i + j) % 3 == 0

            /**
             * 100: mask bits for which (x/2 + y/3) mod 2 == 0
             */
            case DATA_MASK_100 => return (((i / 2) + (j / 3)) & 0x01) == 0

            /**
             * 101: mask bits for which xy mod 2 + xy mod 3 == 0
             * equivalently, such that xy mod 6 == 0
             */
            case DATA_MASK_101 => return (i * j) % 6 == 0

            /**
             * 110: mask bits for which (xy mod 2 + xy mod 3) mod 2 == 0
             * equivalently, such that xy mod 6 < 3
             */
            case DATA_MASK_110 => return ((i * j) % 6) < 3

            /**
             * 111: mask bits for which ((x+y)mod 2 + xy mod 3) mod 2 == 0
             * equivalently, such that (x + y + xy mod 3) mod 2 == 0
             */
            case DATA_MASK_111 => return ((i + j + ((i * j) % 3)) & 0x01) == 0
        }

        return maskResult
    }

    public static func values(): Array<DataMask> {
        return DataMasks
    }
}
