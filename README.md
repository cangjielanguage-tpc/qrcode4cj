<div align="center">
<h1>QRCode4cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.59.6-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-90.2%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## 介绍

一个解析/生成一维码/二维码的库。
支持的格式如下：
- 生成、解析 QRCode
- 生成、解析 Data Matrix
- 生成、解析 PDF417 barcode
- 生成、解析 Aztec barcode
- 生成、解析 codeBar
- 生成、解析 code128
- 生成、解析 code39
- 生成、解析 code93
- 生成、解析 EAN13
- 生成、解析 EAN8
- 生成、解析 ITF
- 生成、解析 UPC-A 
- 生成、解析 UPC-E 
- 解析 UPC/EAN
- 解析 MaxiCode
- 解析 RSS barcode(RSS-14、RSS-Expanded)

### 特性

- 🚀 可根据实际场景需求生成或解析一维或二维码

- 🚀 可在终端设备相机扫描解析一维或二维码


## <img alt="" src="./doc/assets/readme-icon-framework.png" style="display: inline-block;" width=3%/> 架构


### 源码目录

```shell
.
├── README.md
├── doc
├── src
└── test   
    ├── HLT
    ├── LLT
    └── DOC
```

- `doc`存放库的设计文档、提案、库的使用文档
- `src`存放库源码目录
- `test/HLT`存放HLT用例
- `test/LLT`存放LLT用例
- `test/DOC`存放示例代码

### 接口说明

主要是核心类和成员函数说明,详情见 [API](./doc/feature_api.md)

## <img alt="" src="./doc/assets/readme-icon-compile.png" style="display: inline-block;" width=3%/> 使用说明

### 编译（win/linux）

```shell
cjpm build
```

### 功能示例

#### 解码功能示例:

示例代码如下：
额外依赖 bitMatrixToBinaryBitmap 转换代码在 test/DOC/libs.cj

```cangjie
import QRCode4cj.common.*
import QRCode4cj.common.reader.*
import QRCode4cj.common.writer.*
import QRCode4cj.tools.UTF32String
import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*

main(): Int64 {
    let tester = DecoderTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
}

@Test
public class DecoderTestCase {
    @TestCase
    public func testDecode(): Unit {
        var content = "ABCDEF"
        var mfw = MultiFormatWriter();
        var bitMatrixAfterEncode: BitMatrix = mfw.encode(content, BarcodeFormat.AZTEC, 30, 30)

        var bitmap = bitMatrixToBinaryBitmap(bitMatrixAfterEncode, bitMatrixAfterEncode.getWidth(),
            bitMatrixAfterEncode.getHeight())
        var hintType: DecodeHintType = DecodeHintType.TRY_HARDER
        var hints: HashMap<DecodeHintType, Any> = HashMap<DecodeHintType, Any>()
        hints.put(hintType, true)
        var reader: MultiFormatReader = MultiFormatReader()
        var result = reader.decode(bitmap, hints)
        @Assert(content, result.getText())
    }
}
```

执行结果如下：

```shell
[ PASSED ] CASE: testDecode (2342200 ns)
```

#### 编码功能示例:

示例代码如下：

```cangjie
import QRCode4cj.common.*
import QRCode4cj.common.writer.*
import std.unittest.*
import std.unittest.testmacro.*

main(): Int64 {
    let tester = EncoderTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
}

@Test
public class EncoderTestCase {
    @TestCase
    public func testEncode(): Unit {
        var mfw = MultiFormatWriter();
        var res:BitMatrix =  mfw.encode("ABCDEF", BarcodeFormat.QR_CODE, 21, 21)
        var expected = """
                                                          
                                                          
                                                          
                                                          
        X X X X X X X   X   X X X   X X X X X X X         
        X           X       X X     X           X         
        X   X X X   X   X X   X     X   X X X   X         
        X   X X X   X   X X     X   X   X X X   X         
        X   X X X   X   X     X     X   X X X   X         
        X           X     X X X X   X           X         
        X X X X X X X   X   X   X   X X X X X X X         
                              X X                         
        X X X X     X   X X X X X X     X X X   X         
          X   X X X   X X X   X X X X     X X X           
            X X X   X   X   X X           X   X           
            X   X X   X     X X     X X X X   X           
        X         X X   X   X   X     X   X X X X         
                        X X   X     X     X   X X         
        X X X X X X X         X X     X     X X           
        X           X     X X         X X     X X         
        X   X X X   X     X     X X X X X X X   X         
        X   X X X   X   X X   X     X   X     X           
        X   X X X   X   X X     X   X X   X X             
        X           X   X X       X                       
        X X X X X X X   X   X     X     X     X           
                                                          
                                                          
                                                          
                                                          
"""
        @Assert(expected, res.toString())
    }
}
```

执行结果如下：

```shell
[ PASSED ] CASE: testEncode (2362800 ns)
```

## 开源协议

本项目基于 [Apache License 2.0](./LICENSE) ，请自由的享受和参与开源。

## <img alt="" src="./doc/assets/readme-icon-contribute.png" style="display: inline-block;" width=3%/> 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。