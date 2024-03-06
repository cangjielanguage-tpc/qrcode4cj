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
     * 参数 hints - 解码提示信息
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
     * 参数 hints - 解码提示信息
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
     * 参数 hints - 编码提示
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
     * 参数 hints - 解码提示信息
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
     * 参数 hints - 解码提示信息
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
     * 参数 hints - 解码提示信息
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
     * 参数 hints - 解码提示信息
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, startGuardRange: Array<Int64>, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码提示信息
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
     * 参数 hints - 解码提示信息
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
     * 参数 hints - 编码提示
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
     * 参数 hints - 编码提示
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64, hints: HashMap<EncodeHintType, Any>): BitMatrix
}
```

#### 1.10 生成、解析  UPC/EAN

##### 1.10.1 主要接口
```cangjie
public abstract class UPCEANReader <: OneDReader {
    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码提示信息
     * 返回值 Result - 解码结果
     */
    public open override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 startGuardRange - 起始标记数据
     * 参数 hints - 解码提示信息
     * 返回值 Result - 解码结果
     */
    public override func decodeRow(rowNumber: Int64, row: BitArray, startGuardRange: Array<Int64>, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 获取该解码器的格式
     * 返回值 BarcodeFormat - 解码器格式
     */
    public func getBarcodeFormat(): BarcodeFormat
}

public open class UPCEANWriter <: OneDimensionalCodeWriter {
    /*
     * 将内容编码为一维条形码的布尔数组
     * 参数 contentsin - 要编码的字符串
     * 返回值 Array<Bool> - 编码结果, 固定返回一个空数组
     */
    public open func encode(contents: String): Array<Bool> 

    /*
     * 获取默认边距
     * 返回值 Int64 - 固定返回 9
     */
    public override func getDefaultMargin(): Int64
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
     * 参数 hints - 解码提示信息
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 空实现
     */
    public func reset()
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
     * 参数 hints - 编码提示
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
     * 参数 hints - 解码提示信息
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 空实现
     */
    public func reset()
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
     * 参数 hints - 编码提示
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
     * 在图像中定位并解码 Data Matrix 二维码
     * 参数 image - BinaryBitmap 图像
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap): Result

    /*
     * 在图像中定位并解码 Data Matrix 二维码
     * 参数 image - BinaryBitmap 图像
     * 参数 hints - 解码提示信息
     * 返回值 Result - 解码结果
     */
    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 空实现
     */
    public func reset()
}
```

#### 4.2 PDF417 barcode 编码

##### 4.2.1 主要接口
```cangjie
public open class PDF417Writer <: Writer {
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
     * 参数 hints - 编码提示
     * 返回值 BitMatrix - 编码完成的 BitMatrix 图像
     */
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64, hints: HashMap<EncodeHintType, Any>): BitMatrix
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
     * 参数 hints - 解码提示信息
     * 返回值 Result - 解码结果
     */
    public open override func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result

    /*
     * 空实现
     */
    public open func reset()

    /*
     * 解码单行图像中的一维条形码
     * 参数 rowNumber - 行号
     * 参数 row - 该行的黑/白像素 BitArray 数据
     * 参数 hints - 解码提示信息
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
     * 参数 hints - 编码提示
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
     * 参数 hints - 编码提示
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
 * 编码提示类型
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
```