#! /bin/bash

MODULE_NAME=image

src=`pwd`/src
PACKAGE_COLOR=${src}/color
PACKAGE_COLOR_PALETTE=${src}/color/palette
PACKAGE_INTERNALS_MODEL=${src}/internals/model
PACKAGE_IMAGE=${src}/image
PACKAGE_INTERNALS_IMAGE_UTIL=${src}/internals/imageutil
PACKAGE_DRAW=${src}/drawer

PACKAGE_COLOR_NAME=${MODULE_NAME}_color
PACKAGE_COLOR_PALETTE_NAME=${MODULE_NAME}_color_palette
PACKAGE_INTERNALS_MODEL_NAME=${MODULE_NAME}_internals_model
PACKAGE_IMAGE_NAME=${MODULE_NAME}_image
PACKAGE_INTERNALS_IMAGE_UTIL_NAME=${MODULE_NAME}_internals_imageutil
PACKAGE_DRAW_NAME=${MODULE_NAME}_drawer

BUILD_DIST_PATH=build/${MODULE_NAME}

export CANGJIE_PATH=`pwd`/libs/:`pwd`/build/:$CANGJIE_PATH
if [ -d "build" ]; then 
    rm -rf build
fi
mkdir -p ${BUILD_DIST_PATH}

cjc -p ${PACKAGE_COLOR} --module-name ${MODULE_NAME} --output-type=staticlib -o ${BUILD_DIST_PATH}/lib${PACKAGE_COLOR_NAME}.a
cjc -p ${PACKAGE_COLOR_PALETTE} --module-name ${MODULE_NAME} --output-type=staticlib -L build/image -l${PACKAGE_COLOR_NAME} -o ${BUILD_DIST_PATH}/lib${PACKAGE_COLOR_PALETTE_NAME}.a
cjc -p ${PACKAGE_INTERNALS_MODEL} --module-name ${MODULE_NAME} --output-type=staticlib -L build/image -l${PACKAGE_COLOR_NAME} -o ${BUILD_DIST_PATH}/lib${PACKAGE_INTERNALS_MODEL_NAME}.a
cjc -p ${PACKAGE_IMAGE} --module-name ${MODULE_NAME} --output-type=staticlib -L build/image -l${PACKAGE_COLOR_NAME} -L build/image -l${PACKAGE_INTERNALS_MODEL_NAME} -o ${BUILD_DIST_PATH}/lib${PACKAGE_IMAGE_NAME}.a
cjc -p ${PACKAGE_INTERNALS_IMAGE_UTIL} --module-name ${MODULE_NAME} --output-type=staticlib -L build/image -l${PACKAGE_COLOR_NAME} -L build/image -l${PACKAGE_IMAGE_NAME} -L build/image -l${PACKAGE_INTERNALS_MODEL_NAME} -o ${BUILD_DIST_PATH}/lib${PACKAGE_INTERNALS_IMAGE_UTIL_NAME}.a
cjc -p ${PACKAGE_DRAW} --module-name ${MODULE_NAME} --output-type=staticlib -L build/image -l${PACKAGE_COLOR_NAME} -L build/image -l${PACKAGE_IMAGE_NAME} -L build/image -l${PACKAGE_INTERNALS_MODEL_NAME} -L build/image -l${PACKAGE_INTERNALS_IMAGE_UTIL_NAME} -o ${BUILD_DIST_PATH}/lib${PACKAGE_DRAW_NAME}.a


# JPEG格式库
PACKAGE_IMAGE_JPEG=${src}/jpeg
PACKAGE_IMAGE_JPEG_NAME=${MODULE_NAME}_jpeg

cjc -p ${PACKAGE_IMAGE_JPEG} --module-name ${MODULE_NAME} --output-type=staticlib -L build/image -l${PACKAGE_COLOR_NAME} -L build/image -l${PACKAGE_IMAGE_NAME} -L build/image -l${PACKAGE_INTERNALS_MODEL_NAME} -L build/image -l${PACKAGE_INTERNALS_IMAGE_UTIL_NAME} -L build/image -l${PACKAGE_DRAW_NAME} -o ${BUILD_DIST_PATH}/lib${PACKAGE_IMAGE_JPEG_NAME}.a

# # 编译JPEG测试用例
cjc -p test/jpeg -L build/image -l${PACKAGE_COLOR_NAME} -L build/image -l${PACKAGE_IMAGE_NAME} -L build/image -l${PACKAGE_INTERNALS_MODEL_NAME} -L build/image -l${PACKAGE_INTERNALS_IMAGE_UTIL_NAME} -L build/image -l${PACKAGE_DRAW_NAME} -L build/image -l${PACKAGE_IMAGE_JPEG_NAME} -o build/test_jpeg
# # 执行JPEG测试用例
./build/test_jpeg


