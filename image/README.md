<div align="center">
<h1>image</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.3-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.45.2-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-71%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## <img alt="" src="./doc/assets/readme-icon-introduction.png" style="display: inline-block;" width=3%/> 介绍

提供基础图片处理能力。

### 特性

- 🚀 支持 `JPEG`、`PNG`、`GIF`、`BMP` 的读写

- 💪 支持对图片进行`缩放`、`裁剪`、`亮度调节`、`对比度调节`、`锐化处理`、`中心旋转`、`圆角矩形裁剪`、`圆形裁剪`

## <img alt="" src="./doc/assets/readme-icon-framework.png" style="display: inline-block;" width=3%/> 软件架构

### 架构图

<p align="center">
<img src="./doc/assets/image-struct.png" width="60%" >
</p>

- 支持 JPEG 、PNG、GIF 的读写

- 未来支持 BMP、WEBP 的读写

### 源码目录

```
├── doc ----------------------------------------- 参考文档
│    ├── assets --------------------------------- 资产目录
│    ├── cjcov ---------------------------------- LLT 用例覆盖报告
│    └── doc_JPEG.md ---------------------------- JPEG模块参考文档
│       
├── src ----------------------------------------- 源码
│    ├── color ---------------------------------- 图片颜色包
│    │    ├── color.cj -------------------------- 基础颜色定义
│    │    └── ycbcr.cj -------------------------- YCbCr类型图片颜色定义
│    │    
│    ├── drawer --------------------------------- 图片渲染包
│    │    └── draw ------------------------------ 渲染操作
│    │    
│    ├── image ---------------------------------- 核心包
│    │    ├── byte_stream.cj -------------------- 字节流实现
│    │    ├── format.cj ------------------------- 图片库工厂模式包装
│    │    ├── geom.cj --------------------------- 数值操作
│    │    ├── image.cj -------------------------- 图片类型定义及操作核心
│    │    ├── names.cj -------------------------- 基础颜色定义
│    │    └── ycbcr.cj -------------------------- YCbCr类型定义
│    │    
│    ├── internals ------------------------------ 内部定义
│    │    ├── imageutil ------------------------- 工具包
│    │    │    ├── error.cj --------------------- 异常包装
│    │    │    ├── impl.cj ---------------------- YCbCr类型图片渲染实现
│    │    │    └── util.cj ---------------------- 其他工具
│    │    │
│    │    └── model ----------------------------- 模型
│    │         ├── image.cj --------------------- 图片类型接口定义
│    │         ├── point.cj --------------------- Point类型定义
│    │         └── reactangle.cj ---------------- Reactangle类型定义
│    │    
│    ├── gif ------------------------------------ GIF模块
│    │    ├── lzw ------------------------------- LZW压缩算法库
│    │    │    ├── reader.cj -------------------- LZW解码器
│    │    │    └── writer.cj -------------------- LZW编码器
│    │    │
│    │    ├── reader.cj ------------------------- 解码器
│    │    └── writer.cj ------------------------- 编码器
│    │    
│    ├── jpeg ----------------------------------- JPEG模块
│    │    ├── fdct.cj --------------------------- 前向离散余弦变换实现
│    │    ├── huffman.cj ------------------------ Huffman编码/解码
│    │    ├── idct.cj --------------------------- 逆离散余弦变换实现
│    │    ├── reader.cj ------------------------- 解码器
│    │    └── writer.cj ------------------------- 编码器
│    │    
│    ├── png ------------------------------------ PNG模块
│    │    ├── zlib ------------------------------ PNG zlib库
│    │    │    ├── deflate.cj ------------------- Deflate算法
│    │    │    ├── dict_decoder.cj -------------- 字典编码器
│    │    │    ├── hash.cj ---------------------- PNG格式所需Hash操作
│    │    │    ├── huffman_bit_writer.cj -------- Huffman编码器
│    │    │    ├── inflate.cj ------------------- Inflate算法
│    │    │    └── zlib.cj ---------------------- zlib库入口
│    │    │
│    │    ├── peath.cj -------------------------- PEATH过滤器
│    │    ├── reader.cj ------------------------- 解码器
│    │    └── writer.cj ------------------------- 编码器
│    │    
│    ├── bmp ------------------------------------ BMP模块
│    │    ├── reader.cj ------------------------- 解码器
│    │    └── writer.cj ------------------------- 编码器
│    │    
│    ├── resizer -------------------------------- 图片缩放处理模块
│    │    
├── test
│    ├── HLT                
│    │   └── testcase0001.cj  \
│    ├── LLT                   |
│    │   └── testcase0001.cj    > LLT：自测用例  UT： 单元测试用例  HLT：测试级别用例
│    └── UT                    |
│        └── testcase0001.cj  /
├── build_libs.sh ---------- 构建脚本
└── module.json ------------ cpm模块配置
```
- `doc` 是库的设计文档、提案、库的使用文档、LLT 用例覆盖报告(有些不对外暴露的 api 未能测到，影响了整体覆盖率)
- `src` 是库源码目录
- `test` 是存放测试用例，包括 HLT 用例、LLT 用例和 UT 用例

### 接口说明 

详情见文档 [API](./doc/api.md)

## <img alt="" src="./doc/assets/readme-icon-compile.png" style="display: inline-block;" width=3%/> 编译执行

### 编译

此方法可编译全部 LLT 和 UT 示例

```
1、引入 testJekins 包,保持原目录结构
https://gitee.com/HW-PLLab/testJekins 将 src 下 ci_test 放入 根目录下
2、python3 ci_test/main.py build
3、python3 ci_test/main.py test
```

### JPEG格式操作

[JPEG使用案例](./doc/doc_JPEG.md)

### PNG格式操作

[PNG使用案例](./doc/doc_PNG.md)

### GIF格式操作

[GIF使用案例](./doc/doc_GIF.md)


### BMP格式操作

[BMP使用案例](./doc/doc_BMP.md)

## <img alt="" src="./doc/assets/readme-icon-contribute.png" style="display: inline-block;" width=3%/> 参与贡献

主要写参与贡献的人以及个人主页链接

[@changeden](https://gitee.com/changeden)
