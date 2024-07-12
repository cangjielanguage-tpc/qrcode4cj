/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package aztec.encoder

import common.BitMatrix

public class AztecCode {
    private var compact: Bool = false;
    private var size: Int64 = 0;
    private var layers: Int64 = 0;
    private var codeWords: Int64 = 0;
    private var matrix: BitMatrix = BitMatrix();

    public func isCompact(): Bool {
        return compact
    }

    public func setCompact(compact: Bool) {
        this.compact = compact
    }

    /**
     * @return size in pixels (width and height)
     */
    public func getSize(): Int64 {
        return size
    }

    public func setSize(size: Int64) {
        this.size = size
    }

    /**
     * @return number of levels
     */
    public func getLayers(): Int64 {
        return layers
    }

    public func setLayers(layers: Int64) {
        this.layers = layers
    }

    /**
     * @return number of data codewords
     */
    public func getCodeWords(): Int64 {
        return codeWords
    }

    public func setCodeWords(codeWords: Int64) {
        this.codeWords = codeWords
    }

    /**
     * @return the symbol image
     */
    public func getMatrix(): BitMatrix {
        return matrix
    }

    public func setMatrix(matrix: BitMatrix) {
        this.matrix = matrix
    }
}