# PNG格式库
PACKAGE_IMAGE_PNG=${src}/png
PACKAGE_IMAGE_PNG_NAME=${MODULE_NAME}_png
PACKAGE_IMAGE_PNG_ZLIB=${PACKAGE_IMAGE_PNG}/zlib
PACKAGE_IMAGE_PNG_ZLIB_NAME=${PACKAGE_IMAGE_PNG_NAME}_zlib

cjc -p ${PACKAGE_IMAGE_PNG_ZLIB} --module-name ${MODULE_NAME} --output-type=staticlib -L build/image -l${PACKAGE_COLOR_NAME} -L build/image -l${PACKAGE_IMAGE_NAME} -L build/image -l${PACKAGE_INTERNALS_MODEL_NAME} -L build/image -l${PACKAGE_INTERNALS_IMAGE_UTIL_NAME} -L build/image -l${PACKAGE_DRAW_NAME} -o ${BUILD_DIST_PATH}/lib${PACKAGE_IMAGE_PNG_ZLIB_NAME}.a
cjc -p ${PACKAGE_IMAGE_PNG} --module-name ${MODULE_NAME} --output-type=staticlib -L build/image -l${PACKAGE_COLOR_NAME} -L build/image -l${PACKAGE_IMAGE_NAME} -L build/image -l${PACKAGE_INTERNALS_MODEL_NAME} -L build/image -l${PACKAGE_INTERNALS_IMAGE_UTIL_NAME} -L build/image -l${PACKAGE_DRAW_NAME} -L build/image -l${PACKAGE_IMAGE_PNG_ZLIB_NAME} -o ${BUILD_DIST_PATH}/lib${PACKAGE_IMAGE_PNG_NAME}.a

# # 编译PNG测试用例
cjc -p test/png -L build/image -l${PACKAGE_COLOR_NAME} -L build/image -l${PACKAGE_IMAGE_NAME} -L build/image -l${PACKAGE_INTERNALS_MODEL_NAME} -L build/image -l${PACKAGE_INTERNALS_IMAGE_UTIL_NAME} -L build/image -l${PACKAGE_DRAW_NAME} -L build/image -l${PACKAGE_IMAGE_PNG_ZLIB_NAME} -L build/image -l${PACKAGE_IMAGE_PNG_NAME} -o build/test_png
# # 执行PNG测试用例
./build/test_png

# GIF格式库
PACKAGE_IMAGE_GIF=${src}/gif
PACKAGE_IMAGE_GIF_NAME=${MODULE_NAME}_gif
PACKAGE_IMAGE_GIF_LZW=${PACKAGE_IMAGE_GIF}/lzw
PACKAGE_IMAGE_GIF_LZW_NAME=${PACKAGE_IMAGE_GIF_NAME}_lzw

cjc -p ${PACKAGE_IMAGE_GIF_LZW} --module-name ${MODULE_NAME} --output-type=staticlib -L build/image -l${PACKAGE_COLOR_NAME} -L build/image -l${PACKAGE_IMAGE_NAME} -L build/image -l${PACKAGE_INTERNALS_MODEL_NAME} -L build/image -l${PACKAGE_INTERNALS_IMAGE_UTIL_NAME} -L build/image -l${PACKAGE_DRAW_NAME} -o ${BUILD_DIST_PATH}/lib${PACKAGE_IMAGE_GIF_LZW_NAME}.a
cjc -p ${PACKAGE_IMAGE_GIF} --module-name ${MODULE_NAME} --output-type=staticlib -L build/image -l${PACKAGE_COLOR_NAME} -L build/image -l${PACKAGE_COLOR_PALETTE_NAME} -L build/image -l${PACKAGE_IMAGE_NAME} -L build/image -l${PACKAGE_INTERNALS_MODEL_NAME} -L build/image -l${PACKAGE_INTERNALS_IMAGE_UTIL_NAME} -L build/image -l${PACKAGE_DRAW_NAME} -L build/image -l${PACKAGE_IMAGE_GIF_LZW_NAME} -o ${BUILD_DIST_PATH}/lib${PACKAGE_IMAGE_GIF_NAME}.a

# 编译GIF测试用例
cjc -p test/gif -L build/image -l${PACKAGE_COLOR_NAME} -L build/image -l${PACKAGE_COLOR_PALETTE_NAME} -L build/image -l${PACKAGE_IMAGE_NAME} -L build/image -l${PACKAGE_INTERNALS_MODEL_NAME} -L build/image -l${PACKAGE_INTERNALS_IMAGE_UTIL_NAME} -L build/image -l${PACKAGE_DRAW_NAME} -L build/image -l${PACKAGE_IMAGE_GIF_LZW_NAME} -L build/image -l${PACKAGE_IMAGE_GIF_NAME} -o build/test_gif
# 执行GIF测试用例
./build/test_gif
