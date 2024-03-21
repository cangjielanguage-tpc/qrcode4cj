/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

/**
 * This object renders a ITF code as a {@link BitMatrix}.
 */
public open class ITFWriter <: OneDimensionalCodeWriter {
    private static let START_PATTERN: Array<Int64> = [1, 1, 1, 1]
    private static let END_PATTERN: Array<Int64> = [3, 1, 1]

    private static let W: Int64 = 3; // Pixel width of a 3x wide line
    private static let N: Int64 = 1; // Pixed width of a narrow line

    // See ITFReader.PATTERNS
    private static let PATTERNS: Array<Array<Int64>> = [
        [N, N, W, W, N], // 0
        [W, N, N, N, W], // 1
        [N, W, N, N, W], // 2
        [W, W, N, N, N], // 3
        [N, N, W, N, W], // 4
        [W, N, W, N, N], // 5
        [N, W, W, N, N], // 6
        [N, N, N, W, W], // 7
        [W, N, N, W, N], // 8
        [N, W, N, W, N] // 9
    ]

    protected override func getSupportedWriteFormats(): ArrayList<BarcodeFormat> {
        var returnData: ArrayList<BarcodeFormat> = ArrayList<BarcodeFormat>()
        returnData.append(BarcodeFormat.ITF)
        return returnData
    }

    public override func encode(contents: String): Array<Bool> {
        var contestsutf32 = UTF32String(contents)

        var length: Int64 = contestsutf32.charSize;

        if (length % 2 != 0) {
            throw IllegalArgumentException("The length of the input should be even");
        }
        if (length > 80) {
            throw IllegalArgumentException("Requested contents should be less than 80 digits long, but got ${length}");
        }

        checkNumeric(contents);

        var result: Array<Bool> = Array<Bool>(9 + 9 * length, item: false);
        var pos: Int64 = appendPattern(result, 0, START_PATTERN, true);
        var i: Int64 = 0

        while (i < length) {
            var one: Int64 = -1
            if (contestsutf32.get(i).isAsciiNumber()) {
                one = contestsutf32.get(i).hashCode() - 48
            }
            var two: Int64 = -1
            if (contestsutf32.get(i + 1).isAsciiNumber()) {
                two = contestsutf32.get(i + 1).hashCode() - 48
            }

            var encoding: Array<Int64> = Array<Int64>(10, item: 0)
            for (j in 0..5) {
                encoding[2 * j] = PATTERNS[one][j]
                encoding[2 * j + 1] = PATTERNS[two][j]
            }
            pos += appendPattern(result, pos, encoding, true)
            i = i + 2
        }
        appendPattern(result, pos, END_PATTERN, true);

        return result
    }
}
