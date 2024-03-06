// 来自https://e.gitee.com/HW-PLLab-pro/dashboard?issue=I66L17&issue_detail_tab=attachment
package zxing.code.tools

from std import math.*
from std import collection.*

public class BigInteger {
    var number: String = "0"
    var sign: Bool = false

    public init() {}

    public init(number: String) {
        if (number.size == 0) {
            this.number = "0"
            this.sign = false
        } else if (number[0].isAsciiNumber()) {
            setNumber(number)
            this.sign = false
        } else {
            setNumber(number[Range<Int64>(0, 1, 1, true, true, false)])
            this.sign = (Char(number[0]) == '-')
        }
    }

    public init(number: String, sign: Bool) {
        setNumber(number)
        setSign(sign)
    }

    public init(number: Int64) {
        var s = number.toString()
        if (s[0].isAsciiNumber()) {
            this.number = s
            this.sign = false
        } else {
            setNumber(s[Range<Int64>(0, 1, 1, true, true, false)])
            this.sign = (Char(s[0]) == '-')
        }
    }

    public func setNumber(number: String) {
        this.number = number
    }

    public func getNumber() {
        return this.number
    }

    public func setSign(sign: Bool) {
        this.sign = sign
    }

    public func getSign() {
        return this.sign
    }

    // 返回绝对值
    public func absolute() {
        return BigInteger(getNumber())
    }

    // 重载相等运算符，判断两个数是否相等
    public operator func ==(b: BigInteger) {
        return equals(this, b)
    }

    // 重载不等运算符，判断两个数是否不等
    public operator func !=(b: BigInteger) {
        return !equals(this, b)
    }

    // 重载大于运算符，判断this是否大于b
    public operator func >(b: BigInteger) {
        return greater(this, b)
    }

    // 重载小于运算符，判断this是否小于b
    public operator func <(b: BigInteger) {
        return less(this, b)
    }

    // 重载大于等于运算符，判断this是否大于等于b
    public operator func >=(b: BigInteger) {
        return equals(this, b) || greater(this, b)
    }

    // 重载小于等于运算符，判断this是否小于等于b
    public operator func <=(b: BigInteger) {
        return equals(this, b) || less(this, b)
    }

    // 重载加号运算符，返回两个数的和
    public operator func +(b: BigInteger) {
        let addition = BigInteger()
        if (getSign() == b.getSign()) {
            addition.setNumber(add(getNumber(), b.getNumber()))
            addition.setSign(getSign())
        } else {
            if (absolute() > b.absolute()) {
                addition.setNumber(subtract(getNumber(), b.getNumber()))
                addition.setSign(getSign())
            } else {
                addition.setNumber(subtract(b.getNumber(), getNumber()))
                addition.setSign(b.getSign())
            }
        }
        if (addition.getNumber() == "0") {
            addition.setSign(false)
        }
        return addition
    }

    // 重载减号运算符，返回两个数的差
    public operator func -(b: BigInteger) {
        let t = BigInteger(b.getNumber())
        t.setSign(!b.getSign())
        return this + t
    }

    // 重载乘号运算符，返回两个数的乘积
    public operator func *(b: BigInteger) {
        let mul = BigInteger()
        mul.setNumber(multiply(getNumber(), b.getNumber()))
        mul.setSign(getSign() != b.getSign())

        if (mul.getNumber() == "0") {
            mul.setSign(false)
        }

        return mul
    }

    // 重载除号运算符，返回两个数的商
    public operator func /(b: BigInteger) {
        let den = toInt64(b.getNumber())
        let div = BigInteger()

        div.setNumber(divide(getNumber(), den)[0])
        div.setSign(getSign() != b.getSign())

        if (div.getNumber() == "0") {
            div.setSign(false)
        }

        return div
    }

    // 重载取余运算符，返回两个数取余的结果
    public operator func %(b: BigInteger) {
        let den = toInt64(b.getNumber())
        let rem = BigInteger()
        let remInt = divide(number, den)[1]

        rem.setNumber(remInt.toString())
        rem.setSign(getSign() != b.getSign())

        if (rem.getNumber() == "0") {
            rem.setSign(false)
        }

        return rem
    }

    public func toString() {
        if (sign) {
            return "-" + number
        }
        return number
    }

    private func equals(b1: BigInteger, b2: BigInteger) {
        return b1.getNumber() == b2.getNumber() && b1.getSign() == b2.getSign()
    }

    private func less(b1: BigInteger, b2: BigInteger) {
        let sign1 = b1.getSign()
        let sign2 = b2.getSign()

        if (sign1 && !sign2) {
            return true
        } else if (!sign1 && sign2) {
            return false
        } else if (!sign1) {
            if (b1.getNumber().size < b2.getNumber().size) {
                return true
            }
            if (b1.getNumber().size > b2.getNumber().size) {
                return false
            }
            return b1.getNumber() < b2.getNumber()
        } else {
            if (b1.getNumber().size > b2.getNumber().size) {
                return true
            }
            if (b1.getNumber().size < b2.getNumber().size) {
                return false
            }
            return b1.getNumber() > b2.getNumber()
        }
    }

