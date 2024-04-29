# QRCode4cj 库

### 介绍

生成/解析二维码或条码，支持相机扫码功能

### 1 支持生成/解析一维条码

场景：
1. 在多种场合需要使用某些特定的数据生成一维码来作为唯一标识；
2. 需要一维码扫描功能的场景，例如：
商品管理：一维码快速识别商品信息，对商品做库存控制；解码
物流追踪：扫描一维码实现包裹的追踪和管理。
会员卡管理、资产追踪、车票机票、餐饮服务、图书管理等
是否商用：是
目标：提供生成或解析多种格式的一维码，支持的格式包括：
一维码：UPC-A、UPC-E、EAN-8、EAN-13、RSS-14、RSS-Expanded、Code 39、Code 93、Code 128、Codabar、ITF

#### 1.1 生成、解析 codeBar

##### 1.1.1 主要接口
```cangjie
public open class CodaBarReader <: OneDReader {
    /*
     * 默认构造，构造一个 codeBar 一维码解码器
     */
    public init()

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
}

public open class CodaBarWriter <: OneDimensionalCodeWriter {
    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contentsin - 要编码的字符串
     * 返回值 Array<Bool> - 编码结果
     */
    public override func encode(contentsin: String): Array<Bool> 
}
```

#### 1.2 生成、解析 code128

##### 1.2.1 主要接口
```cangjie
public open class Code128Reader <: OneDReader {
    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
}

public open class Code128Writer <: OneDimensionalCodeWriter {
    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contentsin - 要编码的字符串
     * 返回值 Array<Bool> - 编码结果
     */
    public func encode(contents: String): Array<Bool>

    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contentsin - 要编码的字符串
     * 参数 hints - 编码参数配置
     * 返回值 Array<Bool> - 编码结果
     */
    public func encode(contents: String, hints: HashMap<EncodeHintType, Any>): Array<Bool>
}
```

#### 1.3 生成、解析 code39

##### 1.3.1 主要接口
```cangjie
public open class Code39Reader <: OneDReader {
    /*
     * 默认构造，构造一个 code39 一维码解码器
     */
    public init()

    /*
     * 构造一个 code39 一维码解码器
     * 参数 usingCheckDigit - 是否校验，为 true 时，将最后一个数据字符视为校验位，而不是数据，并验证校验和是否通过行号
     */
    public init(usingCheckDigit: Bool)

    /*
     * 构造一个 code39 一维码解码器
     * 参数 usingCheckDigit - 是否校验，为 true 时，将最后一个数据字符视为校验位，而不是数据，并验证校验和是否通过行号
     * 参数 extendedMode - 如果为 true，将解码文本中的扩展 Code 39 序列
     */
    public init(usingCheckDigit: Bool, extendedMode: Bool) 

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
}

public open class Code39Writer <: OneDimensionalCodeWriter {
    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contentsin - 要编码的字符串
     * 返回值 Array<Bool> - 编码结果
     */
    public override func encode(contentsin: String): Array<Bool>
}
```

#### 1.4 生成、解析 code93

##### 1.4.1 主要接口
```cangjie
public open class Code93Reader <: OneDReader {
    /*
     * 默认构造，构造一个 code93 一维码解码器
     */
    public init()

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
}

public class Code93Writer <: OneDimensionalCodeWriter {
    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contentsin - 要编码的字符串
     * 返回值 Array<Bool> - 编码结果
     */
    public override func encode(contentsin: String): Array<Bool>
}
```

#### 1.5 生成、解析 EAN13

##### 1.5.1 主要接口
```cangjie
public open class EAN13Reader <: UPCEANReader {
    /*
     * 默认构造，构造一个 EAN13 一维码解码器
     */
    public init()

    /*
     * 获取该解码器的格式
     * 返回值 BarcodeFormat - 解码器格式
     */
    public override func getBarcodeFormat(): BarcodeFormat

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public open override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 startGuardRange - 起始标记数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, startGuardRange: Array<Int64>, hints: HashMap<DecodeHintType, Any>): Result
}

public open class EAN13Writer <: UPCEANWriter {
    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contentsin - 要编码的字符串
     * 返回值 Array<Bool> - 编码结果
     */
    public func encode(contentsin: String): Array<Bool>
}
```

#### 1.6 生成、解析 EAN8

##### 1.6.1 主要接口
```cangjie
public open class EAN8Reader <: UPCEANReader {
    /*
     * 默认构造，构造一个 EAN8 一维码解码器
     */
    public init()

    /*
     * 获取该解码器的格式
     * 返回值 BarcodeFormat - 解码器格式
     */
    public func getBarcodeFormat(): BarcodeFormat

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public open override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 startGuardRange - 起始标记数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, startGuardRange: Array<Int64>, hints: HashMap<DecodeHintType, Any>): Result
}

public open class EAN8Writer <: UPCEANWriter {
    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contentsin - 要编码的字符串
     * 返回值 Array<Bool> - 编码结果
     */
    public override func encode(contentsin: String): Array<Bool>
}
```

#### 1.7 生成、解析 ITF

##### 1.7.1 主要接口
```cangjie
public open class ITFReader <: OneDReader {
    /*
     * 默认构造，构造一个 EAN8 一维码解码器
     */
    public init()

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {
}

public open class ITFWriter <: OneDimensionalCodeWriter {
    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contentsin - 要编码的字符串
     * 返回值 Array<Bool> - 编码结果
     */
    public override func encode(contents: String): Array<Bool>
}
```

#### 1.8 生成、解析 UPC-A 

##### 1.8.1 主要接口
```cangjie
public open class UPCAReader <: UPCEANReader {
    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 startGuardRange - 起始标记数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, startGuardRange: Array<Int64>, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 在图像中定位并解码 UPC-A 条形码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Result - 解码结果
     */
    public override func decode(image: BinaryBitmap): Result

    /*
     * 在图像中定位并解码 UPC-A 条形码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 获取该解码器的格式
     * 返回值 BarcodeFormat - 解码器格式
     */
    public override func getBarcodeFormat(): BarcodeFormat
}

public open class UPCAWriter <: Writer {
    /*
     * 将内容编码为 BitMatrix 一维条形码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的条形码格式，如果格式不是 BarcodeFormat.UPC_A 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix

    /*
     * 将内容编码为 BitMatrix 一维条形码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的条形码格式，如果格式不是 BarcodeFormat.UPC_A 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 参数 hints - 编码参数配置
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64, hints: HashMap<EncodeHintType, Any>): BitMatrix
}
```

#### 1.9 生成、解析 UPC-E

##### 1.9.1 主要接口
```cangjie
public open class UPCEReader <: UPCEANReader {
    /*
     * 默认构造，构造一个 UPC-E 一维码解码器
     */
    public init()

    /*
     * 获取该解码器的格式
     * 返回值 BarcodeFormat - 解码器格式
     */
    public override func getBarcodeFormat(): BarcodeFormat

    /*
     * 将 UPC-E 值扩展回完整的等效 UPC-A 值
     * 参数 upce - 要转换的值
     * 返回值 UTF32String - 转化后的值
     */
    public static func convertUPCEtoUPCA(upce: UTF32String): UTF32String
}

public open class UPCAWriter <: Writer {
    /*
     * 将内容编码为 BitMatrix 一维条形码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的条形码格式，如果格式不是 BarcodeFormat.UPC_A 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix

    /*
     * 将内容编码为 BitMatrix 一维条形码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的条形码格式，如果格式不是 BarcodeFormat.UPC_A 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 参数 hints - 编码参数配置
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64, hints: HashMap<EncodeHintType, Any>): BitMatrix
}
```

#### 1.10 解析  UPC/EAN

##### 1.10.1 主要接口
```cangjie
public abstract class UPCEANReader <: OneDReader {
    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public open override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 startGuardRange - 起始标记数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, startGuardRange: Array<Int64>, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 获取该解码器的格式
     * 返回值 BarcodeFormat - 解码器格式
     */
    public func getBarcodeFormat(): BarcodeFormat
}
```

### 2 支持生成、解析 QRCode

场景：
1. 终端使用、促销活动应用、电子优惠券等的宣传物料；
是否商用：是
目标：提供生成或解析QRCode格式的二维码
验收标准：
1.  可根据实际场景需求生成或解析 QRCode

#### 2.1 qrcode 解码

##### 2.1.1 主要接口
```cangjie
public open class QRCodeReader <: Reader {
    /*
     * 在图像中定位并解码 qrcode 二维码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap): Result

    /*
     * 在图像中定位并解码 qrcode 二维码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result
}
```

#### 2.2 qrcode 编码

##### 2.2.1 主要接口
```cangjie
public class QRCodeWriter <: Writer {
    /*
     * 将内容编码为 qrcode 二维码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的二维码格式，如果格式不是 BarcodeFormat.QR_CODE 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix

    /*
     * 将内容编码为 qrcode 二维码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的二维码格式，如果格式不是 BarcodeFormat.QR_CODE 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 参数 hints - 编码参数配置
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64, hints: HashMap<EncodeHintType, Any>): BitMatrix
}
```

### 3 支持生成、解析 Data Matrix

场景：
1. 生产制造存储产品信息、物流管理货物、门票管理信息、证件管理信息、医疗管理患者信息等；
是否商用：是
目标：提供生成或解析Data Matrix格式的二维码
验收标准：
1.  可根据实际场景需求生成或解析 Data Matrix

#### 3.1 Data Matrix 解码

##### 3.1.1 主要接口
```cangjie
public class DataMatrixReader <: Reader {
    /*
     * 在图像中定位并解码 Data Matrix 二维码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap): Result

    /*
     * 在图像中定位并解码 Data Matrix 二维码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result
}
```

#### 3.2 Data Matrix 编码

##### 3.2.1 主要接口
```cangjie
public class DataMatrixWriter <: Writer {
    /*
     * 将内容编码为 Data Matrix 二维码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的二维码格式，如果格式不是 BarcodeFormat.DATA_MATRIX 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix

    /*
     * 将内容编码为 Data Matrix 二维码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的二维码格式，如果格式不是 BarcodeFormat.DATA_MATRIX 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 参数 hints - 编码参数配置
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64, hints: HashMap<EncodeHintType, Any>): BitMatrix
}
```

### 4 支持生成、解析 PDF417 barcode

场景：
1. 用于物流运输、身份认证、票务和证件、医疗健康、零食和库存管理等方面；
是否商用：是
目标：提供生成或解析PDF417 barcode格式的二维码
验收标准：
1.  可根据实际场景需求生成或解析 PDF417 barcode

#### 4.1 PDF417 barcode 解码

##### 4.1.1 主要接口
```cangjie
public open class PDF417Reader <: Reader & MultipleBarcodeReader {
    /*
     * 在图像中定位并解码 PDF417 barcode 二维码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap): Result

    /*
     * 在图像中定位并解码 PDF417 barcode 二维码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result
}
```

#### 4.2 PDF417 barcode 编码

##### 4.2.1 主要接口
```cangjie
public open class PDF417Writer <: Writer {
    /*
     * 将内容编码为 PDF417 barcode 二维码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的二维码格式，如果格式不是 BarcodeFormat.PDF_417 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix

    /*
     * 将内容编码为 PDF417 barcode 二维码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的二维码格式，如果格式不是 BarcodeFormat.PDF_417 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 参数 hints - 编码参数配置
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64, hints: HashMap<EncodeHintType, Any>): BitMatrix
}
```

### 5 支持生成、解析 Aztec barcode

场景：
1. 用于移动支付、电子票务、物流追踪、会员卡、电子门票等方面；
是否商用：是
目标：提供生成或解析Aztec barcode格式的二维码
验收标准：
1.  可根据实际场景需求生成或解析 Aztec barcode

#### 5.1 Aztec barcode 解码

##### 5.1.1 主要接口
```cangjie
public class AztecReader <: Reader {
    /*
     * 在图像中定位并解码 Aztec barcode 二维码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Result - 解码结果
     */
    public override func decode(image: BinaryBitmap): Result

    /*
     * 在图像中定位并解码 Aztec barcode 二维码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result
}
```

#### 5.2 Aztec barcode 编码

##### 5.2.1 主要接口
```cangjie
public class AztecWriter <: Writer {
    /*
     * 将内容编码为 Aztec barcode 二维码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的二维码格式，如果格式不是 BarcodeFormat.AZTEC 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix

    /*
     * 将内容编码为 Aztec barcode 二维码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的二维码格式，如果格式不是 BarcodeFormat.AZTEC 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 参数 hints - 编码参数配置
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64, hints: HashMap<EncodeHintType, Any>): BitMatrix
}
```

### 6 支持解析 MaxiCode 

场景：
1. 用于物流、快递、包裹等方面；
是否商用：是
目标：提供解析MaxiCode格式的二维码
验收标准：
1.  可根据实际场景需求解析 MaxiCode

#### 6.1 MaxiCode 解码

##### 6.1.1 主要接口
```cangjie
public class MaxiCodeReader <: Reader {
    /*
     * 在图像中定位并解码 MaxiCode 二维码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap): Result

    /*
     * 在图像中定位并解码 MaxiCode 二维码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result
}
```

### 7 支持解析 RSS  barcode

场景：
1. 用于物流、快递、包裹等方面；
是否商用：是
目标：提供解析 RSS barcode 条码
验收标准：
1.  可根据实际场景需求解析 RSS barcode 条码

#### 7.1 RSS 解码

##### 7.1.1 主要接口
```cangjie
public class RSS14Reader <: AbstractRSSReader {
    /*
     * 解码单行图像中的 RSS-14 一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
}

public class RSSExpandedReader <: AbstractRSSReader {
    /*
     * 解码单行图像中的 RSS-Expanded 一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 解码单行图像中的 RSS-Expanded 一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 返回值 ArrayList<ExpandedPair> - 解码结果
     */
    public func decodeRow2pairs(rowNumber: Int64, row: BitArray): ArrayList<ExpandedPair>
}
```

### 8 支持多种条码扫描

场景：
1. 用于检测一幅图像中存在多种二维码的条码；
是否商用：是
目标：提供解析一幅图像中存在多种二维码的条码
验收标准：
1.  可根据实际场景需求解析 多种二维码的条码

#### 8.1 检测解码一幅图像中多个二维码

##### 8.1.1 主要接口
```cangjie
public interface MultipleBarcodeReader {
    /*
     * 在图像中定位并解码多个二维码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Array<Result> - 解码结果数组
     */
    func decodeMultiple(image: BinaryBitmap): Array<Result>

    /*
     * 在图像中定位并解码多个二维码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Array<Result> - 解码结果数组
     */
    func decodeMultiple(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Array<Result>
}

public class GenericMultipleBarcodeReader <: MultipleBarcodeReader {
    /*
     * 构造一个解码器
     * 参数 delegate - 解码器
     */
    public init(delegate: Reader)
    
    /*
     * 在图像中定位并解码多个二维码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Array<Result> - 解码结果数组
     */
    func decodeMultiple(image: BinaryBitmap): Array<Result>

    /*
     * 在图像中定位并解码多个二维码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Array<Result> - 解码结果数组
     */
    func decodeMultiple(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Array<Result>
}

public class ByQuadrantReader <: Reader {
    /*
     * 构造一个解码器
     * 参数 delegate - 解码器
     */
    public init(delegate: Reader)

    /*
     * 扫描图像的子集并解码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Result - 解码结果
     */
    public override func decode(image: BinaryBitmap): Result

    /*
     * 扫描图像的子集并解码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 调用构造解码器的 reset
     */
    public func reset()
}

public class QRCodeMultiReader <: QRCodeReader & MultipleBarcodeReader {
    /*
     * 在图像中定位并解码多个 qrcode 二维码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Array<Result> - 解码结果数组
     */
    public func decodeMultiple(image: BinaryBitmap): Array<Result>

    /*
     * 在图像中定位并解码多个 qrcode 二维码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Array<Result> - 解码结果数组
     */
    public func decodeMultiple(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Array<Result>
}
```

### 10 客户端分析  （地址、邮件、电话等）

场景：
1.实现地址簿格式、地址簿条目格式、对联系人信息编码后的解析结果
2.实现对某个时间日历事件进行编码后的分析结果
3.实现对电子邮件、电子邮件地址进行编码后的分析结果、实现电子邮件信息输入格式
4.实现对按RSS格式编码的扩展产品信息进行编码后的分析结果
5.实现对地理坐标进行编码后的分析结果
6.实现对ISBN编号产品进行编码后的分析结果
7.实现对通过某种标识符对产品进行编码后的分析结果
8.实现对SMS消息进行编码后的解析结果，包括收件人、主题和正文
9.实现对电话号码进行编码后的分析结果
10.尝试解析某种URI的结果
11.尝试释解析URLT的结果
12.解析根据VCard(2.1)格式格式化后的联系人信息
13.解析日历事件的结果
14.实现对车辆标识号进行编码的分析结果
15.实现对wifi网络信息进行编码后的分析结果
是否商用：是
目标：实现对多种客户端信息编码后的解析结果
验收标准：
1.  实现对多种客户端信息编码后的解析结果

#### 10.1 实现对各种信息解析

##### 10.1.1 主要接口
```cangjie
public abstract class ResultParser {
    /*
     * 对解码结果进行内容解析，抽象函数
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(theResult: Result): ?ParsedResult

    /*
     * 对解码结果进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public static func parseResult(theResult: Result): ParsedResult
}

public open class AddressBookAUResultParser <: ResultParser {
    /*
     * 对 KDDI AU 地址簿类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class AddressBookDoCoMoResultParser <: AbstractDoCoMoResultParser {
    /*
     * 对 MECARD 地址簿格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class EmailAddressResultParser <: ResultParser {
    /*
     * 对邮箱地址类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class ExpandedProductResultParser <: ResultParser {
    /*
     * 对代表 RSS 扩展代码的数字字符串类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class GeoResultParser <: ResultParser {
    /*
     * 对 "geo:" 格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class ISBNResultParser <: ResultParser {
    /*
     * 对 ISBN 类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class ProductResultParser <: ResultParser {
    /*
     * 对 UPC 代码的数字字符串类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class SMSMMSResultParser <: ResultParser {
    /*
     * 对手机号类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class SMSTOMMSTOResultParser <: ResultParser {
    /*
     * 对 "smsto:" 格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class SMTPResultParser <: ResultParser {
    /*
     * 对 "smtp:" 格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class TelResultParser <: ResultParser {
    /*
     * 对 "tel:" 格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class URIResultParser <: ResultParser {
    /*
     * 对 URI 资源地址格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class URLTOResultParser <: ResultParser {
    /*
     * 对网络 URL 地址格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class VCardResultParser <: ResultParser {
    /*
     * 对 VCard (2.1) 联系人信息格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class VEventResultParser <: ResultParser {
    /*
     * 对 "VEVENT" 日历事件格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class VINResultParser <: ResultParser {
    /*
     * 对车辆识别码格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class WifiResultParser <: ResultParser {
    /*
     * 对 wifi 网络信息格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class BizcardResultParser <: AbstractDoCoMoResultParser {
    /*
     * 对 BIZCARD 格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class BookmarkDoCoMoResultParser <: AbstractDoCoMoResultParser {
    /*
     * 对 MEBKM 格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}

public open class EmailDoCoMoResultParser <: AbstractDoCoMoResultParser {
    /*
     * 对 MATMSG 格式类型进行内容解析
     * 参数 theResult - 解码器返回的 Result 结果
     * 返回值 ParsedResult - 解析结果
     */
    public func parse(result: Result): ?ParsedResult
}
```

