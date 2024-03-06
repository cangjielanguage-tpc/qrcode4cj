from std import format.*

public class BitMatrixTestCase {
    private static let BIT_MATRIX_POINTS = [1, 2, 2, 0, 3, 1]

    public static func matrixToString(result: BitMatrix): String {
        @Assert(1, result.getHeight())
        var builder: StringBuilder = StringBuilder();
        for (i in 0..result.getWidth()) {
            builder.append(
                if (result.get(i, 0)) {
                    "1"
                } else {
                    "0"
                }
            );
        }
        return builder.toString();
    }

    private func testXOR(dataMatrix: BitMatrix, flipMatrix: BitMatrix, expectedMatrix: BitMatrix) {
        var matrix: BitMatrix = dataMatrix.clone();
        matrix.xor(flipMatrix);

        assertEqual("expectedMatrix", "matrix", expectedMatrix, matrix)
    }

    public func testRotate180(width: Int64, height: Int64) {
        var input: BitMatrix = getInput(width, height);
        input.rotate180();
        var expected: BitMatrix = getExpected(width, height);

        for (y in 0..height) {
            for (x in 0..width) {
                @Assert(expected.get(x, y), input.get(x, y))
            }
        }
    }

    private static func getExpected(width: Int64, height: Int64): BitMatrix {
        var result: BitMatrix = BitMatrix(width, height);

        var i: Int64 = 0;
        while (i < BIT_MATRIX_POINTS.size) {
            result.set(width - 1 - BIT_MATRIX_POINTS[i], height - 1 - BIT_MATRIX_POINTS[i + 1]);
            i += 2
        }
        return result
    }

    private static func getInput(width: Int64, height: Int64): BitMatrix {
        var result: BitMatrix = BitMatrix(width, height);

        var i: Int64 = 0;
        while (i < BIT_MATRIX_POINTS.size) {
            result.set(BIT_MATRIX_POINTS[i], BIT_MATRIX_POINTS[i + 1]);
            i += 2
        }
        return result
    }

    private static func arrayToString(data: Array<Int64>): String {
        var sb: StringBuilder = StringBuilder("{");

        for (i in 0..data.size) {
            if (i > 0) {
                sb.append(",");
            }
            sb.append(data[i].format("X"))
        }
        return sb.append('}').toString();
    }
}
