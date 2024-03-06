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
 * <p>See ISO 18004:2006, 6.5.1. This enum encapsulates the four error correction levels
 * defined by the QR code standard.</p>
 *
 * @author Sean Owen
 */
let FOR_BITS: Array<ErrorCorrectionLevel> = [M(0x00), L(0x01), H(0x02), Q(0x03)]

public enum ErrorCorrectionLevel <: Equatable<ErrorCorrectionLevel> & ToString {
    /** L = ~7% correction */
    | L(Int32)
    /** M = ~15% correction */
    | M(Int32)
    /** Q = ~25% correction */
    | Q(Int32)
    /** H = ~30% correction */
    | H(Int32)

    public func ToInt(): Int32 {
        match (this) {
            case L(x) => 0x01;
            case M(x) => 0x00;
            case Q(x) => 0x03;
            case H(x) => 0x02;
        }
    }

    public func ordinal(): Int64 {
        match (this) {
            case L(x) => 0;
            case M(x) => 1;
            case Q(x) => 2;
            case H(x) => 3;
        }
    }

    public func getBits(): Int32 {
        match (this) {
            case L(x) => x
            case M(x) => x
            case Q(x) => x
            case H(x) => x
        }
    }

    /**
     * @param bits int containing the two bits encoding a QR Code's error correction level
     * @return ErrorCorrectionLevel representing the encoded error correction level
     */
    public static func forBits(bits: Int64): ErrorCorrectionLevel {
        if (bits < 0 || bits >= FOR_BITS.size) {
            throw IllegalArgumentException();
        }
        return FOR_BITS[bits]
    }

    public operator func ==(rhs: ErrorCorrectionLevel): Bool {
        if (this.ordinal() == rhs.ordinal()) {
            return true;
        } else {
            return false;
        }
    }

    public operator func !=(rhs: ErrorCorrectionLevel): Bool {
        if (this.ordinal() != rhs.ordinal()) {
            return true;
        } else {
            return false;
        }
    }

    public func toString(): String {
        match (this) {
            case M(x) => "M";
            case L(x) => "L";
            case H(x) => "H";
            case Q(x) => "Q";
        }
    }

    public static func valueOf(str: String): ErrorCorrectionLevel {
        match (str) {
            case "M" => return ErrorCorrectionLevel.M(0x00);
            case "L" => return ErrorCorrectionLevel.L(0x01);
            case "H" => return ErrorCorrectionLevel.H(0x02);
            case "Q" => return ErrorCorrectionLevel.Q(0x03);
            case _ => throw IllegalArgumentException();
        }
    }
}
