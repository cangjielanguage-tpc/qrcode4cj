/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * This file is about picture type interface definition.
 */
package image.internals.model

import image.color.*

/**
 * The interface is Image inherited from Hashable
 * @author changeden
 */
public interface Image <: Hashable {
    /*
     * The Function is colorModel
     *
     * @return Type of color.Model
     */
    func colorModel(): Model
    /*
     * The Function is bounds
     *
     * @return Type of Rectangle
     */
    func bounds(): Rectangle
    /*
     * The Function is at
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Color
     */
    func at(x: Int64, y: Int64): Color

    /*
     * The Function is eq
     *
     * @param i of Image
     *
     * @return Type of Bool
     */
    func eq(i: Image): Bool
}

/**
 * The interface is RGBA64Image
 * @author changeden
 */
public interface RGBA64Image {
    /*
     * The Function is rgba64At
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of color.RGBA64C
     */
    func rgba64At(x: Int64, y: Int64): RGBA64C
}

/**
 * The interface is PalettedImage inherited from Image
 * @author changeden
 */
public interface PalettedImage <: Image {
    /*
     * The Function is colorIndexAt
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of UInt8
     */
    func colorIndexAt(x: Int64, y: Int64): UInt8
}

/**
 * The interface is ImageI inherited from Image
 * @author changeden
 */
public interface ImageI <: Image {
    /*
     * The Function is set
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     *
     * @return Type of Unit
     */
    func set(x: Int64, y: Int64, c: Color): Unit
}

/**
 * The interface is RGBA64ImageI inherited from RGBA64Image & ImageI
 * @author changeden
 */
public interface RGBA64ImageI <: RGBA64Image & ImageI {
    /*
     * The Function is set
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     *
     * @return Type of Unit
     */
    func set(x: Int64, y: Int64, c: Color): Unit
    /*
     * The Function is setRGBA64
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of color.RGBA64C
     *
     * @return Type of Unit
     */
    func setRGBA64(x: Int64, y: Int64, c: RGBA64C): Unit
}

/**
 * The interface is ImageT inherited from ImageI & Opaquer
 * @author changeden
 */
public interface ImageT <: ImageI & Opaquer {
    /*
     * The Function is subImage
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    func subImage(r: Rectangle): Image
}

/**
 * The interface is Opaquer
 * @author changeden
 */
public interface Opaquer {
    /*
     * The Function is opaque
     *
     * @return Type of Bool
     */
    func opaque(): Bool
}
