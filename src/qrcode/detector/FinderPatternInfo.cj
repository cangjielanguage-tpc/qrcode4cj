/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package qrcode.detector

/**
 * <p>Encapsulates information about finder patterns in an image, including the location of
 * the three finder patterns, and their estimated module size.</p>
 *
 * @author Sean Owen
 */
public class FinderPatternInfo {
    private var bottomLeft: FinderPattern
    private var topLeft: FinderPattern
    private var topRight: FinderPattern

    public init(patternCenters: Array<FinderPattern>) {
        this.bottomLeft = patternCenters[0]
        this.topLeft = patternCenters[1]
        this.topRight = patternCenters[2]
    }

    public func getBottomLeft(): FinderPattern {
        return bottomLeft
    }

    public func getTopLeft(): FinderPattern {
        return topLeft
    }

    public func getTopRight(): FinderPattern {
        return topRight
    }
}