    private func greater(b1: BigInteger, b2: BigInteger) {
        return !equals(b1, b2) && !less(b1, b2)
    }

    private func charToNumber(c: Byte): Int64 {
        return Int64(UInt32(c))
    }

    private func charToNumber(c: Char): Int64 {
        return Int64(UInt32(c)) - 48
    }

    private func numberToChar(n: Int64): Char {
        return Char(n + 48)
    }

    private func add(n1: String, n2: String) {
        let number1 = ArrayList<Char>(n1.toRuneArray())
        let number2 = ArrayList<Char>(n2.toRuneArray())
        let add = ArrayList<Char>()
        var carry = 0

        if (n1.size >= n2.size) {
            add.appendAll(number1)
            number2.insertAll(0, StringBuilder('0', n1.size - n2.size).toString().toRuneArray())
        } else {
            add.appendAll(number2)
            number1.insertAll(0, StringBuilder('0', n2.size - n1.size).toString().toRuneArray())
        }

        for (i in number1.size - 1..-1 : -1) {
            let v = carry + charToNumber(number1[i]) + charToNumber(number2[i])
            add[i] = numberToChar(v)

            if (i == 0) {
                continue
            }

            if (add[i] > '9') {
                add[i] = numberToChar(charToNumber(add[i]) - 10)
                carry = 1
            } else {
                carry = 0
            }
        }

        if (add[0] > '9') {
            add[0] = numberToChar(charToNumber(add[0]) - 10)
            add.insert(0, '1')
        }

        return String(add)
    }

    private func subtract(n1: String, n2: String) {
        let number1 = ArrayList<Char>(n1.toRuneArray())
        let number2 = ArrayList<Char>(n2.toRuneArray())
        let sub = ArrayList<Char>()

        if (n1.size >= n2.size) {
            sub.appendAll(number1)
            number2.insertAll(0, StringBuilder('0', n1.size - n2.size).toString().toRuneArray())
        } else {
            sub.appendAll(number2)
            number1.insertAll(0, StringBuilder('0', n2.size - n1.size).toString().toRuneArray())
        }

        for (i in number1.size - 1..-1 : -1) {
            if (number1[i] < number2[i]) {
                number1[i] = numberToChar(charToNumber(number1[i]) + 10)
                number1[i - 1] = numberToChar(charToNumber(number1[i - 1]) - 1)
            }
            sub[i] = numberToChar(charToNumber(number1[i]) - charToNumber(number2[i]))
        }

        while (sub[0] == '0' && sub.size != 1) {
            sub.remove(0)
        }

        return String(sub)
    }

    private func multiply(n1: String, n2: String) {
        let number1 = ArrayList<Char>()
        let number2 = ArrayList<Char>()
        var res = "0"

        if (n1.size > n2.size) {
            number1.appendAll(n2.toRuneArray())
            number2.appendAll(n1.toRuneArray())
        } else {
            number1.appendAll(n1.toRuneArray())
            number2.appendAll(n2.toRuneArray())
        }

        for (i in number1.size - 1..-1 : -1) {
            let tmp = ArrayList<Char>(number2)
            var carry = 0

            for (j in tmp.size - 1..-1 : -1) {
                tmp[j] = numberToChar(charToNumber(tmp[j]) * charToNumber(number1[i]) + carry)
                if (tmp[j] > '9') {
                    carry = charToNumber(tmp[j]) / 10
                    tmp[j] = numberToChar(charToNumber(tmp[j]) - carry * 10)
                } else {
                    carry = 0
                }
            }

            if (carry > 0) {
                tmp.insert(0, numberToChar(carry))
            }

            tmp.appendAll(StringBuilder('0', number1.size - i - 1).toString().toRuneArray())
            res = add(res, String(tmp))
        }

        let arr = ArrayList<Char>(res.toRuneArray())
        while (arr[0] == '0' && arr.size != 1) {
            arr.remove(0)
        }

        return String(arr)
    }

    private func divide(n: String, den: Int64): (String, Int64) {
        var rem = 0
        let result = ArrayList<Char>()

        for (i in 0..n.size) {
            rem = rem * 10 + charToNumber(Char(n[i]))
            result.append(numberToChar(rem / den))
            rem %= den
        }

        while (result[0] == '0' && result.size != 1) {
            result.remove(0)
        }

        if (result.size == 0) {
            result.append('0')
        }

        return (String(result), rem)
    }

    private func toInt64(n: String) {
        var sum = 0
        for (i in 0..n.size) {
            sum = sum * 10 + charToNumber(Char(n[i]))
        }
        return sum
    }
}
