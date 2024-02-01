/*
 * Copyright 2008 ZXing authors
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

package zxing.code.qrcode.encoder

import zxing.code.qrcode.decoder.ErrorCorrectionLevel
import zxing.code.qrcode.decoder.Mode
import zxing.code.qrcode.decoder.Version

/**
 * @author satorux@google.com (Satoru Takabayashi) - creator
 * @author dswitkin@google.com (Daniel Switkin) - ported from C++
 */
public class QRCode {
    public static let NUM_MASK_PATTERNS: Int64 = 8;

    private var mode: Mode = TERMINATOR([0, 0, 0], 0x00);
    private var ecLevel: ErrorCorrectionLevel = ErrorCorrectionLevel.M(0x00);
    private var version: ?Version = None
    private var maskPattern: Int64 = 0;
    private var matrix: ?ByteMatrix = None

    public init() {
        maskPattern = -1
    }

    /**
     * @return the mode. Not relevant if {@link com.google.zxing.EncodeHintType#QR_COMPACT} is selected.
     */
    public func getMode(): Mode {
        return mode
    }

    public func getECLevel(): ErrorCorrectionLevel {
        return ecLevel
    }

    public func getVersion(): Version {
        return version.getOrThrow();
    }

    public func getMaskPattern(): Int64 {
        return maskPattern
    }

    public func getMatrix(): ByteMatrix {
        return matrix.getOrThrow();
    }

    public func toString(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        result.appendAll("<<\n".toRuneArray());
        result.appendAll(" mode: ".toRuneArray());
        if (mode == Mode.TERMINATOR([0, 0, 0], 0x00)) {
            result.appendAll("null".toRuneArray());
        } else {
            result.appendAll(mode.toString().toRuneArray());
        }
        result.appendAll("\n ecLevel: ".toRuneArray());
        result.appendAll(ecLevel.toString().toRuneArray());
        if (let Some(v) <- version) {
            result.appendAll("\n version: ".toRuneArray());
            result.appendAll(v.toString().toRuneArray());
        } else {
            result.appendAll("\n version: null".toRuneArray());
        }

        result.appendAll("\n maskPattern: ".toRuneArray());
        result.appendAll(maskPattern.toString().toRuneArray());
        if (let Some(m) <- matrix) {
            result.appendAll("\n matrix:\n".toRuneArray());
            result.appendAll(m.toString().toRuneArray());
        } else {
            result.appendAll("\n matrix: null\n".toRuneArray());
        }
        result.appendAll(">>\n".toRuneArray());
        return String(result);
    }

    public func setMode(value: Mode) {
        mode = value
    }

    public func setECLevel(value: ErrorCorrectionLevel) {
        ecLevel = value
    }

    public func setVersion(version: Version) {
        this.version = version
    }

    public func setMaskPattern(value: Int64) {
        maskPattern = value
    }

    public func setMatrix(value: ByteMatrix) {
        matrix = value
    }

    // Check if "mask_pattern" is valid.
    public static func isValidMaskPattern(maskPattern: Int64): Bool {
        return maskPattern >= 0 && maskPattern < NUM_MASK_PATTERNS
    }
}