### 其他接口

```cangjie
/**
 * 封装了一维条形码系列共有的功能和实现方式
 */
public abstract class OneDReader <: Reader {
    /*
     * 解码 BinaryBitmap 图像中的一维条形码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Result - 解码结果
     */
    public open override func decode(image: BinaryBitmap): Result

    /*
     * 解码 BinaryBitmap 图像中的一维条形码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public open override func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
}

/**
 * 封装了一维条形码常见的功能和实现方式
 */
public abstract class OneDimensionalCodeWriter <: Writer {
    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contents - 要编码的字符串
     * 返回值 Array<Bool> - 编码结果
     */
    public func encode(contents: String): Array<Bool>

    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contents - 要编码的字符串
     * 参数 hints - 编码参数配置
     * 返回值 Array<Bool> - 编码结果
     */
    public open func encode(contents: String, hints: HashMap<EncodeHintType, Any>): Array<Bool>

    /*
     * 将内容编码为 BitMatrix 一维条形码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的条形码格式，如果格式不是 BarcodeFormat.UPC_A 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public open func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix

    /*
     * 将内容编码为 BitMatrix 一维条形码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的条形码格式，如果格式不是 BarcodeFormat.UPC_A 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 参数 hints - 编码参数配置
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64, hints: HashMap<EncodeHintType, Any>): BitMatrix

    /*
     * 获取默认边距
     * 返回值 Int64 - 固定返回 10
     */
    public open func getDefaultMargin(): Int64
}

/**
 * 解码参数配置
 */
public enum DecodeHintType <: Hashable & Equatable<DecodeHintType> {
    /** 未指定的特定应用提示 */
    | OTHER
    /** 图像是条形码的纯单色图像 */
    | PURE_BARCODE
    /** 已知图像可能有几种格式之一 */
    | POSSIBLE_FORMATS
    /** 花更多时间尝试查找条形码，优化准确性而非速度 */
    | TRY_HARDER
    /** 指定解码时使用的字符编码 */
    | CHARACTER_SET
    /** 允许的编码数据长度 */
    | ALLOWED_LENGTHS
    /** 假设代码 39_校验位 */
    | ASSUME_CODE_39_CHECK_DIGIT
    /** 假设条形码作为 GS1 条形码处理 */
    | ASSUME_GS1
    /** 如果为 true，则返回 Codabar 条形码中的起始和结束数字，而不是将其剥离 */
    | RETURN_CODABAR_START_END
    /** 当发现可能的结果时，需要通过回调通知调用者 */
    | NEED_RESULT_POINT_CALLBACK
    /** EAN 或 UPC 条形码允许的扩展长度 */
    | ALLOWED_EAN_EXTENSIONS
    /** 如果为 true，也会尝试解码为反转图像 */
    | ALSO_INVERTED

    /*
     * 返回枚举值对应的 Int64 数字
     * 参数 result - DecodeHintType 枚举值
     * 返回值 Int64 - 对应的 Int64 数字
     */
    public func GetDecodeHintTypeNum(result: DecodeHintType): Int64

    /*
     * 判等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否相等
     */
    public operator func ==(right: DecodeHintType): Bool

    /*
     * 判不等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否不等
     */
    public operator func !=(right: DecodeHintType): Bool

    /*
     * 获取哈希值
     * 返回值 Int64 - 返回实例类型的哈希值
     */
    public func hashCode(): Int64
}

public class AztecDetectorResult <: DetectorResult {
    /*
     * 构造，Aztec 格式的特定信息
     * 参数 bits - BitMatrix 图像
     * 参数 points - 编码提示
     * 参数 compact - 是否压缩
     * 参数 nbDatablocks - 数据块锁定
     * 参数 nbLayers - 层数
     */
    public init(bits: BitMatrix, points: Array<ResultPoint>, compact: Bool, nbDatablocks: Int64, nbLayers: Int64)

    /*
     * 获取 nbLayers 值
     * 参数 Int64 - nbLayers 值
     */
    public func getNbLayers(): Int64

    /*
     * 获取 nbDatablocks 值
     * 参数 Int64 - nbDatablocks 值
     */
    public func getNbDatablocks(): Int64

    /*
     * 获取 compact 标志值
     * 返回值 Bool - Bool 值
     */
    public func isCompact(): Bool
}

public class Decoder {
    /*
     * Aztec 解码
     * 参数 detectorResult - AztecDetectorResult 数据
     * 返回值 DecoderResult - 解码结果
     */
    public func decode(detectorResult: AztecDetectorResult): DecoderResult

    /*
     * 方法用于测试高级编码器
     * 参数 correctedBits - 当前字节
     * 返回值 String - 编码数据
     */
    public static func highLevelDecode(correctedBits: Array<Bool>): String
}

public class Point <: ToString {
    /*
     * 构造，点位信息
     * 参数 x - 横坐标
     * 参数 y - 纵坐标
     */
    public init(x: Int64, y: Int64)

    /*
     * 设置坐标
     * 参数 x - 横坐标
     * 参数 y - 纵坐标
     */
    public func setXY(x: Int64, y: Int64)

    /*
     * 获取设置横坐标
     * 返回值 Int64 - 横坐标
     */
    public func getX(): Int64

    /*
     * 获取设置纵坐标
     * 返回值 Int64 - 纵坐标
     */
    public func getY(): Int64

    /*
     * 转字符串
     * 返回值 String - 按 "<${x} ${y}>" 格式转换
     */
    public func toString(): String
}

public class Detector {
    /*
     * 构造，Aztec 二维码的定位器
     * 参数 image - BitMatrix 图像
     */
    public init(image: BitMatrix)

    /*
     * Aztec 解码
     * 返回值 AztecDetectorResult - 解码结果
     */
    public func detect(): AztecDetectorResult

    /*
     * Aztec 解码
     * 参数 isMirror - 是否为镜像图
     * 返回值 AztecDetectorResult - 解码结果
     */
    public func detect(isMirror: Bool): AztecDetectorResult
}

public open class AddressBookParsedResult <: ParsedResult {
    /*
     * 构造
     * 参数 names - 姓名
     * 参数 phoneNumbers - 电话
     * 参数 phoneTypes - 电话类型
     * 参数 emails - 邮箱
     * 参数 emailTypes - 邮箱类型
     * 参数 addresses - 地址
     * 参数 addressTypes - 地址类型
     */
    public func AddressBookParsedResult(names: Array<String>, phoneNumbers: Array<String>, phoneTypes: Array<String>, emails: Array<String>, emailTypes: Array<String>, addresses: Array<String>, addressTypes: Array<String>)

    /*
     * 构造
     * 参数 names - 姓名
     * 参数 nicknames - 昵称
     * 参数 pronunciation - 电话类型
     * 参数 phoneNumbers - 电话
     * 参数 phoneTypes - 电话类型
     * 参数 emails - 邮箱
     * 参数 emailTypes - 邮箱类型
     * 参数 instantMessenger - 紧急联系人
     * 参数 note - 备注
     * 参数 addresses - 地址
     * 参数 addressTypes - 地址类型
     * 参数 org - 组织
     * 参数 birthday - 生日
     * 参数 title - 标题
     * 参数 urls - 地址
     * 参数 geo - 地址
     */
    public init(
        names: Array<String>,
        nicknames: Array<String>,
        pronunciation: String,
        phoneNumbers: Array<String>,
        phoneTypes: Array<String>,
        emails: Array<String>,
        emailTypes: Array<String>,
        instantMessenger: String,
        note: String,
        addresses: Array<String>,
        addressTypes: Array<String>,
        org: String,
        birthday: String,
        title: String,
        urls: Array<String>,
        geo: Array<String>
    )

    /*
     * 获取 Names
     * 返回值 Array<String> - Names
     */
    public func getNames(): Array<String>

    /*
     * 获取 Nicknames
     * 返回值 Array<String> - Nicknames
     */
    public func getNicknames(): Array<String>

    /*
     * 获取 Pronunciation
     * 返回值 String - Pronunciation
     */
    public func getPronunciation(): String

    /*
     * 获取 PhoneNumbers
     * 返回值 Array<String>  - PhoneNumbers
     */
    public func getPhoneNumbers(): Array<String> 

    /*
     * 获取 PhoneTypes
     * 返回值 Array<String>  - PhoneTypes
     */
    public func getPhoneTypes(): Array<String>

    /*
     * 获取 Emails
     * 返回值 Array<String>  - Emails
     */
    public func getEmails(): Array<String>

    /*
     * 获取 EmailTypes
     * 返回值 Array<String>  - EmailTypes
     */  
    public func getEmailTypes(): Array<String>

    /*
     * 获取 InstantMessenger
     * 返回值 String  - InstantMessenger
     */  
    public func getInstantMessenger(): String

    /*
     * 获取 Note
     * 返回值 String  - Note
     */  
    public func getNote(): String
    
    /*
     * 获取 Addresses
     * 返回值 Array<String>  - Addresses
     */  
    public func getAddresses(): Array<String>

    /*
     * 获取 AddressTypes
     * 返回值 Array<String>  - AddressTypes
     */  
    public func getAddressTypes(): Array<String>

    /*
     * 获取 Title
     * 返回值 String  - Title
     */  
    public func getTitle(): String

    /*
     * 获取 Org
     * 返回值 String  - Org
     */  
    public func getOrg(): String

    /*
     * 获取 URLs
     * 返回值 Array<String>  - URLs
     */  
    public func getURLs(): Array<String>

    /*
     * 获取 Birthday
     * 返回值 String  - Birthday
     */  
    public func getBirthday(): String

    /*
     * 获取 Geo
     * 返回值 Array<String>  - Geo
     */  
    public func getGeo(): Array<String>

    /*
     * 转换字符串
     * 返回值 String  - String
     */  
    public override func getDisplayResult(): String 
}

public open class CalendarParsedResult <: ParsedResult {
    /*
     * 默认构造
     */  
    public init()

    /*
     * 构造
     * 参数 summary - 总结
     * 参数 startString - 开始
     * 参数 endString - 结束
     * 参数 durationString - 持续
     * 参数 location - 位置
     * 参数 organizer - 组织
     * 参数 attendees - 参与
     * 参数 description - 描述
     * 参数 latitude - 经度
     * 参数 longitude - 纬度
     */
    public init(
        summary: String,
        startString: String,
        endString: String,
        durationString: String,
        location: String,
        organizer: String,
        attendees: Array<String>,
        description: String,
        latitude: Float64,
        longitude: Float64
    )

    /*
     * 获取 Summary
     * 返回值 String  - Summary
     */  
    public func getSummary(): String

    /*
     * 获取 Start
     * 参数 start - Int64
     * 返回值 DateTime  - Start
     */  
    public func getStart(start: Int64): DateTime

    /*
     * 获取 StartTimestamp
     * 返回值 StartTimestamp  - StartTimestamp
     */ 
    public func getStartTimestamp(): StartTimestamp

    /*
     * 获取 StartAllDay
     * 返回值 Bool  - StartAllDay
     */ 
    public func isStartAllDay(): Bool

    /*
     * 获取 End
     * 返回值 DateTime  - End
     */ 
    public func getEnd(): DateTime

    /*
     * 获取 EndTimestamp
     * 返回值 Int64  - EndTimestamp
     */ 
    public func getEndTimestamp(): Int64

    /*
     * 获取 EndAllDay
     * 返回值 Bool  - EndAllDay
     */ 
    public func isEndAllDay(): Bool

    /*
     * 获取 Location
     * 返回值 String  - Location
     */ 
    public func getLocation(): String

    /*
     * 获取 Organizer
     * 返回值 String  - Organizer
     */ 
    public func getOrganizer(): String

    /*
     * 获取 Attendees
     * 返回值 Array<String>  - Attendees
     */ 
    public func getAttendees(): Array<String>

    /*
     * 获取 Description
     * 返回值 String  - Description
     */ 
    public func getDescription(): String

    /*
     * 获取 Latitude
     * 返回值 Float64  - Latitude
     */ 
    public func getLatitude(): Float64

    /*
     * 获取 Longitude
     * 返回值 Float64  - Longitude
     */ 
    public func getLongitude(): Float64

    /*
     * 转换字符串
     * 返回值 String  - String
     */  
    public override func getDisplayResult(): String
}

public open class EmailAddressParsedResult <: ParsedResult {
    /*
     * 默认构造
     */  
    public init()

    /*
     * 获取 EmailAddress
     * 返回值 String  - EmailAddress
     */ 
    public func getEmailAddress(): String

    /*
     * 获取 Tos
     * 返回值 Array<String>  - Tos
     */ 
    public func getTos(): Array<String> 

    /*
     * 获取 CCs
     * 返回值 Array<String>  - CCs
     */ 
    public func getCCs(): Array<String>

    /*
     * 获取 BCCs
     * 返回值 Array<String>  - BCCs
     */ 
    public func getBCCs(): Array<String>

    /*
     * 获取 Subject
     * 返回值 String  - Subject
     */ 
    public func getSubject(): String

    /*
     * 获取 Body
     * 返回值 String  - Body
     */ 
    public func getBody(): String

    /*
     * 获取 MailtoURI
     * 返回值 String  - MailtoURI
     */ 
    public func getMailtoURI(): String

    /*
     * 转换字符串
     * 返回值 String  - String
     */  
    public override func getDisplayResult(): String
}

public open class ExpandedProductParsedResult <: ParsedResult {
    /*
     * 构造
     * 参数 rawText - rawText
     * 参数 productID - productID
     * 参数 sscc - sscc
     * 参数 lotNumber - lotNumber
     * 参数 productionDate - productionDate
     * 参数 packagingDate - packagingDate
     * 参数 bestBeforeDate - bestBeforeDate
     * 参数 expirationDate - expirationDate
     * 参数 weight - weight
     * 参数 weightType - weightType
     * 参数 weightIncrement - weightIncrement
     * 参数 price - price
     * 参数 priceIncrement - priceIncrement
     * 参数 priceCurrency - priceCurrency
     * 参数 uncommonAIs - uncommonAIs
     */
    public init(
        rawText: String,
        productID: String,
        sscc: String,
        lotNumber: String,
        productionDate: String,
        packagingDate: String,
        bestBeforeDate: String,
        expirationDate: String,
        weight: String,
        weightType: String,
        weightIncrement: String,
        price: String,
        priceIncrement: String,
        priceCurrency: String,
        uncommonAIs: HashMap<String, String>
    )

    /*
     * 判等
     * 参数 o - Object
     * 返回值 Bool  - 是否相等
     */  
    public func equals(o: Object): Bool

    /*
     * 计算哈希值
     * 返回值 Int64  - 哈希值
     */ 
    public func hashCode(): Int64

    /*
     * 获取 RawText
     * 返回值 String  - RawText
     */ 
    public func getRawText(): String

    /*
     * 获取 ProductID
     * 返回值 String  - ProductID
     */ 
    public func getProductID(): String

    /*
     * 获取 Sscc
     * 返回值 String  - Sscc
     */ 
    public func getSscc(): String

    /*
     * 获取 LotNumber
     * 返回值 String  - LotNumber
     */ 
    public func getLotNumber(): String

    /*
     * 获取 ProductionDate
     * 返回值 String  - ProductionDate
     */ 
    public func getProductionDate(): String

    /*
     * 获取 PackagingDate
     * 返回值 String  - PackagingDate
     */ 
    public func getPackagingDate(): String

    /*
     * 获取 BestBeforeDate
     * 返回值 String  - BestBeforeDate
     */ 
    public func getBestBeforeDate(): String

    /*
     * 获取 ExpirationDate
     * 返回值 String  - ExpirationDate
     */ 
    public func getExpirationDate(): String

    /*
     * 获取 Weight
     * 返回值 String  - Weight
     */ 
    public func getWeight(): String

    /*
     * 获取 WeightType
     * 返回值 String  - WeightType
     */ 
    public func getWeightType(): String

    /*
     * 获取 WeightIncrement
     * 返回值 String  - WeightIncrement
     */ 
    public func getWeightIncrement(): String

    /*
     * 获取 Price
     * 返回值 String  - Price
     */ 
    public func getPrice(): String

    /*
     * 获取 PriceIncrement
     * 返回值 String  - PriceIncrement
     */ 
    public func getPriceIncrement(): String

    /*
     * 获取 PriceCurrency
     * 返回值 String  - PriceCurrency
     */ 
    public func getPriceCurrency(): String

    /*
     * 获取 UncommonAIs
     * 返回值 HashMap<String, String>  - UncommonAIs
     */ 
    public func getUncommonAIs(): HashMap<String, String>

    /*
     * 转换字符串
     * 返回值 String  - String
     */  
    public func getDisplayResult(): String
}

public open class GeoParsedResult <: ParsedResult {
    /*
     * 默认构造
     */  
    public init()

    /*
     * 获取 GeoURI
     * 返回值 String  - GeoURI
     */ 
    public func getGeoURI(): String

    /*
     * 获取 Latitude
     * 返回值 Float64  - Latitude
     */ 
    public func getLatitude(): Float64

    /*
     * 获取 Longitude
     * 返回值 Float64  - Longitude
     */ 
    public func getLongitude(): Float64

    /*
     * 获取 Altitude
     * 返回值 Float64  - Altitude
     */ 
    public func getAltitude(): Float64

    /*
     * 获取 Query
     * 返回值 String  - Query
     */ 
    public func getQuery(): String
    
    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public override func getDisplayResult(): String
}

public open class ISBNParsedResult <: ParsedResult {
    /*
     * 获取 ISBN
     * 返回值 String  - ISBN
     */ 
    public func getISBN(): String

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func getDisplayResult(): String 
}

public abstract class ParsedResult {
    /*
     * 获取类型
     * 返回值 ParsedResultType  - ParsedResultType
     */ 
    public func getType(): ParsedResultType

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public open func getDisplayResult(): String

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String

    /*
     * 添加结果
     * 参数 value - 值
     * 参数 result - 结果
     */ 
    public static func maybeAppend(value: String, result: ArrayList<Char>)

    /*
     * 添加结果
     * 参数 value - 值
     * 参数 result - 结果
     */ 
    public static func maybeAppend(values: Array<String>, result: ArrayList<Char>)
}

public enum ParsedResultType <: ToString {
    | ADDRESSBOOK
    | EMAIL_ADDRESS
    | PRODUCT
    | URI
    | TEXT
    | GEO
    | TEL
    | SMS
    | CALENDAR
    | WIFI
    | ISBN
    | VIN
    
    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String {
}

public open class ProductParsedResult <: ParsedResult {
    /*
     * 获取 ProductID
     * 返回值 String  - ProductID
     */ 
    public func getProductID(): String

    /*
     * 获取 NormalizedProductID
     * 返回值 String  - NormalizedProductID
     */ 
    public func getNormalizedProductID(): String

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public override func getDisplayResult(): String
}

public open class SMSParsedResult <: ParsedResult {
    /*
     * 构造
     * 参数 number - String
     * 参数 via - String
     * 参数 subject - String
     * 参数 body - String
     */ 
    public init(number: String, via: String, subject: String, body: String)

    /*
     * 构造
     * 参数 numbers - Array<String>
     * 参数 vias - Array<String>
     * 参数 subject - String
     * 参数 body - String
     */ 
    public init(numbers: Array<String>, vias: Array<String>, subject: String, body: String)

    /*
     * 获取 SMSURI
     * 返回值 String  - SMSURI
     */ 
    public func getSMSURI(): String

    /*
     * 获取 Numbers
     * 返回值 Array<String>   - Numbers
     */ 
    public func getNumbers(): Array<String> 

    /*
     * 获取 Vias
     * 返回值 Array<String>   - Vias
     */ 
    public func getVias(): Array<String>

    /*
     * 获取 Subject
     * 返回值 String   - Subject
     */ 
    public func getSubject(): String

    /*
     * 获取 Body
     * 返回值 String   - Body
     */ 
    public func getBody(): String

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public override func getDisplayResult(): String
}

public open class TelParsedResult <: ParsedResult {
    /*
     * 默认构造
     */  
    public init()

    /*
     * 构造
     * 参数 number - String
     * 参数 telURI - String
     * 参数 title - String
     */  
    public init(number: String, telURI: String, title: String)

    /*
     * 获取 Number
     * 返回值 String   - Number
     */ 
    public func getNumber(): String

    /*
     * 获取 TelURI
     * 返回值 String   - TelURI
     */ 
    public func getTelURI(): String

    /*
     * 获取 Title
     * 返回值 String   - Title
     */ 
    public func getTitle(): String

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public override func getDisplayResult(): String
}

public open class TextParsedResult <: ParsedResult {
    /*
     * 构造
     * 参数 text - String
     * 参数 language - String
     */  
    public init(text: String, language: String)

    /*
     * 获取 Text
     * 返回值 String   - Text
     */ 
    public func getText(): String

    /*
     * 获取 Language
     * 返回值 String   - Language
     */ 
    public func getLanguage(): String

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public override func getDisplayResult(): String
}

public open class URIParsedResult <: ParsedResult {
    /*
     * 构造
     */ 
    public init()

    /*
     * 构造
     * 参数 uri - String
     * 参数 title - String
     */ 
    public init(uri: String, title: String)

    /*
     * 获取 URI
     * 返回值 String   - URI
     */ 
    public func getURI(): String

    /*
     * 获取 Title
     * 返回值 String   - Title
     */ 
    public func getTitle(): String

    /*
     * 获取 isPossiblyMaliciousURI
     * 返回值 Bool   - isPossiblyMaliciousURI
     */ 
    public func isPossiblyMaliciousURI(): Bool

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public override func getDisplayResult(): String
}

public open class VINParsedResult <: ParsedResult {
    /*
     * 构造
     */ 
    public init()

    /*
     * 构造
     * 参数 vin - Array<String>
     * 参数 worldManufacturerID - Array<String>
     * 参数 vehicleDescriptorSection - String
     * 参数 vehicleIdentifierSection - String
     * 参数 countryCode - Array<String>
     * 参数 vehicleAttributes - Array<String>
     * 参数 modelYear - Int64
     * 参数 plantCode - Char
     * 参数 sequentialNumber - String
     */ 
    public init(
        vin: String,
        worldManufacturerID: String,
        vehicleDescriptorSection: String,
        vehicleIdentifierSection: String,
        countryCode: String,
        vehicleAttributes: String,
        modelYear: Int64,
        plantCode: Char,
        sequentialNumber: String
    )

    /*
     * 获取 VIN
     * 返回值 String   - VIN
     */ 
    public func getVIN(): String

    /*
     * 获取 WorldManufacturerID
     * 返回值 String   - WorldManufacturerID
     */ 
    public func getWorldManufacturerID(): String

    /*
     * 获取 VehicleDescriptorSection
     * 返回值 String   - VehicleDescriptorSection
     */ 
    public func getVehicleDescriptorSection(): String

    /*
     * 获取 VehicleIdentifierSection
     * 返回值 String   - VehicleIdentifierSection
     */ 
    public func getVehicleIdentifierSection(): String

    /*
     * 获取 CountryCode
     * 返回值 String   - CountryCode
     */ 
    public func getCountryCode(): String

    /*
     * 获取 VehicleAttributes
     * 返回值 String   - VehicleAttributes
     */ 
    public func getVehicleAttributes(): String

    /*
     * 获取 ModelYear
     * 返回值 Int64   - ModelYear
     */ 
    public func getModelYear(): Int64

    /*
     * 获取 PlantCode
     * 返回值 Char   - PlantCode
     */ 
    public func getPlantCode(): Char

    /*
     * 获取 SequentialNumber
     * 返回值 String   - SequentialNumber
     */ 
    public func getSequentialNumber(): String

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public override func getDisplayResult(): String
}

public open class WifiParsedResult <: ParsedResult {
    /*
     * 构造
     */ 
    public init()

    /*
     * 构造
     * 参数 networkEncryption - String
     * 参数 ssid - String
     * 参数 password - String
     */  
    public func WifiParsedResult(networkEncryption: String, ssid: String, password: String)

    /*
     * 构造
     * 参数 networkEncryption - String
     * 参数 ssid - String
     * 参数 password - String
     * 参数 hidden - Bool
     */  
    public func WifiParsedResult(networkEncryption: String, ssid: String, password: String, hidden: Bool)

    /*
     * 构造
     * 参数 networkEncryption - String
     * 参数 ssid - String
     * 参数 password - String
     * 参数 hidden - Bool
     * 参数 identity - String
     * 参数 anonymousIdentity - String
     * 参数 eapMethod - String
     * 参数 phase2Method - Bool
     */  
    public init(
        networkEncryption: String,
        ssid: String,
        password: String,
        hidden: Bool,
        identity: String,
        anonymousIdentity: String,
        eapMethod: String,
        phase2Method: String
    )

    /*
     * 获取 Ssid
     * 返回值 String   - Ssid
     */ 
    public func getSsid(): String

    /*
     * 获取 NetworkEncryption
     * 返回值 String   - NetworkEncryption
     */ 
    public func getNetworkEncryption(): String

    /*
     * 获取 Password
     * 返回值 String - Password
     */ 
    public func getPassword(): String

    /*
     * 获取 Hidden
     * 返回值 Bool - Hidden
     */ 
    public func isHidden(): Bool

    /*
     * 获取 Identity
     * 返回值 String - Identity
     */ 
    public func getIdentity(): String

    /*
     * 获取 AnonymousIdentity
     * 返回值 String - AnonymousIdentity
     */ 
    public func getAnonymousIdentity(): String

    /*
     * 获取 EapMethod
     * 返回值 String - EapMethod
     */ 
    public func getEapMethod(): String

    /*
     * 获取 Phase2Method
     * 返回值 String - Phase2Method
     */ 
    public func getPhase2Method(): String

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public override func getDisplayResult(): String
}

public class MathUtils {
    /*
     * 四舍五入运算
     * 参数 d - 运算的数
     * 返回值 Int64  - 运算结果
     */ 
    public static func round(d: Float32): Int64

    /*
     * 距离运算
     * 参数 aX - 运算的数
     * 参数 aY - 运算的数
     * 参数 bX - 运算的数
     * 参数 bY - 运算的数
     * 返回值 Float32  - 运算结果
     */ 
    public static func distance(aX: Float32, aY: Float32, bX: Float32, bY: Float32): Float32

    /*
     * 距离运算
     * 参数 aX - 运算的数
     * 参数 aY - 运算的数
     * 参数 bX - 运算的数
     * 参数 bY - 运算的数
     * 返回值 Float32  - 运算结果
     */ 
    public static func distance(aX: Int64, aY: Int64, bX: Int64, bY: Int64): Float32

    /*
     * 加法运算
     * 参数 array - 运算的数
     * 返回值 Int64  - 运算结果
     */ 
    public static func sum(array: Array<Int64>): Int64
}

public class MonochromeRectangleDetector {
    /*
     * 构造
     * 参数 image - BitMatrix 图像
     */  
    public MonochromeRectangleDetector(image: BitMatrix)

    /*
     * 解码
     * 返回值 Array<ResultPoint> - 解码结果
     */ 
    public func detect(): Array<ResultPoint>
}

public class WhiteRectangleDetector {
    /*
     * 构造
     * 参数 image - BitMatrix 图像
     */  
    public init(image: BitMatrix)

    /*
     * 构造
     * 参数 image - BitMatrix 图像
     * 参数 initSize - Int64 值
     * 参数 x - Int64 值
     * 参数 y - Int64 值
     */  
    public init(image: BitMatrix, initSize: Int64, x: Int64, y: Int64)

    /*
     * 检测图像中的候选条形码矩形区域
     * 返回值 Array<ResultPoint> - 解码结果
     */ 
    public func detect(): Array<ResultPoint>
}

public open class MultiFormatReader <: Reader {
    /*
     * 默认构造
     */  
    public init()

    /*
     * 在图像中定位并解码二维码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap): Result

    /*
     * 在图像中定位并解码二维码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 在图像中定位并解码二维码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Result - 解码结果
     */
    public func decodeWithState(image: BinaryBitmap): Result

    /*
     * 设置解码提示
     * 参数 hints - 解码参数配置
     */
    public func setHints(hints: HashMap<DecodeHintType, Any>)

    /*
     * 调用构造解码器的 reset
     */
    public func reset()
}

public class GenericGF {
    /*
     * 构造
     * 参数 primitive - Int64 值
     * 参数 size - Int64 值
     * 参数 b - Int64 值
     */
    public init(primitive: Int64, size: Int64, b: Int64)

    /*
     * 获取 Zero
     * 返回值 GenericGFPoly - Zero
     */ 
    public func getZero(): GenericGFPoly

    /*
     * 获取 One
     * 返回值 GenericGFPoly - One
     */ 
    public func getOne(): GenericGFPoly

    /*
     * 返回代表系数 * x^degree 的单项式
     * 返回值 GenericGFPoly - GenericGFPoly
     */ 
    public func buildMonomial(degree: Int64, coefficient: Int64): GenericGFPoly

    /*
     * 同时执行加法和减法--它们在 GF（大小）中是相同的。
     * 返回值 Int64 - Int64
     */ 
    public static func addOrSubtract(a: Int64, b: Int64): Int64

    /*
     * 返回 GF(size) 中 a 的 2 次方
     * 返回值 Int64 - Int64
     */ 
    public func exp(a: Int64): Int64

    /*
     * 返回 a 在 GF（大小）中的基 2 对数
     * 返回值 Int64 - Int64
     */ 
    public func log(a: Int64): Int64

    /*
     * 返回 a 的乘法逆
     * 返回值 Int64 - Int64
     */ 
    public func inverse(a: Int64): Int64

    /*
     * 返回 a 和 b 在 GF（大小）中的乘积
     * 返回值 Int64 - Int64
     */ 
    public func multiply(a: Int64, b: Int64): Int64

    /*
     * 返回大小
     * 返回值 Int64 - Int64
     */ 
    public func getSize(): Int64

    /*
     * 返回 GeneratorBase
     * 返回值 Int64 - GeneratorBase
     */ 
    public func getGeneratorBase(): Int64

    /*
     * 返回字符串
     * 返回值 String - String
     */ 
    public func toString(): String
}

public class GenericGFPoly <: Equatable<GenericGFPoly> & ToString {
    /*
     * 构造
     * 参数 field - GenericGF 值
     * 参数 coefficients - Array<Int64> 值
     */
    public init(field: GenericGF, coefficients: Array<Int64>)

    /*
     * 返回 Coefficients
     * 返回值 Array<Int64> - Coefficients
     */ 
    public func getCoefficients(): Array<Int64>

    /*
     * 返回 Degree
     * 返回值 Int64 - Degree
     */ 
    public func getDegree(): Int64

    /*
     * 返回 Zero
     * 返回值 Bool - Zero
     */ 
    public func isZero(): Bool

    /*
     * 返回 Coefficient
     * 参数 degree - 位置
     * 返回值 Int64 - Coefficient
     */ 
    public func getCoefficient(degree: Int64): Int64

    /*
     * 返回 evaluate
     * 参数 a - 位置
     * 返回值 Int64 - evaluate
     */ 
    public func evaluateAt(a: Int64): Int64

    /*
     * 返回 GenericGFPoly
     * 参数 other - 位置
     * 返回值 GenericGFPoly - GenericGFPoly
     */ 
    public func addOrSubtract(other: GenericGFPoly): GenericGFPoly

    /*
     * 返回 GenericGFPoly
     * 参数 other - GenericGFPoly
     * 返回值 GenericGFPoly - GenericGFPoly
     */ 
    public func multiply(other: GenericGFPoly): GenericGFPoly

    /*
     * 返回 GenericGFPoly
     * 参数 other - Int64
     * 返回值 GenericGFPoly - GenericGFPoly
     */ 
    public func multiply(scalar: Int64): GenericGFPoly

    /*
     * 返回 GenericGFPoly
     * 参数 degree - Int64
     * 参数 coefficient - Int64
     * 返回值 GenericGFPoly - GenericGFPoly
     */ 
    public func multiplyByMonomial(degree: Int64, coefficient: Int64): GenericGFPoly

    /*
     * 返回字符串
     * 返回值 String - String
     */ 
    public func toString(): String

    /*
     * 判等
     * 参数 that - 对比值
     * 返回值 Bool - 判等
     */ 
    public operator func ==(that: GenericGFPoly): Bool

    /*
     * 判不等
     * 参数 that - 对比值
     * 返回值 Bool - 判不等
     */ 
    public operator func !=(that: GenericGFPoly): Bool
}

public class ReedSolomonDecoder {
    /*
     * 构造
     * 参数 field - GenericGF 值
     */
    public init(field: GenericGF)

    /*
     * 解码
     * 参数 received - Array<Int64 值
     * 参数 twoS - Int64 值
     */
    public func decode(received: Array<Int64>, twoS: twoS)
}

public class ReedSolomonEncoder {
    /*
     * 构造
     * 参数 field - GenericGF 值
     */
    public init(field: GenericGF)

    /*
     * 编码
     * 参数 toEncode - Array<Int64> 值
     * 参数 ecBytes - Int64 值
     */
    public func encode(toEncode: Array<Int64>, ecBytes: Int64)
}

public class ReedSolomonException <: Exception {
    /*
     * 抛异常
     * 参数 message - 异常信息
     */ 
    public ReedSolomonException(message: String)
}

public open class MultiFormatWriter <: Writer {
    /*
     * 将内容编码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的条形码格式，如果格式不是 BarcodeFormat.UPC_A 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public override func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64
    ): BitMatrix

    /*
     * 将内容编码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的条形码格式，如果格式不是 BarcodeFormat.UPC_A 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 参数 hints - 编码参数配置
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64,
        hints: HashMap<EncodeHintType, Any>
    ): BitMatrix
}

public enum BarcodeFormat <: ToString & Equatable<BarcodeFormat> {
    /** Aztec 2D barcode format. */
    | AZTEC
    /** CODABAR 1D format. */
    | CODABAR
    /** Code 39 1D format. */
    | CODE_39
    /** Code 93 1D format. */
    | CODE_93
    /** Code 128 1D format. */
    | CODE_128
    /** Data Matrix 2D barcode format. */
    | DATA_MATRIX
    /** EAN-8 1D format. */
    | EAN_8
    /** EAN-13 1D format. */
    | EAN_13
    /** ITF (Interleaved Two of Five) 1D format. */
    | ITF
    /** MaxiCode 2D barcode format. */
    | MAXICODE
    /** PDF417 format. */
    | PDF_417
    /** QR Code 2D barcode format. */
    | QR_CODE
    /** RSS 14 */
    | RSS_14
    /** RSS EXPANDED */
    | RSS_EXPANDED
    /** UPC-A 1D format. */
    | UPC_A
    /** UPC-E 1D format. */
    | UPC_E
    /** UPC/EAN extension format. Not a stand-alone format. */
    | UPC_EAN_EXTENSION
    | NONE

    /*
     * 判等
     * 参数 right - 对比值
     * 返回值 Bool - 判等
     */ 
    public operator func ==(right: BarcodeFormat): Bool

    /*
     * 判不等
     * 参数 right - 对比值
     * 返回值 Bool - 判不等
     */ 
    public operator func !=(right: BarcodeFormat): Bool

    /*
     * 转换字符串
     * 返回值 String - 字符串
     */ 
    public func toString(): String
}

public abstract class Binarizer {
    /*
     * 获取 LuminanceSource
     * 返回值 LuminanceSource - LuminanceSource
     */ 
    public func getLuminanceSource(): LuminanceSource

    /*
     * 获取 BlackRow
     * 参数 y - Int64
     * 参数 row - BitArray
     * 返回值 BitArray - BitArray
     */ 
    public func getBlackRow(y: Int64, row: BitArray): BitArray

    /*
     * 获取 BlackMatrix
     * 返回值 BitMatrix - BitMatrix
     */ 
    public func getBlackMatrix(): BitMatrix

    /*
     * 获取 Binarizer
     * 参数 source - 数据源
     * 返回值 Binarizer - Binarizer
     */ 
    public func createBinarizer(source: LuminanceSource): Binarizer

    /*
     * 获取 Width
     * 返回值 Int64 - Width
     */ 
    public func getWidth(): Int64

    /*
     * 获取 Height
     * 返回值 Int64 - Height
     */ 
    public func getHeight(): Int64
}

public class BinaryBitmap {
    /*
     * 构造
     * 参数 binarizer - binarizer 值
     */
    public init(binarizer: Binarizer)

    /*
     * 获取 Width
     * 返回值 Int64 - Width
     */ 
    public func getWidth(): Int64

    /*
     * 获取 Height
     * 返回值 Int64 - Height
     */ 
    public func getHeight(): Int64

    /*
     * 获取 BlackRow
     * 参数 y - Int64
     * 参数 row - BitArray
     * 返回值 BitArray - BitArray
     */ 
    public func getBlackRow(y: Int64, row: BitArray): BitArray

    /*
     * 获取 BlackMatrix
     * 返回值 BitMatrix - BitMatrix
     */ 
    public func getBlackMatrix(): BitMatrix

    /*
     * 获取是否可裁剪
     * 返回值 Bool - 可裁剪
     */ 
    public func isCropSupported(): Bool

    /*
     * 裁剪
     * 参数 left - Int64
     * 参数 top - Int64
     * 参数 width - Int64
     * 参数 height - Int64
     * 返回值 BinaryBitmap - BinaryBitmap
     */ 
    public func crop(left: Int64, top: Int64, width: Int64, height: Int64): BinaryBitmap

    /*
     * 获取是否可旋转
     * 返回值 Bool - 是否可旋转
     */ 
    public func isRotateSupported(): Bool

    /*
     * 旋转
     * 返回值 BinaryBitmap - BinaryBitmap
     */ 
    public func rotateCounterClockwise(): BinaryBitmap

    /*
     * 旋转
     * 返回值 BinaryBitmap - BinaryBitmap
     */ 
    public func rotateCounterClockwise45(): BinaryBitmap

    /*
     * 转字符串
     * 返回值 String - 字符串
     */ 
    public func toString(): String
}

public class BitArray <: Hashable & ToString & Equatable<BitArray> {
    /*
     * 构造
     */
    public init()

    /*
     * 构造
     * 参数 size - Int64 值
     */
    public init(size: Int64)

    /*
     * 构造
     * 参数 bits - Array<Int32> 值
     * 参数 size - Int64 值
     */
    public init(bits: Array<Int32>, size: Int64)

    /*
     * 获取 Size
     * 返回值 Int64 - Size
     */ 
    public func getSize(): Int64

    /*
     * 获取 SizeInBytes
     * 返回值 Int64 - SizeInBytes
     */ 
    public func getSizeInBytes(): Int64

    /*
     * 获取值
     * 参数 i - 位置
     * 返回值 Bool - Bool
     */ 
    public func get(i: Int64): Bool

    /*
     * 设置值
     * 参数 i - 位置
     */ 
    public func set(i: Int64): Unit

    /*
     * 跳过值
     * 参数 i - Int64
     */ 
    public func flip(i: Int64): Unit 

    /*
     * 获取 NextSet
     * 参数 fro - 位置
     * 返回值 Int64 - NextSet
     */ 
    public func getNextSet(fro: Int64): Int64

    /*
     * 获取 NextUnset
     * 参数 fro - 位置
     * 返回值 Int64 - NextUnset
     */ 
    public func getNextUnset(fro: Int64): Int64

    /*
     * 设置 Bulk
     * 参数 i - Int64
     * 参数 newBits - Int32
     */ 
    public func setBulk(i: Int64, newBits: Int32): Unit

    /*
     * 设置 Range
     * 参数 start - Int64
     * 参数 end - Int64
     */ 
    public func setRange(start: Int64, end: Int64)

    /*
     * 清空
     */ 
    public func clear()

    /*
     * 设置 Range
     * 参数 start - Int64
     * 参数 end - Int64
     * 参数 value - Int64
     * 返回值 Bool - Bool
     */ 
    public func isRange(start: Int64, end: Int64, value: Bool): Bool

    /*
     * 设置 Bit
     * 参数 bit - Bool
     */ 
    public func appendBit(bit: Bool)

    /*
     * 设置 Bits
     * 参数 value - Int64
     * 参数 numBits - Int64
     */ 
    public func appendBits(value: Int64, numBits: Int64)

    /*
     * 设置 BitArray
     * 参数 other - BitArray
     */ 
    public func appendBitArray(other: BitArray)

    /*
     * 设置 xor
     * 参数 other - BitArray
     */ 
    public func xor(other: BitArray)

    /*
     * 设置 Bytes
     * 参数 other - BitArray
     */ 
    public func toBytes(bitOffset: Int64, array: Array<UInt8>, offset: Int64, numBytes: Int64) 

    /*
     * 获取 BitArray
     * 返回值 Array<Int32> - Array<Int32>
     */ 
    public func getBitArray(): Array<Int32>

    /*
     * 翻转
     * 参数 num - Int32
     * 返回值 Int32 - Int32
     */ 
    public func reverse(num: Int32): Int32

    /*
     * 翻转
     */ 
    public func reverse()

    /*
     * 判等
     * 参数 o - 对比值
     * 返回值 Bool - 判等
     */ 
    public operator func ==(o: BitArray): Bool

    /*
     * 判不等
     * 参数 o - 对比值
     * 返回值 Bool - 判不等
     */ 
    public operator func !=(o: BitArray): Bool

    /*
     * 获取哈希值
     * 返回值 Int64 - 返回实例类型的哈希值
     */
    public func hashCode(): Int64

    /*
     * 转字符串
     * 返回值 String - 字符串
     */ 
    public func toString(): String

    /*
     * 复制
     * 返回值 BitArray - BitArray
     */ 
    public func clone(): BitArray
}

public class BitMatrix <: Equatable<BitMatrix> & ToString {
    /*
     * 初始化一个指定维度的 BitMatrix 对象
     * 参数 dimension - BitMatrix 的维度，即行列数相同的正方形矩阵的边长
     */
    public init(dimension: Int64)

    /*
     * 初始化一个指定维度的 BitMatrix 对象
     * 参数 width - BitMatrix 的宽度，即列数
     * 参数 height - BitMatrix 的高度，即行数
     */
    public init(width: Int64, height: Int64)

    /*
     * 初始化一个指定维度的 BitMatrix 对象
     * 参数 width - BitMatrix 的宽度，即列数
     * 参数 height - BitMatrix 的高度，即行数
     * 参数 rowSize - 位数组中每一行的大小
     * 参数 bits - 用于初始化 BitMatrix 的位数组数据
     */
    public init(width: Int64, height: Int64, rowSize: Int64, bits: Array<Int32>)

    /*
     * 解析二维布尔数组并创建对应的 BitMatrix 对象
     * 参数 image - 二维布尔数组，表示黑白像素图像，true 表示黑色，false 表示白色
     * 返回值 BitMatrix - 对应的 BitMatrix 对象
     */
    public static func parse(image: Array<Array<Bool>>): BitMatrix

    /*
     * 解析二维布尔数组并创建对应的 BitMatrix 对象
     * 参数 stringRepresentation - 字符串表示的 BitMatrix
     * 参数 setString - 用于表示设置了的位的字符
     * 参数 unsetString - 用于表示未设置的位的字符
     * 返回值 BitMatrix - 对应的 BitMatrix 对象
     */
    public static func parse(stringRepresentation: UTF32String, setString: UTF32String, unsetString: UTF32String): BitMatrix

    /*
     * 获取指定位置的像素值
     * 参数 x - 像素的横坐标
     * 参数 y - 像素的纵坐标
     * 返回值 Bool - 指定位置像素的值，true 表示黑色，false 表示白色
     */
    public func get(x: Int64, y: Int64): Bool

    /*
     * 设置指定位置的像素值为黑色
     * 参数 x - 像素的横坐标
     * 参数 y - 像素的纵坐标
     */
    public func set(x: Int64, y: Int64)

    /*
     * 设置指定位置的像素值为白色（即清除像素）
     * 参数 x - 像素的横坐标
     * 参数 y - 像素的纵坐标
     */
    public func unset(x: Int64, y: Int64)

    /*
     * 翻转指定位置的像素值，即将黑色像素变为白色，白色像素变为黑色
     * 参数 x - 像素的横坐标
     * 参数 y - 像素的纵坐标
     */
    public func flip(x: Int64, y: Int64)

    /*
     * 翻转所有像素值，即将黑色像素变为白色，白色像素变为黑色
     */
    public func flip()

    /*
     * 对当前 BitMatrix 对象的像素值与另一个 BitMatrix 对象的像素值进行异或操作
     * 参数 mask - 用于异或操作的 BitMatrix 对象
     */
    public func xor(mask: BitMatrix)

    /*
     * 清除当前 BitMatrix 对象的所有像素值，将所有像素置为白色（即清空 BitMatrix）
     */
    public func clear()

    /*
     * 设置指定区域的像素值为黑色
     * 参数 left - 区域左上角像素的横坐标
     * 参数 top - 区域左上角像素的纵坐标
     * 参数 width - 区域的宽度
     * 参数 height - 区域的高度
     */
    public func setRegion(left: Int64, top: Int64, width: Int64, height: Int64)

    /*
     * 获取指定行的像素数据，并将其存储到给定的 BitArray 对象中
     * 参数 y - 指定行的纵坐标
     * 参数 row - 存储像素数据的 BitArray 对象
     */
    public func getRow(y: Int64, row: BitArray): BitArray

    /*
     * 设置指定行的像素数据为给定的 BitArray 对象中的像素数据
     * 参数 y - 指定行的纵坐标
     * 参数 row - 包含要设置的像素数据的 BitArray 对象
     */
    public func setRow(y: Int64, row: BitArray)

    /*
     * 将当前 BitMatrix 对象中的像素数据按指定角度顺时针旋转
     * 参数 row - 包含要设置的像素数据的 BitArray 对象
     */
    public func rotate(degrees: Int64)

    /*
     * 将当前 BitMatrix 对象中的像素数据按指定角度顺时针旋转 180 度
     */
    public func rotate180()

    /*
     * 将当前 BitMatrix 对象中的像素数据按指定角度顺时针旋转 90 度
     */
    public func rotate90()

    /*
     * 获取当前 BitMatrix 对象中包含像素的最小矩形范围
     * 返回值 Array<Int64> - 包含四个元素的数组，分别表示矩形左上角的 x 坐标、y 坐标、宽度和高度
     */
    public func getEnclosingRectangle(): Array<Int64>

    /*
     * 获取当前 BitMatrix 对象中第一个设置为黑色（即打开）的像素的位置，即左上角的黑色像素的坐标
     * 返回值 Array<Int64> - 包含两个元素的数组，分别表示第一个黑色像素的横坐标和纵坐标
     */
    public func getTopLeftOnBit(): Array<Int64>

    /*
     * 获取当前 BitMatrix 对象中最后一个设置为黑色（即打开）的像素的位置，即右下角的黑色像素的坐标
     * 返回值 Array<Int64> - 包含两个元素的数组，分别表示最后一个黑色像素的横坐标和纵坐标
     */
    public func getBottomRightOnBit(): Array<Int64>

    /*
     * 获取当前 BitMatrix 对象的宽度，即列数
     * 返回值 Int64 - 当前 BitMatrix 对象的宽度（列数）
     */
    public func getWidth(): Int64

    /*
     * 获取当前 Height
     * 返回值 Int64 - Height
     */
    public func getHeight(): Int64

    /*
     * 获取当前 RowSize
     * 返回值 Int64 - RowSize
     */
    public func getRowSize(): Int64

    /*
     * 获取当前哈希值
     * 返回值 Int64 - 哈希值
     */
    public func hashCode(): Int64

    /*
     * 获取当前字符串
     * 返回值 String - 字符串
     */
    public func toString(): String

    /*
     * 将当前 BitMatrix 对象转换为字符串表示形式
     * 参数 setString - 用于表示设置了的位的字符
     * 参数 unsetString - 用于表示未设置的位的字符
     * 返回值 String - 字符串表示的 BitMatrix
     */
    public func toString(setString: String, unsetString: String): String

    /*
     * 将当前 BitMatrix 对象转换为字符串表示形式
     * 参数 setString - 用于表示设置了的位的字符
     * 参数 unsetString - 用于表示未设置的位的字符
     * 参数 lineSeparator - 行分隔符，用于分隔不同行的像素数据
     * 返回值 String - 字符串表示的 BitMatrix
     */
    public func toString(setString: String, unsetString: String, lineSeparator: String): String

    /*
     * 将当前 BitMatrix 对象复制
     * 返回值 BitMatrix - BitMatrix
     */
    public func clone(): BitMatrix

    /*
     * 判不等
     * 参数 right - 对比值
     * 返回值 Bool - 判不等
     */ 
    public operator func !=(right: BitMatrix): Bool

    /*
     * 判等
     * 参数 right - 对比值
     * 返回值 Bool - 判等
     */ 
    public operator func ==(right: BitMatrix): Bool
}

public class BitSource {
    /*
     * 构造
     * 参数 bytes - Array<UInt8>
     */
    public init(bytes: Array<UInt8>)

    /*
     * 获取 BitOffset
     * 返回值 Int64 - Int64
     */ 
    public func getBitOffset(): Int64

    /*
     * 获取 ByteOffset
     * 返回值 Int64 - Int64
     */ 
    public func getByteOffset(): Int64

    /*
     * 读取 oNumBits
     * 参数 oNumBits - Int64
     * 返回值 Int64 - Int64
     */ 
    public func readBits(oNumBits: Int64): Int64

    /*
     * 判有效
     * 返回值 Int64 - Int64
     */ 
    public func available(): Int64
}

public open class StandardCharsets {
    /*
     * 构造
     * 参数 iencode - CharsetEncoder 编码
     */
    public init(iencode: CharsetEncoder)
}

public open class CharsetDecoder {
    /*
     * 构造
     * 参数 idecode - Decoder
     * 参数 icharset - MyCharset 编码
     */
    public init(idecode: Decoder, icharset: MyCharset)

    /*
     * 返回 MyCharset
     * 返回值 MyCharset - MyCharset 编码
     */
    public func charset(): MyCharset

    /*
     * 编码
     * 参数 src - Array<UInt8>
     * 返回值 String - String
     */
    public func decode(src: Array<UInt8>): String
}

public open class CharsetEncoder {
    /*
     * 构造
     * 参数 idecode - Decoder
     * 参数 icharset - MyCharset 编码
     */
    public init(iencode: Encoder, icharset: MyCharset)

    /*
     * 返回 MyCharset
     * 返回值 MyCharset - MyCharset 编码
     */
    public func charset(): MyCharset

    /*
     * 是否可编码
     * 参数 c - Char
     * 返回值 Bool - 是否可编码
     */
    public func canEncode(c: Char): Bool

    /*
     * 获取字节
     * 参数 c - UTF32String
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public func getBytes(c: UTF32String): Array<UInt8>
}

public open class MyCharset <: Equatable<MyCharset> & ToString{
    /*
     * 构造
     */
    public init()

    /*
     * 构造
     * 参数 mychartset - Charset 编码
     * 参数 name - 名称
     */
    public init(mychartset: Charset, name: String)

    /*
     * 构造
     * 参数 mychartset - Charset 编码
     * 参数 name - 名称
     * 参数 realName - 名称
     */
    public init(mychartset: Charset, name: String, realName: String) 

    /*
     * 获取编码
     * 参数 mychartset - Charset 编码
     * 返回值 MyCharset - MyCharset
     */
    public static func forName(name: String): MyCharset

    /*
     * 获取Encoder
     * 返回值 CharsetEncoder - CharsetEncoder
     */
    public func newEncoder(): CharsetEncoder

    /*
     * 获取 Decoder
     * 返回值 CharsetDecoder - CharsetDecoder
     */
    public func newDecoder(): CharsetDecoder

    /*
     * 判等
     * 参数 scharset - MyCharset 值
     * 返回值 Bool - Bool
     */
    public func equals(scharset: MyCharset): Bool

    /*
     * 获取 name
     * 返回值 String - name
     */
    public func name(): String 

    /*
     * 判不等
     * 参数 that - MyCharset
     * 返回值 Bool  - 判不等
     */  
    public operator func !=(that: MyCharset): Bool 

    /*
     * 判等
     * 参数 that - MyCharset
     * 返回值 Bool  - 是否相等
     */  
    public operator func ==(that: MyCharset): Bool

    /*
     * 获取当前字符串
     * 返回值 String - 字符串
     */
    public func toString(): String
}

public open class CharacterSetECI {
    /*
     * 获取 name
     * 返回值 String - name
     */
    public func name(): String


    public func GetCharacterSetECIByValue(result: CharacterSetECI): MyCharset

    /*
     * 判不等
     * 参数 that - MyCharset
     * 返回值 Bool  - 判不等
     */  
    public operator func !=(right: CharacterSetECI): Bool

    /*
     * 判等
     * 参数 that - MyCharset
     * 返回值 Bool  - 是否相等
     */  
    public operator func ==(right: CharacterSetECI): Bool

    /*
     * 计算哈希
     * 返回值 Int64  - 哈希
     */  
    public func hashCode(): Int64

    /*
     * 计获取值
     * 返回值 Int64  - 哈希
     */  
    public func getValue(): Int64

    /*
     * 获取 MyCharset
     * 返回值 MyCharset  - MyCharset
     */ 
    public func getCharset(): MyCharset

    /*
     * 获取 CharacterSetECI
     * 参数 MyCharset  - MyCharset
     * 返回值 Int64  - Int64
     */ 
    public static func getCharacterSetECI(charset: MyCharset): Int64

    /*
     * 获取 CharacterSetSetECIByValue
     * 参数 result  - Int64
     * 返回值 CharacterSetECI  - CharacterSetECI
     */ 
    public static func getCharacterSetECIByValue(result: Int64): CharacterSetECI

    /*
     * 获取 CharacterSetECIByName
     * 参数 result  - String
     * 返回值 CharacterSetECI  - CharacterSetECI
     */ 
    public static func getCharacterSetECIByName(result: String): CharacterSetECI
}

public open class ChecksumException <: ReaderException {
    /*
     * 获取 ChecksumInstance
     * 返回值 ChecksumException  - ChecksumException
     */ 
    public static func getChecksumInstance(): ChecksumException
}

public class DecoderResult {
    /*
     * 构造
     * 参数 rawBytes - Array<UInt8>
     * 参数 text - String
     * 参数 byteSegments - ArrayList<Array<UInt8>>
     * 参数 ecLevel - String
     */
    public init(rawBytes: Array<UInt8>, text: String, byteSegments: ArrayList<Array<UInt8>>, ecLevel: String)

    /*
     * 构造
     * 参数 rawBytes - Array<UInt8>
     * 参数 text - String
     * 参数 byteSegments - ArrayList<Array<UInt8>>
     * 参数 ecLevel - String
     * 参数 symbologyModifier - Int64
     */
    public init(
        rawBytes: Array<UInt8>,
        text: String,
        byteSegments: ArrayList<Array<UInt8>>,
        ecLevel: String,
        symbologyModifier: Int64
    )

    /*
     * 构造
     * 参数 rawBytes - Array<UInt8>
     * 参数 text - String
     * 参数 byteSegments - ArrayList<Array<UInt8>>
     * 参数 ecLevel - String
     * 参数 symbologyModifier - Int64
     * 参数 saParity - Int64
     */
    public init(
        rawBytes: Array<UInt8>,
        text: String,
        byteSegments: ArrayList<Array<UInt8>>,
        ecLevel: String,
        saSequence: Int64,
        saParity: Int64
    )

    /*
     * 构造
     * 参数 rawBytes - Array<UInt8>
     * 参数 text - String
     * 参数 byteSegments - ArrayList<Array<UInt8>>
     * 参数 ecLevel - String
     * 参数 symbologyModifier - Int64
     * 参数 saParity - Int64
     * 参数 symbologyModifier - Int64
     */
    public init(
        rawBytes: Array<UInt8>,
        text: String,
        byteSegments: ArrayList<Array<UInt8>>,
        ecLevel: String,
        saSequence: Int64,
        saParity: Int64,
        symbologyModifier: Int64
    )

    /*
     * 获取 RawBytes
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public func getRawBytes(): Array<UInt8>


    /*
     * 获取 NumBits
     * 返回值 Int64 - NumBits
     */
    public func getNumBits(): Int64

    /*
     * 设置 NumBits
     * 参数 NumBits - NumBits
     */
    public func setNumBits(numBits: Int64): Unit

    /*
     * 获取 Text
     * 返回值 String - Text
     */
    public func getText(): String

    /*
     * 获取 ByteSegments
     * 返回值 ArrayList<Array<UInt8>> - ByteSegments
     */
    public func getByteSegments(): ArrayList<Array<UInt8>>

    /*
     * 获取 ECLevel
     * 返回值 String - String
     */
    public func getECLevel(): String

    /*
     * 获取 ErrorsCorrected
     * 返回值 Int64 - ErrorsCorrected
     */
    public func getErrorsCorrected(): Int64

    /*
     * 设置 ErrorsCorrected
     * 参数 errorsCorrected - ErrorsCorrected
     */
    public func setErrorsCorrected(errorsCorrected: Int64): Unit

    /*
     * 获取 Erasures
     * 返回值 Int64 - Erasures
     */
    public func getErasures(): Int64 

    /*
     * 设置 Erasures
     * 参数 erasures - Erasures
     */
    public func setErasures(erasures: Int64): Unit

    /*
     * 获取 Other
     * 返回值 Any - Other
     */
    public func getOther(): Any

    /*
     * 设置 other
     * 参数 other - other
     */
    public func setOther(other: Any): Unit

    /*
     * StructuredAppend
     * 返回值 Bool - Bool
     */
    public func hasStructuredAppend(): Bool

    /*
     * 获取 StructuredAppendParit
     * 返回值 Int64 - Int64
     */
    public func getStructuredAppendParity(): Int64

    /*
     * 获取 StructuredAppendSequenceNumber
     * 返回值 Int64 - Int64
     */
    public func getStructuredAppendSequenceNumber(): Int64

    /*
     * 获取 SymbologyModifier
     * 返回值 Int64 - SymbologyModifier
     */
    public func getSymbologyModifier(): Int64 
}

public class DefaultGridSampler <: GridSampler {
    /*
     * 获取 BitMatrix
     * 返回值 BitMatrix - BitMatrix
     */
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
    ): BitMatrix

    /*
     * 获取 BitMatrix
     * 返回值 BitMatrix - BitMatrix
     */
    public func sampleGrid(
        image: BitMatrix,
        dimensionX: Int64,
        dimensionY: Int64,
        transform: PerspectiveTransform
    ): BitMatrix
}

public open class DetectorResult {
    /*
     * 构造
     * 参数 bits - BitMatrix
     * 参数 points - Array<ResultPoint>
     */
    public init(bits: BitMatrix, points: Array<ResultPoint>)

    /*
     * 获取 Bits
     * 返回值 BitMatrix - BitMatrix
     */
    public func getBits(): BitMatrix

    /*
     * 获取 Points
     * 返回值 Array<ResultPoint> - Array<ResultPoint>
     */
    public func getPoints(): Array<ResultPoint>
}

public open class Dimension {
    /*
     * 构造
     * 参数 width - Int64
     * 参数 height - Int64
     */
    public init(width: Int64, height: Int64)

    /*
     * 获取 Width
     * 返回值 Int64 - Width
     */
    public func getWidth(): Int64

    /*
     * 获取 Height
     * 返回值 Int64 - Height
     */
    public func getHeight(): Int64

    /*
     * 判等
     * 参数 other - Any 值
     * 返回值 Bool - Bool
     */
    public func equals(other: Any): Bool

    /*
     * 计算哈希
     * 返回值 Int64  - 哈希
     */  
    public func hashCode(): Int64

    /*
     * 转字符串
     * 返回值 String - String
     */
    public func toString(): String
}

public class ECIEncoderSet {
    /*
     * 构造
     * 参数 stringToEncodeIn - UTF32String
     * 参数 priorityCharset - MyCharset
     * 参数 fnc1 - Int64
     */
    public init(stringToEncodeIn: UTF32String, priorityCharset: MyCharset, fnc1: Int64)

    /*
     * 获取 length
     * 返回值 Int64 - Height
     */
    public func length(): Int64

    /*
     * 获取 CharsetName
     * 参数 index - Int64
     * 返回值 String - String
     */
    public func getCharsetName(index: Int64): String

    /*
     * 获取 Charset
     * 参数 index - Int64
     * 返回值 MyCharset - MyCharset
     */
    public func getCharset(index: Int64): MyCharset

    /*
     * 获取 ECIValue
     * 参数 encoderIndex - Int64
     * 返回值 Int64 - Int64
     */
    public func getECIValue(encoderIndex: Int64): Int64

    /*
     * 获取 PriorityEncoderIndex
     * 返回值 Int64 - Int64
     */
    public func getPriorityEncoderIndex(): Int64

    /*
     * 获取 canEncode
     * 参数 c - Char
     * 参数 encoderIndex - Int64
     * 返回值 Bool - Bool
     */
    public func canEncode(c: Char, encoderIndex: Int64): Bool

    /*
     * 编码
     * 参数 c - Char
     * 参数 encoderIndex - Int64
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public func encode(c: Char, encoderIndex: Int64): Array<UInt8>

    /*
     * 编码
     * 参数 s - UTF32String
     * 参数 encoderIndex - Int64
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public func encode(s: UTF32String, encoderIndex: Int64): Array<UInt8>
}

public class ECIStringBuilder <: ToString {
    /*
     * 构造
     */
    public init()

    /*
     * 构造
     * 参数 initialCapacity - Int64
     */
    public init(initialCapacity: Int64)

    /*
     * 添加值
     * 参数 value - Char
     */
    public func append(value: Char)

    /*
     * 添加值
     * 参数 value - Byte
     */
    public func append(value: Byte)

    /*
     * 添加值
     * 参数 value - String
     */
    public func append(value: String)

    /*
     * 添加值
     * 参数 value - Int64
     */
    public func append(value: Int64)

    /*
     * 添加值
     * 参数 value - Int64
     */
    public func appendECI(value: Int64)

    /*
     * 添加值
     * 参数 value - ArrayList<Char>
     */
    public func appendCharacters(value: ArrayList<Char>)

    /*
     * 获取长度
     * 返回值 Int64 - Int64
     */
    public func length(): Int64

    /*
     * 获取是否为空
     * 返回值 Bool - Bool
     */
    public func isEmpty(): Bool

    /*
     * 获取字符串
     * 返回值 String - String
     */
    public func toString(): String
}

public enum EncodeHintType <: Hashable & Equatable<EncodeHintType> {
    | ERROR_CORRECTION
    | CHARACTER_SET
    | DATA_MATRIX_SHAPE
    | DATA_MATRIX_COMPACT
    | MIN_SIZE
    | MAX_SIZE
    | MARGIN
    | PDF417_COMPACT
    | PDF417_COMPACTION
    | PDF417_DIMENSIONS
    | PDF417_AUTO_ECI
    | AZTEC_LAYERS
    | QR_VERSION
    | QR_MASK_PATTERN
    | QR_COMPACT
    | GS1_FORMAT
    | FORCE_CODE_SET
    | FORCE_C40
    | CODE128_COMPACT

    /*
     * 获取对应数字
     * 参数 result - EncodeHintType
     * 返回值 Int64 - Int64
     */
    public func GetEncodeHintTypeNum(result: EncodeHintType): Int64

    /*
     * 判等
     * 参数 that - MyCharset
     * 返回值 Bool  - 是否相等
     */  
    public operator func ==(right: EncodeHintType): Bool

    /*
     * 判不等
     * 参数 that - MyCharset
     * 返回值 Bool  - 判不等
     */ 
    public operator func !=(right: EncodeHintType): Bool

    /*
     * 计算哈希
     * 返回值 Int64  - 哈希
     */  
    public func hashCode(): Int64

    /*
     * 获取HashMapValue
     * 参数 key - EncodeHintType
     * 参数 value - Any
     * 返回值 String - String
     */
    public static func getHashMapValue(key: EncodeHintType, value: Any): String
}

public open class FormatException <: ReaderException {
    /*
     * 构造
     */
    public init()

    /*
     * 构造
     * 参数 msg - String
     */
    public init(msg: String)

    /*
     * 获取一个异常
     * 返回值 FormatException - FormatException
     */
    public static func getFormatInstance(): FormatException

    /*
     * 获取一个异常
     * 参数 ex - Exception
     * 返回值 FormatException - FormatException
     */
    public static func getFormatInstance(ex: Exception): FormatException
}

public open class GlobalHistogramBinarizer <: Binarizer {
    /*
     * 构造
     * 参数 source - LuminanceSource
     */
    public init(source: LuminanceSource)

    /*
     * 获取一个BitArray
     * 参数 y - Int64
     * 参数 r - BitArray
     * 返回值 BitArray - BitArray
     */
    public open func getBlackRow(y: Int64, r: BitArray): BitArray

    /*
     * 获取一个BlackMatrix
     * 返回值 BitMatrix - BitMatrix
     */
    public open func getBlackMatrix(): BitMatrix

    /*
     * 获取一个Binarizer
     * 参数 source - LuminanceSource
     * 返回值 Binarizer - Binarizer
     */
    public open func createBinarizer(source: LuminanceSource): Binarizer
}

public abstract class GridSampler {
    /*
     * 设置 newGridSampler
     * 参数 newGridSampler - GridSampler
     */
    public static func setGridSampler(newGridSampler: GridSampler): Unit

    /*
     * 获取一个 GridSampler
     * 返回值 GridSampler - GridSampler
     */
    public static func getInstance(): GridSampler

    /*
     * 获取一个 BitMatrix
     * 返回值 BitMatrix - BitMatrix
     */
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
    ): BitMatrix

    /*
     * 获取一个 BitMatrix
     * 返回值 BitMatrix - BitMatrix
     */
    public func sampleGrid(
        image: BitMatrix,
        dimensionX: Int64,
        dimensionY: Int64,
        transform: PerspectiveTransform
    ): BitMatrix
}

public class HybridBinarizer <: GlobalHistogramBinarizer {

    /*
     * 构造
     * 参数 source - LuminanceSource
     */
    public init(source: LuminanceSource)

    /*
     * 获取一个 BlackMatrix
     * 返回值 BitMatrix - BitMatrix
     */
    public override func getBlackMatrix(): BitMatrix

    /*
     * 创建一个 Binarizer
     * 参数 source - LuminanceSource
     * 返回值 Binarizer - Binarizer
     */
    public override func createBinarizer(source: LuminanceSource): Binarizer
}

public open class InvertedLuminanceSource <: LuminanceSource {
    /*
     * 构造
     * 参数 delegate - LuminanceSource
     */
    public init(delegate: LuminanceSource)

    /*
     * 获取一个 Row
     * 参数 y - Int64
     * 参数 row - Array<UInt8>
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public override func getRow(y: Int64, row: Array<UInt8>): Array<UInt8>

    /*
     * 获取一个 Matrix
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public override func getMatrix(): Array<UInt8>

    /*
     * 获取 isCropSupporte
     * 返回值 Bool - Bool
     */
    public override func isCropSupported(): Bool

    /*
     * 获取 crop
     * 参数 left - Int64
     * 参数 top - Int64
     * 参数 width - Int64
     * 参数 height - Int64
     * 返回值 LuminanceSource - LuminanceSource
     */
    public override func crop(left: Int64, top: Int64, width: Int64, height: Int64): LuminanceSource

    /*
     * 获取 isRotateSupported
     * 返回值 Bool - Bool
     */
    public override func isRotateSupported(): Bool

    /*
     * 获取 invert
     * 返回值 LuminanceSource - LuminanceSource
     */
    public override func invert(): LuminanceSource

    /*
     * 获取 rotateCounterClockwise
     * 返回值 LuminanceSource - LuminanceSource
     */
    public override func rotateCounterClockwise(): LuminanceSource

    /*
     * 获取 rotateCounterClockwise45
     * 返回值 LuminanceSource - LuminanceSource
     */
    public override func rotateCounterClockwise45(): LuminanceSource 
}

public abstract class LuminanceSource {
    /*
     * 构造
     * 参数 delegate - LuminanceSource
     */
    public init()

    /*
     * 获取一个 Row
     * 参数 y - Int64
     * 参数 row - Array<UInt8>
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public open func getRow(y: Int64, row: Array<UInt8>): Array<UInt8>

    /*
     * 获取一个 Matrix
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public open func getMatrix(): Array<UInt8>

    /*
     * 获取 Width
     * 返回值 Int64 - Width
     */
    public func getWidth(): Int64

    /*
     * 获取 Height
     * 返回值 Int64 - Height
     */
    public func getHeight(): Int64

    /*
     * 获取是否可裁剪
     * 返回值 Bool - 可裁剪
     */ 
    public open func isCropSupported(): Bool

    /*
     * 裁剪
     * 参数 left - Int64
     * 参数 top - Int64
     * 参数 width - Int64
     * 参数 height - Int64
     * 返回值 BinaryBitmap - BinaryBitmap
     */ 
    public open func crop(left: Int64, top: Int64, width: Int64, height: Int64): LuminanceSource

    /*
     * 获取是否可旋转
     * 返回值 Bool - 是否可旋转
     */ 
    public open func isRotateSupported(): Bool

    /*
     * 获取 invert
     * 返回值 LuminanceSource - LuminanceSource
     */
    public open func invert(): LuminanceSource

    /*
     * 获取 rotateCounterClockwise
     * 返回值 LuminanceSource - LuminanceSource
     */
    public override func rotateCounterClockwise(): LuminanceSource

    /*
     * 获取 rotateCounterClockwise45
     * 返回值 LuminanceSource - LuminanceSource
     */
    public func rotateCounterClockwise45(): BinaryBitmap

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String
}

public open class MinimalECIInput <: ECIInput {
    /*
     * 构造
     * 参数 stringToEncode - UTF32String
     * 参数 priorityCharset - MyCharset
     * 参数 fnc1 - Int64
     */
    public init(stringToEncode: UTF32String, priorityCharset: MyCharset, fnc1: Int64)

    /*
     * 获取 FNC1Character
     * 返回值 Int64 - Int64
     */
    public func getFNC1Character(): Int64

    /*
     * 获取 length
     * 返回值 Int64 - Int64
     */
    public func length(): Int64

    /*
     * 获取 haveNCharacters
     * 参数 index - Int64
     * 参数 n - Int64
     * 返回值 Bool - Bool
     */
    public func haveNCharacters(index: Int64, n: Int64): Bool

    /*
     * 获取 charAt
     * 参数 index - Int64
     * 返回值 Char - Char
     */
    public func charAt(index: Int64): Char

    /*
     * 获取 charAt
     * 参数 start - Int64
     * 参数 end - Int64
     * 返回值 UTF32String - UTF32String
     */
    public func subSequence(start: Int64, end: Int64): UTF32String

    /*
     * 获取 ECI
     * 参数 index - Int64
     * 返回值 index - index
     */
    public func isECI(index: Int64): index

    /*
     * 获取 FNC1
     * 参数 index - Int64
     * 返回值 Bool - Bool
     */
    public func isFNC1(index: Int64): Bool

    /*
     * 获取 ECIValue
     * 参数 index - Int64
     * 返回值 Int64 - Int64
     */
    public func getECIValue(index: Int64): Int64

    /*
     * 转字符串
     * 返回值 String - 字符串
     */ 
    public func toString(): String
}

public open class NotFoundException <: ReaderException {
    /*
     * 构造
     */
    public init()

    /*
     * 构造
     * 参数 msg - String
     */
    public init(msg: String)

    /*
     * 返回一个异常
     * 返回值 NotFoundException - NotFoundException
     */
    public static func getNotFoundInstance(): NotFoundException
}

public class PerspectiveTransform {
    /*
     * 返回一个 PerspectiveTransform
     * 返回值 PerspectiveTransform - PerspectiveTransform
     */
    public static func quadrilateralToQuadrilateral(
        x0: Float64,
        y0: Float64,
        x1: Float64,
        y1: Float64,
        x2: Float64,
        y2: Float64,
        x3: Float64,
        y3: Float64,
        x0p: Float64,
        y0p: Float64,
        x1p: Float64,
        y1p: Float64,
        x2p: Float64,
        y2p: Float64,
        x3p: Float64,
        y3p: Float64
    ): PerspectiveTransform 

    /*
     * 处理PerspectiveTransform
     * 参数 points -  Array<Float64>
     */
    public func transformPoints(points: Array<Float64>)

    /*
     * 处理 squareToQuadrilateral
     * 返回值 PerspectiveTransform -  PerspectiveTransform
     */
    public static func squareToQuadrilateral(
        x0: Float64,
        y0: Float64,
        x1: Float64,
        y1: Float64,
        x2: Float64,
        y2: Float64,
        x3: Float64,
        y3: Float64
    ): PerspectiveTransform

    /*
     * 处理 quadrilateralToSquare
     * 返回值 PerspectiveTransform -  PerspectiveTransform
     */
    public static func quadrilateralToSquare(
        x0: Float64,
        y0: Float64,
        x1: Float64,
        y1: Float64,
        x2: Float64,
        y2: Float64,
        x3: Float64,
        y3: Float64
    ): PerspectiveTransform
}

public open class PlanarYUVLuminanceSource <: LuminanceSource {
    /*
     * 构造
     */
    public init(
        yuvData: Array<UInt8>,
        dataWidth: Int64,
        dataHeight: Int64,
        left: Int64,
        top: Int64,
        width: Int64,
        height: Int64,
        reverseHorizontalBool: Bool
    )

    /*
     * 获取指定行的像素数据，并将其存储到给定的 BitArray 对象中
     * 参数 y - 指定行的纵坐标
     * 参数 row - 存储像素数据的 BitArray 对象
     */
    public override func getRow(y: Int64, rowIn: Array<UInt8>): Array<UInt8>

    /*
     * 获取一个 Matrix
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public override func getMatrix(): Array<UInt8>

    /*
     * 获取 isCropSupporte
     * 返回值 Bool - Bool
     */
    public override func isCropSupported(): Bool 

    /*
     * 获取 crop
     * 参数 left - Int64
     * 参数 top - Int64
     * 参数 width - Int64
     * 参数 height - Int64
     * 返回值 LuminanceSource - LuminanceSource
     */
    public override func crop(
        left: Int64,
        top: Int64,
        width: Int64,
        height: Int64
    ): LuminanceSource 

    /*
     * 获取一个 renderThumbnail
     * 返回值 Array<Int64> - Array<Int64>
     */
    public func renderThumbnail(): Array<Int64>

    /*
     * 获取 ThumbnailWidth
     * 返回值 Int64 - Int64
     */
    public func getThumbnailWidth(): Int64

    /*
     * 获取 ThumbnailHeight
     * 返回值 Int64 - Int64
     */
    public func getThumbnailHeight(): Int64
}

public open class ReaderException <: Exception {
    /*
     * 构造
     */
    public init()

    /*
     * 构造
     */
    public init(msg: String) 
}

public enum ResultMetadataType <: Equatable<ResultMetadataType> & Hashable & ToString {
    | OTHER
    | ORIENTATION
    | BYTE_SEGMENTS
    | ERROR_CORRECTION_LEVEL
    | ISSUE_NUMBER
    | SUGGESTED_PRICE
    | POSSIBLE_COUNTRY
    | UPC_EAN_EXTENSION
    | PDF417_EXTRA_METADATA
    | STRUCTURED_APPEND_SEQUENCE
    | STRUCTURED_APPEND_PARITY
    | SYMBOLOGY_IDENTIFIER

    /*
     * 获取对应数字
     * 参数 result - ResultMetadataType
     * 返回值 Int64 - Int64
     */
    public func GetResultMetadataTypeNum(result: ResultMetadataType): Int64

    /*
     * 判等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否相等
     */
    public operator func ==(right: ResultMetadataType): Bool

    /*
     * 判不等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否不等
     */
    public operator func !=(right: ResultMetadataType): Bool

    /*
     * 获取哈希值
     * 返回值 Int64 - 返回实例类型的哈希值
     */
    public func hashCode(): Int64

    /*
     * 转字符串
     * 返回值 String - String
     */
    public func toString(): String

    /*
     * 获取对应枚举
     * 参数 data - String
     * 返回值 ResultMetadataType - ResultMetadataType
     */
    public func valueOf(data: String): ResultMetadataType
}

public open class ResultPoint {
    /*
     * 构造
     */
    public init()

    /*
     * 构造
     */
    public init(x: Float32, y: Float32)

    /*
     * 获取设置横坐标
     * 返回值 Int64 - 横坐标
     */
    public func getX(): Float32

    /*
     * 获取设置纵坐标
     * 返回值 Int64 - 纵坐标
     */
    public func getY(): Float32

    /*
     * 判等
     * 参数 o - Object
     * 返回值 Bool  - 是否相等
     */  
    public func equals(other: ResultPoint): Bool

    /*
     * 计算哈希值
     * 返回值 Int64  - 哈希值
     */ 
    public func hashCode(): Int64

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String

    /*
     * 模式
     * 参数 patterns  - Array<ResultPoint>
     */ 
    public static func orderBestPatterns(patterns: Array<ResultPoint>)

    /*
     * 距离
     * 参数 patterns  - ResultPoint
     * 参数 pattern2  - ResultPoint
     * 返回值 Float32  - Float32
     */ 
    public static func distance(pattern1: ResultPoint, pattern2: ResultPoint): Float32
}

public class Result {
    /*
     * 构造
     */
    public init()

    /*
     * 构造
     */
    public init(
        text: String,
        rawBytes: Array<UInt8>,
        resultPoints: Array<ResultPoint>,
        format: BarcodeFormat
    )
    /*
     * 构造
     */
    public init(
        text: String,
        rawBytes: Array<UInt8>,
        resultPoints: Array<ResultPoint>,
        format: BarcodeFormat,
        timestamp: Int64
    )

    /*
     * 构造
     */
    public init(
        text: String,
        rawBytes: Array<UInt8>,
        numBits: Int64,
        resultPoints: Array<ResultPoint>,
        format: BarcodeFormat,
        timestamp: Int64
    )

    /*
     * 获取 Text
     * 返回值 String   - Text
     */ 
    public func getText(): String

    /*
     * 获取 RawBytes
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public func getRawBytes(): Array<UInt8>

    /*
     * 获取 NumBits
     * 返回值 Int64 - NumBits
     */
    public func getNumBits(): Int64

    /*
     * 获取 ResultPoints
     * 返回值 Array<ResultPoint> - Array<ResultPoint>
     */
    public func getResultPoints(): Array<ResultPoint>

    /*
     * 获取 BarcodeFormat
     * 返回值 BarcodeFormat - BarcodeFormat
     */
    public func getBarcodeFormat(): BarcodeFormat

    /*
     * 获取 ResultMetadata
     * 返回值 HashMap<ResultMetadataType, Any> - HashMap<ResultMetadataType, Any>
     */
    public func getResultMetadata(): HashMap<ResultMetadataType, Any>

    /*
     * 设置 Metadata
     * 参数 rmtype - ResultMetadataType
     * 参数 value - ResultMetadataType
     */
    public func putMetadata(rmtype: ResultMetadataType, value: Any)

    /*
     * 设置 AllMetadata
     * 参数 rmtype - HashMap<ResultMetadataType, Any>
     */
    public func putAllMetadata(metadata: HashMap<ResultMetadataType, Any>)

    /*
     * 设置 ResultPoints
     * 参数 newPoints - Array<ResultPoint>
     */
    public func addResultPoints(newPoints: Array<ResultPoint>)

    /*
     * 获取 Timestamp
     * 返回值 Int64 - Int64
     */
    public func getTimestamp(): Int64

    /*
     * 获取字符串
     * 返回值 String - String
     */
    public func toString(): String
}

public open class RGBLuminanceSource <: LuminanceSource {
    /*
     * 构造
     */
    public init(width: Int64, height: Int64, pixels: Array<Int64>) 

    /*
     * 获取一个 Row
     * 参数 y - Int64
     * 参数 row - Array<UInt8>
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public override func getRow(y: Int64, rowin: Array<UInt8>): Array<UInt8>

    /*
     * 获取一个 Matrix
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public override func getMatrix(): Array<UInt8>

    /*
     * 获取 isCropSupporte
     * 返回值 Bool - Bool
     */
    public override func isCropSupported(): Bool

    /*
     * 获取 crop
     * 参数 left - Int64
     * 参数 top - Int64
     * 参数 width - Int64
     * 参数 height - Int64
     * 返回值 LuminanceSource - LuminanceSource
     */
    public override func crop(left: Int64, top: Int64, width: Int64, height: Int64): LuminanceSource
}

public class StringUtils {
    /*
     * 编码推测
     * 参数 bytes - Array<Byte>
     * 参数 hints - HashMap<DecodeHintType, Any>
     */
    public static func guessEncoding(bytes: Array<Byte>, hints: HashMap<DecodeHintType, Any>) 

    /*
     * 编码推测
     * 参数 bytes - Array<Byte>
     * 参数 hints - HashMap<DecodeHintType, Any>
     */
    public static func guessCharset(bytes: Array<Byte>, hints: HashMap<DecodeHintType, Any>): MyCharset
}

public open class WriterException <: Exception {
    /*
     * 构造
     */
    public init()

    /*
     * 构造
     */
    public init(message: String)

    /*
     * 构造
     */
    public init(cause: Exception)
}

public class DecodedBitStreamParser {
    /*
     * 解码
     * 参数 bytes - Array<Byte>
     * 返回值 DecoderResult - DecoderResult
     */
    public static func decode(bytes: Array<UInt8>): DecoderResult
}

public class Version {
    /*
     * 获取 VersionNumber
     * 返回值 Int64 - Int64
     */
    public func getVersionNumber(): Int64

    /*
     * 获取 SymbolSizeRows
     * 返回值 Int64 - Int64
     */
    public func getSymbolSizeRows(): Int64

    /*
     * 获取 SymbolSizeColumns
     * 返回值 Int64 - Int64
     */
    public func getSymbolSizeColumns(): Int64

    /*
     * 获取 DataRegionSizeRows
     * 返回值 Int64 - Int64
     */
    public func getDataRegionSizeRows(): Int64

    /*
     * 获取 DataRegionSizeColumns
     * 返回值 Int64 - Int64
     */
    public func getDataRegionSizeColumns(): Int64

    /*
     * 获取 TotalCodewords
     * 返回值 Int64 - Int64
     */
    public func getTotalCodewords(): Int64

    /*
     * 获取 VersionForDimension
     * 参数 numRows - Int64
     * 参数 numColumns - Int64
     * 返回值 Version - Version
     */
    public static func getVersionForDimensions(numRows: Int64, numColumns: Int64): Version

    /*
     * 获取字符串
     * 返回值 String - String
     */
    public func toString(): String
}

public class ASCIIEncoder <: Encoder {
    /*
     * 获取 EncodingMode
     * 返回值 Int64 - Int64
     */
    public func getEncodingMode(): Int64

    /*
     * 编码
     * 参数 context - EncoderContext
     */
    public func encode(context: EncoderContext)
}

public open class C40Encoder <: Encoder {
    /*
     * 获取 EncodingMode
     * 返回值 Int64 - Int64
     */
    public open func getEncodingMode(): Int64 

    /*
     * 编码
     * 参数 context - EncoderContext
     */
    public open func encode(context: EncoderContext): Unit

    /*
     * 编码
     * 参数 context - EncoderContext
     * 参数 buffer - ArrayList<Char>
     */
    public open func handleEOD(context: EncoderContext, buffer: ArrayList<Char>) 

    /*
     * 编码 Char
     * 参数 c - Char
     * 参数 sb - ArrayList<Char>
     * 返回值 Int64 - Int64
     */
    public open func encodeChar(c: Char, sb: ArrayList<Char>): Int64
}

public open class DefaultPlacement {
    /*
     * 构造
     */
    public init(codewords: String, numcols: Int64, numrows: Int64)

    /*
     * 获取 Numrows
     * 返回值 Int64 - Int64
     */
    public func getNumrows(): Int64

    /*
     * 获取 Numcols
     * 返回值 Int64 - Int64
     */
    public func getNumcols(): Int64

    /*
     * 获取 Bits
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public func getBits(): Array<UInt8>

    /*
     * 获取 Bits
     * 参数 col - Int64
     * 参数 row - Int64
     * 返回值 Bool - Bool
     */
    public func getBit(col: Int64, row: Int64): Bool

    /*
     * 替换
     */
    public func place()
}

public class EncoderContext {
    /*
     * 设置 SymbolShape
     * 参数 shape - SymbolShapeHint
     */
    public func setSymbolShape(shape: SymbolShapeHint)

    /*
     * 设置 SizeConstraints
     * 参数 minSize - Dimension
     * 参数 maxSize - Dimension
     */
    public func setSizeConstraints(minSize: ?Dimension, maxSize: ?Dimension)

    /*
     * 获取 Message
     * 返回值 UTF32String - UTF32String
     */
    public func getMessage(): UTF32String

    /*
     * 设置 count
     * 参数 Int64 - Int64
     */
    public func setSkipAtEnd(count: Int64)

    /*
     * 获取 CurrentChar
     * 返回值 Char - Char
     */
    public func getCurrentChar(): Char

    /*
     * 获取 Current
     * 返回值 Char - Char
     */
    public func getCurrent(): Char

    /*
     * 获取 Codewords
     * 返回值 ArrayList<Char> - ArrayList<Char>
     */
    public func getCodewords(): ArrayList<Char>

    /*
     * 设置 Codewords
     * 参数 codewords - UTF32String
     */
    public func writeCodewords(codewords: UTF32String)

    /*
     * 设置 codeword
     * 参数 codeword - Char
     */
    public func writeCodeword(codeword: Char)

    /*
     * 获取 CodewordCount
     * 返回值 Int64 - Int64
     */
    public func getCodewordCount(): Int64

    /*
     * 获取 NewEncoding
     * 返回值 Int64 - Int64
     */
    public func getNewEncoding(): Int64

    /*
     * 设置 EncoderChange
     * 参数 encoding - Int64
     */
    public func signalEncoderChange(encoding: Int64)

    /*
     * resetEncoderSignal
     */
    public func resetEncoderSignal()

    /*
     * 获取 hasMoreCharacters
     * 返回值 Bool - Bool
     */
    public func hasMoreCharacters(): Bool

    /*
     * 获取 TotalMessageCharCount
     * 返回值 Int64 - Int64
     */
    public func getTotalMessageCharCount(): Int64

    /*
     * 获取 RemainingCharacters
     * 返回值 Int64 - Int64
     */
    public func getRemainingCharacters(): Int64

    /*
     * 获取 SymbolInfo
     * 返回值 SymbolInfo - SymbolInfo
     */
    public func getSymbolInfo(): ?SymbolInfo

    /*
     * 更新 SymbolInfo
     */
    public func updateSymbolInfo()

    /*
     * 获取 SymbolInfo
     * 返回值 len - Int64
     */
    public func updateSymbolInfo(len: Int64)

    /*
     * 重置 SymbolInfo
     */
    public func resetSymbolInfo()
}

public class ErrorCorrection {
    /*
     * 为编码报文创建 ECC200 错误校正
     * 参数 codewords - UTF32String
     * 参数 symbolInfo - SymbolInfo
     * 返回值 String - String
     */
    public static func encodeECC200(codewords: UTF32String, symbolInfo: SymbolInfo): String 
}

public class HighLevelEncoder {
    /*
     * 编码
     * 参数 msg - UTF32String
     * 参数 UTF32String - UTF32String
     */
    public static func encodeHighLevel(msg: UTF32String): UTF32String

    /*
     * 编码
     * 参数 codewords - UTF32String
     * 参数 symbolInfo - SymbolInfo
     * 返回值 UTF32String - UTF32String
     */
    public static func encodeHighLevel(
        msg: UTF32String,
        shape: SymbolShapeHint,
        minSize: ?Dimension,
        maxSize: ?Dimension
    ): UTF32String

    /*
     * 编码
     * 参数 codewords - UTF32String
     * 参数 symbolInfo - SymbolInfo
     * 返回值 UTF32String - UTF32String
     */
    public static func encodeHighLevel(
        msg: UTF32String,
        shape: SymbolShapeHint,
        minSize: ?Dimension,
        maxSize: ?Dimension,
        forceC40: Bool
    ): UTF32String

    /*
     * 确定连续数字计数
     * 参数 msg - UTF32String
     * 参数 startpos - Int64
     * 返回值 Int64 - Int64
     */
    public static func determineConsecutiveDigitCount(msg: UTF32String, startpos: Int64): Int64
}

public enum Mode <: Equatable<Mode> {
    | ASCII
    | C40
    | TEXT
    | X12
    | EDF
    | B256

    /*
     * 获取模式数字
     * 返回值 Int64 - Int64
     */
    public func GetModeNum(): Int64

    /*
     * 判等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否相等
     */
    public operator func ==(right: Mode): Bool

    /*
     * 判不等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否不等
     */
    public operator func !=(right: Mode): Bool
}

public class Input <: MinimalECIInput {
    /*
     * 获取 MacroId
     * 返回值 Int64 - Int64
     */
    public func getMacroId(): Int64 

    /*
     * 获取 ShapeHint
     * 返回值 SymbolShapeHint - SymbolShapeHint
     */
    public func getShapeHint(): SymbolShapeHint
}

public class MinimalEncoder {
    /*
     * 判断 ExtendedASCII
     * 参数 ch - Char
     * 参数 fnc1 - Int64
     * 返回值 Bool - 是否相等
     */
    public static func isExtendedASCII(ch: Char, fnc1: Int64): Bool

    /*
     * 判断 InC40Shift1Set
     * 参数 ch - Char
     * 返回值 Bool - 是否相等
     */
    public static func isInC40Shift1Set(ch: Char): Bool

    /*
     * 判断 isInC40Shift2Set
     * 参数 ch - Char
     * 参数 fnc1 - Int64
     * 返回值 Bool - 是否相等
     */
    public static func isInC40Shift2Set(ch: Char, fnc1: Int64): Bool

    /*
     * 判断 isInTextShift1Set
     * 参数 ch - Char
     * 返回值 Bool - 是否相等
     */
    public static func isInTextShift1Set(ch: Char): Bool

    /*
     * 判断 isInTextShift2Set
     * 参数 ch - Char
     * 参数 fnc1 - Int64
     * 返回值 Bool - 是否相等
     */
    public static func isInTextShift2Set(ch: Char, fnc1: Int64): Bool

    /*
     * 编码
     * 参数 codewords - UTF32String
     * 参数 symbolInfo - SymbolInfo
     * 返回值 UTF32String - UTF32String
     */
    public static func encodeHighLevel(msg: UTF32String): UTF32String

    /*
     * 编码
     * 参数 codewords - UTF32String
     * 参数 symbolInfo - SymbolInfo
     * 返回值 UTF32String - UTF32String
     */
    public static func encodeHighLevel(
        msg0: UTF32String,
        priorityCharset: MyCharset,
        fnc1: Int64,
        shape: SymbolShapeHint
    ): UTF32String

    /*
     * 获取 NumberOfC40Words
     * 参数 ch - Char
     * 返回值 Int64 - Int64
     */
    public static func getNumberOfC40Words(input: Input, start: Int64, c40: Bool, characterLength: Array<Int64>): Int64

    /*
     * 添加 Edges
     * 参数 input - Input
     * 参数 edges - Array<Array<?Edge>>
     * 参数 start - Int64
     * 参数 previous - Edge
     */
    public static func addEdges(input: Input, edges: Array<Array<?Edge>>, start: Int64, previous: ?Edge)

    /*
     * 编码
     * 参数 input - Input
     * 返回值 Result - Result
     */
    public static func encodeMinimally(input: Input): Result
}

public enum SymbolShapeHint <: Equatable<SymbolShapeHint> & ToString {

    /*
     * 获取 GetSymbolShapeHintNum
     * 参数 result - SymbolShapeHint
     * 返回值 Int64 - Int64
     */
    public func GetSymbolShapeHintNum(result: SymbolShapeHint): Int64

    /*
     * 判等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否相等
     */
    public operator func ==(right: SymbolShapeHint): Bool

    /*
     * 判不等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否不等
     */
    public operator func !=(right: SymbolShapeHint): Bool

    /*
     * 转换字符串
     * 返回值 String  - String
     */  
    public func toString()
}

public open class SymbolInfo {
    /*
     * 覆盖符号集
     * 参数 ride - Array<SymbolInfo>
     */
    public static func overrideSymbolSet(ride: Array<SymbolInfo>)

    /*
     * 构造
     */
    public init(
        rectangular: Bool,
        dataCapacity: Int64,
        errorCodewords: Int64,
        matrixWidth: Int64,
        matrixHeight: Int64,
        dataRegions: Int64
    ) 

    /*
     * 锁定
     * 参数 dataCodewords - Int64
     * 返回值 SymbolInfo  - SymbolInfo
     */
    public static func lookup(dataCodewords: Int64): ?SymbolInfo

    /*
     * 锁定
     * 参数 dataCodewords - Int64
     * 参数 shape - SymbolShapeHint
     * 返回值 SymbolInfo  - SymbolInfo
     */
    public static func lookup(dataCodewords: Int64, shape: SymbolShapeHint): ?SymbolInfo

    /*
     * 锁定
     * 参数 dataCodewords - Int64
     * 参数 shape - SymbolShapeHint
     * 参数 fail - Bool
     * 返回值 SymbolInfo  - SymbolInfo
     */
    public static func lookup(dataCodewords: Int64, allowRectangular: Bool, fail: Bool): ?SymbolInfo

    /*
     * 锁定
     * 参数 dataCodewords - Int64
     * 参数 shape - SymbolShapeHint
     * 参数 fail - Bool
     * 返回值 SymbolInfo  - SymbolInfo
     */
    public static func lookup(
        dataCodewords: Int64,
        shape: SymbolShapeHint,
        minSize: ?Dimension,
        maxSize: ?Dimension,
        fail: Bool
    ): ?SymbolInfo

    /*
     * 获取 HorizontalDataRegions
     * 返回值 Int64 - Int64
     */
    public func getHorizontalDataRegions(): Int64

    /*
     * 获取 VerticalDataRegions
     * 返回值 Int64 - Int64
     */
    public func getVerticalDataRegions(): Int64

    /*
     * 获取 SymbolDataWidth
     * 返回值 Int64 - Int64
     */
    public func getSymbolDataWidth(): Int64

    /*
     * 获取 SymbolDataWidth
     * 返回值 Int64 - Int64
     */
    public func getSymbolDataWidth(): Int64

    /*
     * 获取 SymbolWidth
     * 返回值 Int64 - Int64
     */
    public func getSymbolWidth(): Int64

    /*
     * 获取 SymbolHeight
     * 返回值 Int64 - Int64
     */
    public func getSymbolHeight(): Int64

    /*
     * 获取 CodewordCount
     * 返回值 Int64 - Int64
     */
    public func getCodewordCount(): Int64

    /*
     * 获取 InterleavedBlockCount
     * 返回值 Int64 - Int64
     */
    public open func getInterleavedBlockCount(): Int64

    /*
     * 获取 DataCapacity
     * 返回值 Int64 - Int64
     */
    public func getDataCapacity(): Int64

    /*
     * 获取 ErrorCodewords
     * 返回值 Int64 - Int64
     */
    public func getErrorCodewords(): Int64

    /*
     * 获取 DataLengthForInterleavedBlock
     * 返回值 Int64 - Int64
     */
    public open func getDataLengthForInterleavedBlock(index: Int64): Int64

    /*
     * 获取 ErrorLengthForInterleavedBlock
     * 返回值 Int64 - Int64
     */
    public func getErrorLengthForInterleavedBlock(index: Int64): Int64

    /*
     * 转换字符串
     * 返回值 String  - String
     */  
    public func toString(): String 
}

public class TextEncoder <: C40Encoder {
    /*
     * 获取 EncodingMode
     * 返回值 Int64 - Int64
     */
    public func getEncodingMode(): Int64

    /*
     * 编码 Char
     * 参数 c - Char
     * 参数 sb - ArrayList<Char>
     * 返回值 Int64 - Int64
     */
    public func encodeChar(c: Char, sb: ArrayList<Char>): Int64
}

public class BitMatrixParser {
    /*
     * 构造
     * 参数 bitMatrix - BitMatrix
     */
    public init(bitMatrix: BitMatrix)

    /*
     * 获取 readCodewords
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public func readCodewords(): Array<UInt8>
}

public class DecodedBitStreamParser {
    /*
     * 编码
     * 参数 bytes - Array<UInt8>
     * 参数 mode - Int64
     * 返回值 DecoderResult - DecoderResult
     */
    public static func decode(bytes: Array<UInt8>, mode: Int64): DecoderResult
}

public class MultiDetector <: Detector {
    /*
     * 构造
     * 参数 image - BitMatrix
     */
    public init(image: BitMatrix)

    /*
     * 解码
     * 参数 hints - 解码参数配置
     * 返回值 ArrayList<DetectorResult>  - ArrayList<DetectorResult> 
     */
    public func detectMulti(hints: HashMap<DecodeHintType, Any>): ArrayList<DetectorResult> 

}

public class MultiFinderPatternFinder <: FinderPatternFinder {
    /*
     * 解码
     * 参数 hints - 解码参数配置
     * 返回值 ArrayList<DetectorResult>  - Array<FinderPatternInfo>
     */
    public func findMulti(hints: HashMap<DecodeHintType, Any>): Array<FinderPatternInfo>
}

public abstract class AbstractExpandedDecoder {
    /*
     * 信息
     * 返回值 String  - String
     */
    public func parseInformation(): String

    /*
     * 创建解码
     * 参数 information - BitArray
     * 返回值 AbstractExpandedDecoder  - AbstractExpandedDecoder
     */
    public static func createDecoder(information: BitArray): AbstractExpandedDecoder
}

public class BitArrayBuilder {
    /*
     * 创建 BitArray
     * 参数 pairs - ArrayList<ExpandedPair>
     * 返回值 BitArray  - BitArray
     */
    public static func buildBitArray(pairs: ArrayList<ExpandedPair>): BitArray
}

public class ExpandedPair {
    /*
     * 构造
     */
    public init(leftChar: ?DataCharacter, rightChar: ?DataCharacter, finderPattern: ?FinderPattern)

    /*
     * 获取 FinderPattern
     * 返回值 FinderPattern  - FinderPattern
     */
    public func getFinderPattern(): ?FinderPattern

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String

    /*
     * 判等
     * 参数 scharset - MyCharset 值
     * 返回值 Bool - Bool
     */
    public func equals(o: Any): Bool

    /*
     * 计算哈希
     * 返回值 Int64  - 哈希
     */  
    public func hashCode(): Int64
}

public class ExpandedRow {
    /*
     * 获取 Pairs
     * 返回值 ArrayList<ExpandedPair>  - ArrayList<ExpandedPair>
     */
    public func getPairs(): ArrayList<ExpandedPair>

    /*
     * 获取 RowNumber
     * 返回值 RowNumber  - ARowNumber
     */
    public func getRowNumber(): Int64 

    /*
     * 判等
     * 参数 otherPairs - MyCharset 值
     * 返回值 Bool - Bool
     */
    public func isEquivalent(otherPairs: ArrayList<ExpandedPair>): Bool

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String 

    /*
     * 判等
     * 参数 scharset - MyCharset 值
     * 返回值 Bool - Bool
     */
    public func equals(o: Any): Bool

    /*
     * 计算哈希
     * 返回值 Int64  - 哈希
     */  
    public func hashCode(): Int64
}

public abstract class AbstractRSSReader <: OneDReader {
    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
}

public class RSSExpandedReader <: AbstractRSSReader {
    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 返回值 ArrayList<ExpandedPair> - 解码结果
     */
    public func decodeRow2pairs(rowNumber: Int64, row: BitArray): ArrayList<ExpandedPair>

    /*
     * 获取当前 RowSize
     * 返回值 Int64 - RowSize
     */
    public func getRows(): ArrayList<ExpandedRow>

    /*
     * 获取当前 Result
     * 返回值 Result - Result
     */
    public static func constructResult(pairs: ArrayList<ExpandedPair>): Result

    /*
     * 获取当前 ExpandedPair
     * 返回值 ExpandedPair - ExpandedPair
     */
    public func retrieveNextPair(row: BitArray, previousPairs: ArrayList<ExpandedPair>, rowNumber: Int64): ExpandedPair
}

public abstract class AbstractRSSReader <: OneDReader {
    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
}

public open class DataCharacter {
    /*
     * 构造
     */  
    public init()

    /*
     * 构造
     */ 
    public init(value: Int64, checksumPortion: Int64)

    /*
     * 获取值
     * 返回值 Int64  - Int64
     */  
    public func getValue(): Int64

    /*
     * 获取ChecksumPortion
     * 返回值 Int64  - Int64
     */  
    public func getChecksumPortion(): Int64

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String

    /*
     * 判等
     * 参数 o - Object 值
     * 返回值 Bool - Bool
     */
    public func equals(o: Object): Bool

    /*
     * 计算哈希
     * 返回值 Int64  - 哈希
     */  
    public func hashCode(): Int64
}

public class FinderPattern {
    /*
     * 获取 Value
     * 返回值 Int64  - Int64
     */ 
    public func getValue(): Int64

    /*
     * 获取 ResultPoints
     * 返回值 Array<Int64>  - Array<Int64>
     */ 
    public func getStartEnd(): Array<Int64>

    /*
     * 获取 ResultPoints
     * 返回值 Array<ResultPoint>  - Array<ResultPoint>
     */  
    public func getResultPoints(): Array<ResultPoint>

    /*
     * 判等
     * 参数 o - Object 值
     * 返回值 Bool - Bool
     */
    public func equals(o: Object): Bool

    /*
     * 计算哈希
     * 返回值 Int64  - 哈希
     */
    public func hashCode(): Int64
}

public class RSSUtils {
    /*
     * 获取 ResultPoints
     * 参数 widths - Array<Int64>
     * 参数 maxWidth - Int64
     * 参数 noNarrow - Bool
     * 返回值 Int64  - Int64
     */  
    public static func getRSSvalue(widths: Array<Int64>, maxWidth: Int64, noNarrow: Bool): Int64
}

public open class EANManufacturerOrgSupport {
    /*
     * 查找国家标识符
     * 参数 productCode - UTF32String
     * 返回值 String  - String
     */  
    public func lookupCountryIdentifier(productCode: UTF32String): String
}

public open class MultiFormatOneDReader <: OneDReader {
    /*
     * 构造
     */ 
    public init(hints: HashMap<DecodeHintType, Any>)

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
    ublic override func reset()
}

public open class MultiFormatUPCEANReader <: OneDReader {
    /*
     * 构造
     */ 
    public init(hints: HashMap<DecodeHintType, Any>)

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
}

public abstract class OneDimensionalCodeWriter <: Writer {
    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contentsin - 要编码的字符串
     * 返回值 Array<Bool> - 编码结果
     */
    public func encode(contents: String): Array<Bool>

    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contentsin - 要编码的字符串
     * 参数 hints - 编码参数配置
     * 返回值 Array<Bool> - 编码结果
     */
    public open func encode(contents: String, hints: HashMap<EncodeHintType, Any>): Array<Bool>

    /*
     * 将内容编码为 BitMatrix 一维条形码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的条形码格式，如果格式不是 BarcodeFormat.UPC_A 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public open func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix

    /*
     * 将内容编码为 BitMatrix 一维条形码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的条形码格式，如果格式不是 BarcodeFormat.UPC_A 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 参数 hints - 编码参数配置
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64,
        hints: HashMap<EncodeHintType, Any>
    ): BitMatrix 

    /*
     * 获取默认边距
     * 返回值 Int64 - 固定返回 10
     */
    public open func getDefaultMargin(): Int64
}

public class BigInteger {
    /*
     * 构造
     */ 
    public init()

    /*
     * 构造
     */ 
    public init(number: String)

    /*
     * 构造
     */ 
    public init(number: String, sign: Bool)

    /*
     * 构造
     */ 
    public init(number: Int64)

    /*
     * 设置数字
     * 参数 number - String
     */
    public func setNumber(number: String)

    /*
     * 获取数字
     */
    public func getNumber()

    /*
     * 设置符号
     * 参数 sign - Bool
     */
    public func setSign(sign: Bool) 

    /*
     * 获取符号
     */
    public func getSign() 

    /*
     * 取绝对值
     */
    public func absolute()

    /*
     * 判等操作符
     * 参数 b - BigInteger
     */
    public operator func ==(b: BigInteger)

    /*
     * 判不等操作符
     * 参数 b - BigInteger
     */
    public operator func !=(b: BigInteger) 

    /*
     * 大于操作符
     * 参数 b - BigInteger
     */
    public operator func >(b: BigInteger) 

    /*
     * 小于操作符
     * 参数 b - BigInteger
     */
    public operator func <(b: BigInteger)

    /*
     * 大于等于操作符
     * 参数 b - BigInteger
     */
    public operator func >=(b: BigInteger) 

    /*
     * 小于等于操作符
     * 参数 b - BigInteger
     */
    public operator func <=(b: BigInteger)

    /*
     * 加操作符
     * 参数 b - BigInteger
     */
    public operator func +(b: BigInteger)

    /*
     * 减操作符
     * 参数 b - BigInteger
     */
    public operator func -(b: BigInteger)

    /*
     * 乘操作符
     * 参数 b - BigInteger
     */
    public operator func *(b: BigInteger)

    /*
     * 除操作符
     * 参数 b - BigInteger
     */
    public operator func /(b: BigInteger)

    /*
     * 取余操作符
     * 参数 b - BigInteger
     */
    public operator func %(b: BigInteger)

    /*
     * 转字符串
     */
    public func toString()
}

public class System {
    /*
     * 数组复制
     * 参数 src - Array<T>
     * 参数 srcPos - Int64
     * 参数 dest - Array<T>
     * 参数 hedestPosight - Int64
     * 参数 length - Int64
     * 返回值 Array<T>  - Array<T>
     */
    public static func arraycopy<T>(src: Array<T>, srcPos: Int64, dest: Array<T>, destPos: Int64, length: Int64): Array<T> 

    /*
     * 当前时间
     * 返回值 Int64  - Int64
     */
    public static func currentTimeMillis(): Int64

    /*
     * 无符号右移
     * 参数 c - Int32
     * 参数 num - Int64
     */
    public static func unsignedShiftRight(c: Int32, num: Int64) 
}

/*
 * 尾数
 * 参数 inData - Int64
 * 返回值 Int64 - Int64
 */
public func numberOfTrailingZeros(inData: Int64): Int64

/*
 * 数组哈希
 * 参数 inData - Array<Int32>
 * 返回值 Int64 - Int64
 */
public func intArraysHashCode(inData: Array<Int32>): Int64

/*
 * 浮点数到整数位
 * 参数 inData - Float32
 * 返回值 Int64 - Int64
 */
public func floatToIntBits(indata: Float32): Int64 

/*
 * 整数到字符串
 * 参数 inData - Int64
 * 返回值 String - String
 */
public func intToHexString(indata: Int64): String

public open class PDF417Common {
    /*
     * 获取比特计数总和
     * 参数 moduleBitCount - Array<Int64>
     * 返回值 Int64 - Int64
     */
    public static func getBitCountSum(moduleBitCount: Array<Int64>): Int64

    /*
     * 转换数组
     * 参数 list - Collection<Int64>
     * 返回值 Array<Int64> - Array<Int64>
     */
    public static func toIntArray(list: Collection<Int64>): Array<Int64>

    /*
     * 获取 Codeword
     * 参数 symbol - Int64
     * 返回值 Int64 - Int64
     */
    public static func getCodeword(symbol: Int64): Int64
}

public open class PDF417ResultMetadata {
    /*
     * 构造
     */
    public init()

    /*
     * 获取 SegmentIndex
     * 返回值 Int64 - Int64
     */
    public func getSegmentIndex(): Int64

    /*
     * 设置 segmentIndex
     * 参数 segmentIndex - Int64
     */
    public func setSegmentIndex(segmentIndex: Int64)

    /*
     * 获取 FileId
     * 返回值 String - String
     */
    public func getFileId(): String

    /*
     * 设置 fileId
     * 参数 fileId - String
     */
    public func setFileId(fileId: String)

    /*
     * 获取 OptionalData
     * 返回值 Array<Int64> - Array<Int64>
     */
    public func getOptionalData(): Array<Int64>

    /*
     * 设置 optionalData
     * 参数 optionalData - Array<Int64>
     */
    public func setOptionalData(optionalData: Array<Int64>)

    /*
     * 获取 isLastSegment
     * 返回值 Bool - Bool
     */
    public func isLastSegment(): Bool

    /*
     * 设置 isLastSegment
     * 参数 lastSegment - Int64
     */
    public func setLastSegment(lastSegment: Bool) 

    /*
     * 获取 SegmentCount
     * 返回值 Int64 - Int64
     */
    public func getSegmentCount(): Int64 

    /*
     * 设置 SegmentCount
     * 参数 Sender - Int64
     */
    public func setSegmentCount(segmentCount: Int64)

    /*
     * 获取 Sender
     * 返回值 Sender - Sender
     */
    public func getSender(): Sender 

    /*
     * 设置 Sender
     * 参数 Sender - Int64
     */
    public func setSender(sender: String) 

    /*
     * 获取 Addressee
     * 返回值 String - String
     */
    public func getAddressee(): String、

    /*
     * 设置 Addressee
     * 参数 Addressee - Int64
     */
    public func setAddressee(addressee: String)

    /*
     * 获取 FileName
     * 返回值 String - String
     */
    public func getFileName(): String

    /*
     * 设置 FileName
     * 参数 FileName - Int64
     */
    public func setFileName(fileName: String)

    /*
     * 获取 FileSize
     * 返回值 Int64 - Int64
     */
    public func getFileSize(): Int64

    /*
     * 设置 FileSize
     * 参数 FileSize - Int64
     */
    public func setFileSize(fileSize: Int64)

    /*
     * 获取 Checksum
     * 返回值 Int64 - Int64
     */
    public func getChecksum(): Int64

    /*
     * 设置 Checksum
     * 参数 Checksum - Int64
     */
    public func setChecksum(checksum: Int64)

    /*
     * 获取 Timestamp
     * 返回值 Int64 - Int64
     */
    public func getTimestamp(): Int64

    /*
     * 设置 Timestamp
     * 参数 timestamp - Int64
     */
    public func setTimestamp(timestamp: Int64)
}

public open class ErrorCorrection {
    /*
     * 构造
     */
    public init()

    /*
     * 解码
     * 参数 received - BinaryBitmap 图像
     * 返回值 Int64 - 解码结果
     */
    public func decode(
        received: Array<Int64>,
        numECCodewords: Int64,
        erasures: Array<Int64>
    ): Int64
}

public open class ModulusGF {
    /*
     * 设置 modulusGF
     * 参数 ModulusGF - ModulusGF
     */
    public func SetZeroOne(modulusGF: ModulusGF)
}

public open class PDF417ScanningDecoder {
    /*
     * 解码 BinaryBitmap 图像中的一维条形码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public static func decode(
        image: BitMatrix,
        imageTopLeft: ResultPoint,
        imageBottomLeft: ResultPoint,
        imageTopRight: ResultPoint,
        imageBottomRight: ResultPoint,
        minCodewordWidth: Int64,
        maxCodewordWidth: Int64
    ): DecoderResult
}

public open class PDF417DetectorResult {
    /*
     * 构造
     */
    public init(bits: BitMatrix, points: ArrayList<Array<ResultPoint>>, rotation: Int64)

    /*
     * 构造
     */
    public init(bits: BitMatrix, points: ArrayList<Array<ResultPoint>>)

    /*
     * 获取 Bits
     * 返回值 BitMatrix - BitMatrix
     */
    public func getBits(): BitMatrix

    /*
     * 获取 Points
     * 返回值 ArrayList<Array<ResultPoint>> - ArrayList<Array<ResultPoint>>
     */
    public func getPoints(): ArrayList<Array<ResultPoint>>

    /*
     * 获取 Rotation
     * 返回值 Int64 - Int64
     */
    public func getRotation(): Int64
}

public open class BarcodeMatrix {
    /*
     * 获取一个 Matrix
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public func getMatrix(): Array<Array<UInt8>>

    /*
     * 获取一个 Matrix
     * 返回值 Array<Array<UInt8>> - Array<Array<UInt8>>
     */
    public func getScaledMatrix(xScale: Int64, yScale: Int64): Array<Array<UInt8>>
}

public enum Compaction <: ToString {
    | AUTO
    | TEXT
    | BYTE
    | NUMERIC

    /*
     * 获取对应枚举
     * 参数 data - String
     * 返回值 ResultMetadataType - ResultMetadataType
     */
    public static func valueOf(str: String): Compaction 

    /*
     * 获取字符串
     * 返回值 String - String
     */
    public func toString(): String
}

public open class Dimensions {
    /*
     * 构造
     */
    public init(minCols: Int64, maxCols: Int64, minRows: Int64, maxRows: Int64)

    /*
     * 获取 MinCols
     * 返回值 Int64 - Int64
     */
    public func getMinCols(): Int64

    /*
     * 获取 MaxCols
     * 返回值 Int64 - Int64
     */
    public func getMaxCols(): Int64

    /*
     * 获取 MinRows
     * 返回值 Int64 - Int64
     */
    public func getMinRows(): Int64

    /*
     * 获取 MaxRows
     * 返回值 Int64 - Int64
     */
    public func getMaxRows(): Int64
}

public open class PDF417 {
    /*
     * 构造
     */
    public init()

    /*
     * 构造
     */
    public init(compact: Bool)

    /*
     * 获取 BarcodeMatrix
     * 返回值 BarcodeMatrix - BarcodeMatrix
     */
    public func getBarcodeMatrix(): ?BarcodeMatrix

    /*
     * 生成条码逻辑
     * 参数 msg - UTF32String
     * 参数 errorCorrectionLevel - Int64
     */
    public func generateBarcodeLogic(msg: UTF32String, errorCorrectionLevel: Int64)

    /*
     * 生成条码逻辑
     * 参数 msg - UTF32String
     * 参数 errorCorrectionLevel - Int64
     */
    public func generateBarcodeLogic(msg: UTF32String, errorCorrectionLevel: Int64, autoECI: Bool)

    /*
     * 设置 Dimensions
     * 参数 maxCols - Int64
     * 参数 minCols - Int64
     * 参数 maxRows - Int64
     * 参数 minRows - Int64
     */
    public func setDimensions(maxCols: Int64, minCols: Int64, maxRows: Int64, minRows: Int64)

    /*
     * 设置 Compaction
     * 参数 compaction - Compaction
     */
    public func setCompaction(compaction: Compaction)

    /*
     * 设置 compact
     * 参数 compact - Bool
     */
    public func setCompact(compact: Bool)

    /*
     * 设置 encoding
     * 参数 encoding - MyCharset
     */
    public func setEncoding(encoding: MyCharset)
}

public open class PDF417HighLevelEncoder {
    /*
     * 编码
     * 参数 codewords - UTF32String
     * 参数 symbolInfo - SymbolInfo
     * 返回值 UTF32String - UTF32String
     */
    public static func encodeHighLevel(msg: UTF32String, compaction: Compaction, encoding: MyCharset, autoECI: Bool): UTF32String 

    /*
     * 子序列
     * 参数 input - ECIInput
     * 参数 start - Int64
     * 返回值 Array<UInt8>  - Array<UInt8> 
     */
    public static func subBytes(input: ECIInput, start: Int64, end: Int64): Array<UInt8> 
}

public open class PDF417HighLevelEncoderTestAdapter {
    /*
     * 编码
     * 参数 codewords - UTF32String
     * 参数 symbolInfo - SymbolInfo
     * 返回值 UTF32String - UTF32String
     */
     public static func encodeHighLevel(
        msg: String,
        compaction: Compaction,
        encoding: MyCharset,
        autoECI: Bool
    ): UTF32String
}

public class BitMatrixParser {
    /*
     * 构造
     */
    public init(bitMatrix: BitMatrix)

    /*
     * 获取 FormatInformation
     * 返回值 FormatInformation - FormatInformation
     */
    public func readFormatInformation(): FormatInformation

    /*
     * 获取 Version
     * 返回值 Version - Version
     */
    public func readVersion(): Version

    /*
     * 复制 bit
     * 参数 i - Int64
     * 参数 j - Int64
     * 参数 versionBits - Int64
     * 返回值 Int64 - Int64
     */
    public func copyBit(i: Int64, j: Int64, versionBits: Int64): Int64

    /*
     * 获取 Codewords
     * 返回值 Array<UInt8> - Array<UInt8>
     */
    public func readCodewords(): Array<UInt8>

    /*
     * 获取重屏蔽
     */
    public func remask()

    /*
     * 设置镜像
     * 参数 mirror - Bool
     */
    public func setMirror(mirror: Bool)

    /*
     * 镜像
     */
    public func Mirror()
}

public enum DataMask {
    // See ISO 18004:2006 6.8.1
    | DATA_MASK_000
    | DATA_MASK_001
    | DATA_MASK_010
    | DATA_MASK_011
    | DATA_MASK_100
    | DATA_MASK_101
    | DATA_MASK_110
    | DATA_MASK_111

    /*
     * 取消标记
     * 参数 bits - BitMatrix
     * 参数 dimension - Int64
     * 参数 mirror - Bool
     */
    public func unmaskBitMatrix(bits: BitMatrix, dimension: Int64)

    /*
     * 是否标记
     * 参数 i - Int64
     * 参数 j - Int64
     * 返回值 Bool - Bool
     */
    public func isMasked(i: Int64, j: Int64): Bool

    /*
     * 获取值
     * 返回值 Array<DataMask> - Array<DataMask>
     */
    public static func values(): Array<DataMask>
}

public class DecodedBitStreamParser {
    /*
     * 解码 BinaryBitmap 图像中的一维条形码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码参数配置
     * 返回值 Result - 解码结果
     */
    public static func decode(
        bytes: Array<Byte>,
        version: Version,
        ecLevel: ?ErrorCorrectionLevel,
        hints: HashMap<DecodeHintType, Any>
    ): DecoderResult 
}

public enum ErrorCorrectionLevel <: Equatable<ErrorCorrectionLevel> & ToString {
    | L(Int32)
    | M(Int32)
    | Q(Int32)
    | H(Int32)

    /*
     * 转成整型
     * 返回值 Int32 - Int32
     */
    public func ToInt(): Int32

    /*
     * 转成整型
     * 返回值 Int64 - Int64
     */
    public func ordinal(): Int64

    /*
     * 转成整型
     * 返回值 Int32 - Int32
     */
    public func getBits(): Int32

    /*
     * 获取对应枚举
     * 参数 bits - Int64
     * 返回值 ErrorCorrectionLevel - ErrorCorrectionLevel
     */
    public static func forBits(bits: Int64): ErrorCorrectionLevel

    /*
     * 判等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否相等
     */
    public operator func ==(rhs: ErrorCorrectionLevel): Bool

    /*
     * 判不等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否不等
     */
    public operator func !=(rhs: ErrorCorrectionLevel): Bool

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String

    /*
     * 获取对应枚举
     * 参数 data - String
     * 返回值 ResultMetadataType - ResultMetadataType
     */
    public static func valueOf(str: String): ErrorCorrectionLevel
}

public class FormatInformation <: Equatable<FormatInformation> & ToString {
    /*
     * 构造
     */
    public init(formatInfo: Int64)

    /*
     * 差异位数
     * 参数 a  - Int64
     * 参数 b  - Int64
     * 返回值 Int64  - Int64
     */ 
    public static func numBitsDiffering(a: Int64, b: Int64): Int64

    /*
     * 字节统计
     * 参数 v  - Int64
     * 返回值 Int32  - Int32
     */ 
    public static func bitCount(v: Int32): Int32

    /*
     * 获取 ErrorCorrectionLevel
     * 参数 maskedFormatInfo1  - Int64
     * 参数 maskedFormatInfo2  - Int64
     * 返回值 FormatInformation  - FormatInformation
     */  
    public static func decodeFormatInformation(maskedFormatInfo1: Int64, maskedFormatInfo2: Int64): ?FormatInformation

    /*
     * 获取 ErrorCorrectionLevel
     * 返回值 ErrorCorrectionLevel  - ErrorCorrectionLevel
     */  
    public func getErrorCorrectionLevel(): ErrorCorrectionLevel

    /*
     * 获取 DataMask
     * 返回值 UInt8  - UInt8
     */  
    public func getDataMask(): UInt8

    /*
     * 计算哈希值
     * 返回值 Int64  - 哈希值
     */ 
    public func hashCode(): UInt8

    /*
     * 判等
     * 参数 o - Object
     * 返回值 Bool  - 是否相等
     */  
    public func equals(o: Any): Bool

    /*
     * 判等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否相等
     */
    public opera
    tor func ==(right: FormatInformation): Bool

    /*
     * 判不等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否不等
     */
    public operator func !=(right: FormatInformation): Bool

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String
}

public enum Mode <: Equatable<Mode> & ToString {
    | TERMINATOR(Array<Int64>, Int64) // Not really a mode...
    | NUMERIC(Array<Int64>, Int64)
    | ALPHANUMERIC(Array<Int64>, Int64)
    | STRUCTURED_APPEND(Array<Int64>, Int64) // Not supported
    | BYTE(Array<Int64>, Int64)
    | ECI(Array<Int64>, Int64) // character counts don't apply
    | KANJI(Array<Int64>, Int64)
    | FNC1_FIRST_POSITION(Array<Int64>, Int64)
    | FNC1_SECOND_POSITION(Array<Int64>, Int64)
    | HANZI(Array<Int64>, Int64)

    /*
     * 转换
     * 参数 bits - Int64
     * 返回值 Mode - Mode
     */
    public static func forBits(bits: Int64): Mode

    /*
     * 获取对应数字
     * 参数 version - Version
     * 返回值 Int64 - Int64
     */
    public func getCharacterCountBits(version: Version): Int64

    /*
     * 获取字节数组
     * 返回值 Int64 - Int64
     */
    public func getBits(): Int64

    /*
     * 判等
     * 参数 that - 对比值
     * 返回值 Bool - 判等
     */ 
    public operator func ==(that: Mode): Bool

    /*
     * 判不等
     * 参数 that - 对比值
     * 返回值 Bool - 判不等
     */ 
    public operator func !=(that: Mode): Bool 

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String
}

public class QRCodeDecoderMetaData {
    /*
     * 是否镜像
     * 返回值 Bool  - Bool
     */ 
    public func isMirrored(): Bool

    /*
     * 镜像修正
     * 参数 points  - Array<ResultPoint>
     */ 
    public func applyMirroredCorrection(points: Array<ResultPoint>)
}

public class ECB {
    /*
     * 计数
     * 返回值 Int64  - Int64
     */ 
    public func getCount(): Int64

    /*
     * 获取 DataCodewords
     * 返回值 Int64  - Int64
     */ 
    public func getDataCodewords(): Int64
}

public class ECBlocks {
    /*
     * 构造
     */
    public init(ecCodewordsPerBlock: Int64, ecBlocks: Array<ECB>)

    /*
     * 获取 ECCodewordsPerBlock
     * 返回值 Int64  - Int64
     */ 
    public func getECCodewordsPerBlock(): Int64

    /*
     * 获取 NumBlocks
     * 返回值 Int64  - Int64
     */ 
    public func getNumBlocks(): Int64

    /*
     * 获取 TotalECCodewords
     * 返回值 Int64  - Int64
     */ 
    public func getTotalECCodewords(): Int64

    /*
     * 获取 ECBlocks
     * 返回值 Array<ECB>  - Array<ECB>
     */ 
    public func getECBlocks(): Array<ECB>
}

public class Version <: ToString {
    /*
     * 构造
     */
    public init(
        versionNumber: Int64,
        alignmentPatternCenters: Array<Int64>,
        ecBlocks: Array<ECBlocks>
    )

    /*
     * 获取 VersionNumber
     * 返回值 Int64  - Int64
     */ 
    public func getVersionNumber(): Int64

    /*
     * 获取 AlignmentPatternCenters
     * 返回值 Array<Int64>  - Array<Int64>
     */ 
    public func getAlignmentPatternCenters(): Array<Int64>

    /*
     * 获取 TotalCodewords
     * 返回值 Int64  - Int64
     */ 
    public func getTotalCodewords(): Int64 

    /*
     * 获取 DimensionForVersion
     * 返回值 Int64  - Int64
     */ 
    public func getDimensionForVersion(): Int64 

    /*
     * 获取 ECBlocksForLevel
     * 参数 ecLevel  - ErrorCorrectionLevel
     * 返回值 ECBlocks  - ECBlocks
     */ 
    public func getECBlocksForLevel(ecLevel: ErrorCorrectionLevel): ECBlocks

    /*
     * 获取 ProvisionalVersionForDimension
     * 参数 dimension  - Int64
     * 返回值 Version  - Version
     */ 
    public static func getProvisionalVersionForDimension(dimension: Int64): Version

    /*
     * 获取 VersionForNumber
     * 参数 versionNumber  - Int64
     * 返回值 Version  - Version
     */ 
    public static func getVersionForNumber(versionNumber: Int64): Version

    /*
     * 获取 VersionInformation
     * 参数 versionBits  - Int64
     * 返回值 Option<Version>  - Option<Version>
     */ 
    public static func decodeVersionInformation(versionBits: Int64): Option<Version>

    /*
     * 构建函数模式
     * 返回值 BitMatrix  - BitMatrix
     */ 
    public func buildFunctionPattern(): BitMatrix

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String
}

public open class FinderPattern <: ResultPoint {
    /*
     * 获取 EstimatedModuleSize
     * 返回值 Float32  - Float32
     */ 
    public func getEstimatedModuleSize(): Float32

    /*
     * 获取 Count
     * 返回值 Int64  - Int64
     */ 
    public func getCount(): Int64
}

public open class FinderPatternFinder {
    /*
     * 构造
     */
    public init(image: BitMatrix)

    /*
     * 构造
     */
    public init(image: BitMatrix, resultPointCallback: ?ResultPointCallback)

    /*
     * 更改查找模式数组
     * 参数 arrayFinder  - Array<FinderPattern>
     * 返回值 Array<ResultPoint>  - Array<ResultPoint>
     */ 
    public static func changeFinderPatternArray(arrayFinder: Array<FinderPattern>): Array<ResultPoint>
}

public class FinderPatternInfo {
    /*
     * 构造
     */
    public init(patternCenters: Array<FinderPattern>)

    /*
     * 获取 BottomLeft
     * 返回值 FinderPattern  - FinderPattern
     */ 
    public func getBottomLeft(): FinderPattern

    /*
     * 获取 TopLeft
     * 返回值 FinderPattern  - FinderPattern
     */ 
    public func getTopLeft(): FinderPattern

    /*
     * 获取 TopRight
     * 返回值 FinderPattern  - FinderPattern
     */ 
    public func getTopRight(): FinderPattern
}

public class ByteMatrix <: ToString & Equatable<ByteMatrix> {
    /*
     * 构造
     */
    public init(width: Int64, height: Int64)

    /*
     * 获取 Height
     * 返回值 Int64 - Height
     */ 
    public func getHeight(): Int64

    /*
     * 获取 Width
     * 返回值 Int64 - Width
     */ 
    public func getWidth(): Int64

    /*
     * 获取指定位置的像素值
     * 参数 x - 像素的横坐标
     * 参数 y - 像素的纵坐标
     * 返回值 Bool - 指定位置像素的值，true 表示黑色，false 表示白色
     */
    public func get(x: Int64, y: Int64): Byte

    /*
     * 获取 Array
     * 返回值 Array<Array<Byte>> - Array<Array<Byte>>
     */ 
    public func getArray(): Array<Array<Byte>>

    /*
     * 设置指定位置的像素值为黑色
     * 参数 x - 像素的横坐标
     * 参数 y - 像素的纵坐标
     */
    public func set(x: Int64, y: Int64, value: Byte)

    /*
     * 设置指定位置的像素值为白色（即清除像素）
     * 参数 x - 像素的横坐标
     * 参数 y - 像素的纵坐标
     */
    public func set(x: Int64, y: Int64, value: Int64)

    /*
     * 设置指定位置的像素值为白色（即清除像素）
     * 参数 x - 像素的横坐标
     * 参数 y - 像素的纵坐标
     */
    public func set(x: Int64, y: Int64, value: Bool)

    /*
     * 清除当前 BitMatrix 对象的所有像素值，将所有像素置为白色（即清空 BitMatrix）
     */
    public func clear(value: Byte)

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 

    public func toString(): String

    /*
     * 判等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否相等
     */
    public operator func ==(rhs: ByteMatrix): Bool

    /*
     * 判不等操作符
     * 参数 right - DecodeHintType 枚举值
     * 返回值 Bool - 是否不等
     */
    public operator func !=(rhs: ByteMatrix): Bool
}

public class MaskUtil {
    /*
     * 应用屏蔽处罚规则
     * 参数 matrix - ByteMatrix
     * 返回值 Int64 - Int64
     */
    public static func applyMaskPenaltyRule1(matrix: ByteMatrix): Int64

    /*
     * 应用屏蔽处罚规则
     * 参数 matrix - ByteMatrix
     * 返回值 Int64 - Int64
     */
    public static func applyMaskPenaltyRule2(matrix: ByteMatrix): Int64

    /*
     * 应用屏蔽处罚规则
     * 参数 matrix - ByteMatrix
     * 返回值 Int64 - Int64
     */
    public static func applyMaskPenaltyRule3(matrix: ByteMatrix): Int64

    /*
     * 应用屏蔽处罚规则
     * 参数 matrix - ByteMatrix
     * 返回值 Int64 - Int64
     */
    public static func applyMaskPenaltyRule4(matrix: ByteMatrix): Int64

    /*
     * 获取数据掩码位
     * 参数 maskPattern - 像素的横坐标
     * 参数 x - 像素的横坐标
     * 参数 y - 像素的纵坐标
     * 返回值 Bool - Bool
     */
    public static func getDataMaskBit(maskPattern: Int64, x: Int64, y: Int64): Bool
}

public class MatrixUtil {
    /*
     * 清空 Matrix
     * 参数 matrix - ByteMatrix
     */
    public static func clearMatrix(matrix: ByteMatrix)

    /*
     * 构建 Matrix
     * 参数 dataBits - BitArray
     * 参数 ecLevel - ErrorCorrectionLevel
     * 参数 version - Version
     * 参数 maskPattern - Int64
     * 参数 matrix - ByteMatrix
     */
    public static func buildMatrix(
        dataBits: BitArray,
        ecLevel: ErrorCorrectionLevel,
        version: Version,
        maskPattern: Int64,
        matrix: ByteMatrix
    ) 

    /*
     * 构建 Matrix
     * 参数 version - BitArray
     * 参数 matrix - ErrorCorrectionLevel
     */
    public static func embedBasicPatterns(version: Version, matrix: ByteMatrix)

    /*
     * 构建 Matrix
     * 参数 ecLevel - ErrorCorrectionLevel
     * 参数 maskPattern - Int64
     * 参数 matrix - ByteMatrix
     */
    public static func embedTypeInfo(ecLevel: ErrorCorrectionLevel, maskPattern: Int64, matrix: ByteMatrix)

    /*
     * 构建 Matrix
     * 参数 version - Version
     * 参数 matrix - ByteMatrix
     */
    public static func maybeEmbedVersionInfo(version: Version, matrix: ByteMatrix)

    /*
     * 构建 Matrix
     * 参数 dataBits - BitArray
     * 参数 maskPattern - Int64
     * 参数 matrix - ByteMatrix
     */
    public static func embedDataBits(dataBits: BitArray, maskPattern: Int64, matrix: ByteMatrix)

    /*
     * 查找 MBSet
     * 参数 value - Int64
     * 返回值 Int64 - Int64
     */
    public static func findMSBSet(value: Int64): Int64

    /*
     * 计算BCHC 代码
     * 参数 value - Int64
     * 参数 poly - Int64
     * 返回值 Int64 - Int64
     */
    public static func calculateBCHCode(value_: Int64, poly: Int64): Int64

    /*
     * 使TypeInfoBits
     * 参数 ecLevel - ErrorCorrectionLevel
     * 参数 maskPattern - Int64
     * 参数 bits - BitArray
     */
    public static func makeTypeInfoBits(ecLevel: ErrorCorrectionLevel, maskPattern: Int64, bits: BitArray)

    /*
     * makeVersionInfoBits
     * 参数 version - Version
     * 参数 bits - BitArray
     */
    public static func makeVersionInfoBits(version: Version, bits: BitArray)
}

public class ResultList {
    /*
     * 返回大小
     * 参数 version - Version
     * 返回值 Int64 - Int64
     */ 
    public func getSize(version: Version): Int64

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String
}

public class ResultNode {
    /*
     * 返回大小
     * 参数 version - Version
     * 返回值 Int64 - Int64
     */ 
    public func getSize(version: Version): Int64

    /*
     * 返回 Bits
     * 参数 bits - bits
     */ 
    public func getBits(bits: BitArray)

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String
}

public class MinimalEncoder {
    /*
     * 将内容编码
     * 参数 contents - 要编码的字符串
     * 参数 format - 要生成的条形码格式，如果格式不是 BarcodeFormat.UPC_A 则抛 IllegalArgumentException 异常
     * 参数 width - 图像宽度
     * 参数 height - 图像高度
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public static func encode(
        stringToEncode: UTF32String,
        version: ?Version,
        priorityCharset: MyCharset,
        isGS1: Bool,
        ecLevel: ErrorCorrectionLevel
    ): ResultList
}

public class QRCode {
    /*
     * 构造
     */
    public init()

    /*
     * 获取 Mode
     * 返回值 Mode - Mode
     */
    public func getMode(): Mode

    /*
     * 获取 ECLevel
     * 返回值 ErrorCorrectionLevel - ECLevel
     */
    public func getECLevel(): ErrorCorrectionLevel 

    /*
     * 获取 Version
     * 返回值 Version - Version
     */
    public func getVersion(): Version

    /*
     * 获取 MaskPattern
     * 返回值 Int64 - VersiMaskPatternon
     */
    public func getMaskPattern(): Int64

    /*
     * 获取 Matrix
     * 返回值 ByteMatrix - ByteMatrix
     */
    public func getMatrix(): ByteMatrix

    /*
     * 转换字符串
     * 返回值 String  - String
     */ 
    public func toString(): String

    /*
     * 设置 Mode
     * 参数 value - Mode
     */ 
    public func setMode(value: Mode)

    /*
     * 设置 ECLevel
     * 参数 value - ErrorCorrectionLevel
     */ 
    public func setECLevel(value: ErrorCorrectionLevel)

    /*
     * 设置 Version
     * 参数 value - Version
     */ 
    public func setVersion(version: Version)

    /*
     * 设置 MaskPattern
     * 参数 value - Int64
     */ 
    public func setMaskPattern(value: Int64) 

    /*
     * 设置 Matrix
     * 参数 value - ByteMatrix
     */ 
    public func setMatrix(value: ByteMatrix) 

    /*
     * 是有效掩码模式
     * 参数 maskPattern - Int64
     * 返回值 Bool  - Bool
     */ 
    public static func isValidMaskPattern(maskPattern: Int64): Bool
}
```