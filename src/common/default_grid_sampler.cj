/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.common

//import *
public class DefaultGridSampler <: GridSampler {
    public func sampleGrid(
        image: BitMatrix,
        dimensionX: Int64,
        dimensionY: Int64,
        p1ToX: Float64,
        p1ToY: Float64,
        p2ToX: Float64,
        p2ToY: Float64,
        p3ToX: Float64,
        p3ToY: Float64,
        p4ToX: Float64,
        p4ToY: Float64,
        p1FromX: Float64,
        p1FromY: Float64,
        p2FromX: Float64,
        p2FromY: Float64,
        p3FromX: Float64,
        p3FromY: Float64,
        p4FromX: Float64,
        p4FromY: Float64
    ): BitMatrix {
        let transform = PerspectiveTransform.quadrilateralToQuadrilateral(
            p1ToX,
            p1ToY,
            p2ToX,
            p2ToY,
            p3ToX,
            p3ToY,
            p4ToX,
            p4ToY,
            p1FromX,
            p1FromY,
            p2FromX,
            p2FromY,
            p3FromX,
            p3FromY,
            p4FromX,
            p4FromY
        )
        sampleGrid(image, dimensionX, dimensionY, transform)
    }

    public func sampleGrid(
        image: BitMatrix,
        dimensionX: Int64,
        dimensionY: Int64,
        transform: PerspectiveTransform
    ): BitMatrix {
        if (dimensionX <= 0 || dimensionY <= 0) {
            throw Qrcoder4cjNotFoundException()
        }
        let bits = BitMatrix(dimensionX, dimensionY)
        let points: Array<Float64> = Array<Float64>(2 * dimensionX, repeat: 0.0)
        for (y in 0..dimensionY) {
            let iValue = Float64(y) + 0.5
            for (x in 0..points.size : 2) {
                points[x] = Float64(x / 2) + 0.5
                points[x + 1] = iValue
            }
            transform.transformPoints(points)

            // Quick check to see if points transformed to something inside the image;
            // sufficient to check the endpoints
            checkAndNudgePoints(image, points)
            try {
                for (x in 0..points.size : 2) {
                    if (image.get(Int64(points[x]), Int64(points[x + 1]))) {
                        bits.set(x / 2, y)
                    }
                }
            } catch (e: Exception) {
                // This feels wrong, but, sometimes if the finder patterns are misidentified, the resulting
                // transform gets "twisted" such that it maps a straight line of points to a set of points
                // whose endpoints are in bounds, but others are not. There is probably some mathematical
                // way to detect this about the transformation that I don't know yet.
                // This results in an ugly runtime exception despite our clever checks above -- can't have
                // that. We could check each point's coordinates but that feels duplicative. We settle for
                // catching and wrapping ArrayIndexOutOfBoundsException.
                throw Qrcoder4cjNotFoundException.getNotFoundInstance()
            }
        }

        bits
    }
}
