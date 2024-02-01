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

from std import math.*

/**
 * <p>Encapsulates a QR Code's format information, including the data mask used and
 * error correction level.</p>
 *
 * @author Sean Owen
 * @see DataMask
 * @see ErrorCorrectionLevel
 */
public class FormatInformation <: Equatable<FormatInformation> & ToString {
    private static let FORMAT_INFO_MASK_QR: Int64 = 0x5412;

    /**
     * See ISO 18004:2006, Annex C, Table C.1
     */
    private static let FORMAT_INFO_DECODE_LOOKUP: Array<Array<Int64>> = [
        [0x5412, 0x00],
        [0x5125, 0x01],
        [0x5E7C, 0x02],
        [0x5B4B, 0x03],
        [0x45F9, 0x04],
        [0x40CE, 0x05],
        [0x4F97, 0x06],
        [0x4AA0, 0x07],
        [0x77C4, 0x08],
        [0x72F3, 0x09],
        [0x7DAA, 0x0A],
        [0x789D, 0x0B],
        [0x662F, 0x0C],
        [0x6318, 0x0D],
        [0x6C41, 0x0E],
        [0x6976, 0x0F],
        [0x1689, 0x10],
        [0x13BE, 0x11],
        [0x1CE7, 0x12],
        [0x19D0, 0x13],
        [0x0762, 0x14],
        [0x0255, 0x15],
        [0x0D0C, 0x16],
        [0x083B, 0x17],
        [0x355F, 0x18],
        [0x3068, 0x19],
        [0x3F31, 0x1A],
        [0x3A06, 0x1B],
        [0x24B4, 0x1C],
        [0x2183, 0x1D],
        [0x2EDA, 0x1E],
        [0x2BED, 0x1F]
    ]

    private var errorCorrectionLevel: ErrorCorrectionLevel = M(0);
    private var dataMask: UInt8 = 0;

    public init(formatInfo: Int64) {
        // Bits 3,4
        errorCorrectionLevel = ErrorCorrectionLevel.forBits(Int64(formatInfo >> 3) & 0x03)

        // Bottom 3 bits
        dataMask = UInt8(formatInfo & 0x07)
    }

    public static func numBitsDiffering(a: Int64, b: Int64): Int64 {
        return Int64(bitCount(Int32(a ^ b)))
    }

    public static func bitCount(v: Int32): Int32 {
        var i = v
        i = i - (Int32(UInt32(0xffffffffi64 & Int64(i)) >> 1) & 0x55555555)
        i = (i & 0x33333333) + (Int32(UInt32(0xffffffffi64 & Int64(i)) >> 2) & 0x33333333)
        i = (i + Int32(UInt32(0xffffffffi64 & Int64(i)) >> 4)) & 0x0f0f0f0f
        i = i + Int32(UInt32(0xffffffffi64 & Int64(i)) >> 8)
        i = i + Int32(UInt32(0xffffffffi64 & Int64(i)) >> 16)
        return i & 0x3f
    }

    /**
     * @param maskedFormatInfo1 format info indicator, with mask still applied
     * @param maskedFormatInfo2 second copy of same info; both are checked at the same time
     * to establish best match
     * @return information about the format it specifies, or {@code null}
     * if doesn't seem to match any known pattern
     */
    public static func decodeFormatInformation(maskedFormatInfo1: Int64, maskedFormatInfo2: Int64): ?FormatInformation {
        var formatInfo: Option<FormatInformation> = doDecodeFormatInformation(maskedFormatInfo1, maskedFormatInfo2);
        if (let Some(format) <- formatInfo) {
            return format
        }

        // Should return null, but, some QR codes apparently
        // do not mask this info. Try again by actually masking the pattern
        // first
        return doDecodeFormatInformation(
            maskedFormatInfo1 ^ FORMAT_INFO_MASK_QR,
            maskedFormatInfo2 ^ FORMAT_INFO_MASK_QR
        );
    }

    private static func doDecodeFormatInformation(maskedFormatInfo1: Int64, maskedFormatInfo2: Int64): Option<FormatInformation> {
        // Find the int in FORMAT_INFO_DECODE_LOOKUP with fewest bits differing
        var bestDifference: Int64 = Int64.Max;
        var bestFormatInfo: Int64 = 0;
        for (i in 0..FORMAT_INFO_DECODE_LOOKUP.size) {
            let targetInfo: Int64 = FORMAT_INFO_DECODE_LOOKUP[i][0]
            if (targetInfo == maskedFormatInfo1 || targetInfo == maskedFormatInfo2) {
                // Found an exact match
                return FormatInformation(FORMAT_INFO_DECODE_LOOKUP[i][1]);
            }
            var bitsDifference: Int64 = numBitsDiffering(maskedFormatInfo1, targetInfo);
            if (bitsDifference < bestDifference) {
                bestFormatInfo = FORMAT_INFO_DECODE_LOOKUP[i][1]
                bestDifference = bitsDifference
            }
            if (maskedFormatInfo1 != maskedFormatInfo2) {
                // also try the other option
                bitsDifference = numBitsDiffering(maskedFormatInfo2, targetInfo)
                if (bitsDifference < bestDifference) {
                    bestFormatInfo = FORMAT_INFO_DECODE_LOOKUP[i][1]
                    bestDifference = bitsDifference
                }
            }
        }

        // Hamming distance of the 32 masked codes is 7, by construction, so <= 3 bits
        // differing means we found a match
        if (bestDifference <= 3) {
            return FormatInformation(bestFormatInfo);
        }
        return None
    }

    public func getErrorCorrectionLevel(): ErrorCorrectionLevel {
        return errorCorrectionLevel
    }

    public func getDataMask(): UInt8 {
        return dataMask
    }

    public func hashCode(): UInt8 {
        return UInt8(errorCorrectionLevel.ordinal() << 3) | dataMask
    }

    public func equals(o: Any): Bool {
        if (let Some(other) <- o as FormatInformation) {
            return this.errorCorrectionLevel == other.errorCorrectionLevel && this.dataMask == other.dataMask
        } else {
            return false;
        }
    }

    public operator func ==(right: FormatInformation): Bool {
        return this.errorCorrectionLevel == right.errorCorrectionLevel && this.dataMask == right.dataMask
    }

    public operator func !=(right: FormatInformation): Bool {
        return this.errorCorrectionLevel != right.errorCorrectionLevel || this.dataMask != right.dataMask
    }

    public func toString(): String {
        return "FormatInformation";
    }
}
