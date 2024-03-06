/*
 * Copyright (C) 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
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

/*
 * These authors would like to acknowledge the Spanish Ministry of Industry,
 * Tourism and Trade, for the support in the project TSI020301-2008-2
 * "PIRAmIDE: Personalizable Interactions with Resources on AmI-enabled
 * Mobile Dynamic Environments", led by Treelogic
 * ( http://www.treelogic.com/ ):
 *
 * http://www.piramidepse.com/
 */

class TestCaseUtil {
    private TestCaseUtil() {}

    private static func getBufferedImage(pathin: String, name: String): ImageI {
        var path = AbstractBlackBoxTestCase.buildTestBase(pathin).join(name)

        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(path.toString())

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()
        return imagei
    }

    static func getBinaryBitmap(path: String, name: String): BinaryBitmap {
        var imagei: ImageI = getBufferedImage(path, name)
        var luminanceSource: BufferedImageLuminanceSource = BufferedImageLuminanceSource(imagei)

        var binaryMap: BinaryBitmap = BinaryBitmap(GlobalHistogramBinarizer(luminanceSource))

        return binaryMap
    }
}
