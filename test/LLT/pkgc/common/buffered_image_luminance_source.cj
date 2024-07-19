public open class BufferedImageLuminanceSource <: LuminanceSource {
    private static let MINUS_45_IN_RADIANS: Float64 = -0.7853981633974483

    private var image: ImageI = Gray_p()
    private let left: Int64
    private let top: Int64

    public init(image: ImageI) {
        this(image, 0, 0, image.bounds().size().x, image.bounds().size().y);
    }

    @OverflowWrapping
    public init(imagein: ImageI, left: Int64, top: Int64, width: Int64, height: Int64) {
        super(width, height);
        if (imagein.colorModel() == GrayModel) {
            this.image = imagein
        } else {
            var sourceWidth: Int64 = imagein.bounds().size().x
            var sourceHeight: Int64 = imagein.bounds().size().y
            if (left + width > sourceWidth || top + height > sourceHeight) {
                throw IllegalArgumentException("Crop rectangle does not fit within image data.");
            }
            let rectangle: Rectangle_p = Rectangle_p(left, top, width, height)
            var gray: Gray_p = Gray_p(rectangle)

            for (y in top..top + height) {
                for (x in 0..width) {
                    let colorin: Color = imagein.at(x, y)

                    let (a1, a2, a3, a4) = colorin.rgba();

                    if (a4 == 0) {
                        gray.setGray(x, y - top, GrayC(255))
                    } else {
                        if (imagein is RGBA) {
                            let colorRGB: Color = (imagein as RGBA_p).getOrThrow().rgbaAt(x, y)
                            let coloritem = (colorRGB as RGBAC).getOrThrow();
                            gray.set(
                                x,
                                y - top,
                                GrayC(
                                    UInt8((Int64(coloritem.r) * 306 + Int64(coloritem.g) * 601 + Int64(coloritem.b) * 117 +
                                            0x200) >> 10)
                                )
                            )
                        } else {
                            gray.set(x, y - top, colorin)
                        }
                    }
                }
            }
            this.image = gray
        }
        this.left = left
        this.top = top
    }

    public override func getRow(y: Int64, rowin: Array<UInt8>): Array<UInt8> {
        var row: Array<UInt8> = rowin
        if (y < 0 || y >= getHeight()) {
            throw IllegalArgumentException("Requested row is outside the image: ${y}");
        }
        var width: Int64 = getWidth();
        if (row.size == 0 || row.size < width) {
            row = Array<UInt8>(width, item: 0)
        }

        let dstImg = crop(image, width, 1, cropX: left, cropY: top + y)

        for (x in 0..width) {
            var colors: GrayC = (grayModel(dstImg.at(x, top + y)) as GrayC).getOrThrow()
            row[x] = colors.y
        }
        return row
    }

    public override func getMatrix(): Array<UInt8> {
        var width: Int64 = getWidth();
        var height: Int64 = getHeight();
        var area: Int64 = width * height
        var matrix: Array<UInt8> = Array<UInt8>(area, item: 0)

        // The underlying raster of image consists of area bytes with the luminance values
        let dstImg = crop(image, width, height, cropX: left, cropY: top)

        for (x in 0..width) {
            for (y in 0..height) {
                var colors: GrayC = (grayModel(image.at(x + left, top + y)) as GrayC).getOrThrow()
                matrix[x + y * width] = colors.y
            }
        }

        return matrix
    }

    public override func isCropSupported(): Bool {
        return true;
    }

    public override func crop(left: Int64, top: Int64, width: Int64, height: Int64): LuminanceSource {
        return BufferedImageLuminanceSource(image, this.left + left, this.top + top, width, height);
    }

    /**
     * This is always true, since the image is a gray-scale image.
     *
     * @return true
     */
    public override func isRotateSupported(): Bool {
        return true;
    }

    public override func rotateCounterClockwise(): LuminanceSource {
        var sourceWidth: Int64 = image.bounds().size().x
        var sourceHeight: Int64 = image.bounds().size().y
        var imageI: ImageI = this.image
        let rotatedImage = AbstractBlackBoxTestCase.selfrotate(imageI, 270)

        // Maintain the cropped region, but rotate it too.
        var width: Int64 = getWidth();
        return BufferedImageLuminanceSource(rotatedImage, top, sourceWidth - (left + width), getHeight(), width);
    }

    public override func rotateCounterClockwise45(): LuminanceSource {
        var width: Int64 = getWidth();
        var height: Int64 = getHeight();

        var oldCenterX: Int64 = left + width / 2
        var oldCenterY: Int64 = top + height / 2

        let rotatedImage = rotate(this.image, 45)
        var sourceDimension: Int64 = max(this.image.bounds().size().x, this.image.bounds().size().y);
        var halfDimension: Int64 = max(width, height) / 2
        var newLeft: Int64 = max(0, oldCenterX - halfDimension);
        var newTop: Int64 = max(0, oldCenterY - halfDimension);
        var newRight: Int64 = min(sourceDimension - 1, oldCenterX + halfDimension);
        var newBottom: Int64 = min(sourceDimension - 1, oldCenterY + halfDimension);

        return BufferedImageLuminanceSource(rotatedImage, newLeft, newTop, newRight - newLeft, newBottom - newTop);
    }
}
