# https://github.com/DavidBalishyan/nim-bigint
import strutils

type
  BigInt* = object
    ## Arbitrary-precision integer stored in little-endian base 10^9 digits.
    neg: bool
    digits: seq[int]

const
  Base*: int = 1_000_000_000
  ## Internal digit base: 10^9 fits in 32 bits, products fit in 64 bits.

  BaseDigits: int = 9
  ## Number of decimal digits per base-Base limb.

proc initBigInt*(): BigInt =
  ## Returns the BigInt zero.

proc isZero*(a: BigInt): bool =
  ## Returns true if `a` is zero.
  a.digits.len == 0 or (a.digits.len == 1 and a.digits[0] == 0)

proc len*(a: BigInt): int =
  ## Returns the number of internal base-Base digits (not decimal digits).
  a.digits.len

proc initBigInt*(n: int64): BigInt =
  ## Creates a BigInt from a 64-bit signed integer.
  if n == 0: return
  var n: int64 = n
  if n < 0:
    result.neg = true
    n = -n
  while n > 0:
    result.digits.add(int(n mod Base))
    n = n div Base

proc initBigInt*(s: string): BigInt =
  ## Creates a BigInt from a decimal string (e.g. "12345678901234567890").
  var s: string = s.strip()
  if s.len == 0: return
  if s[0] == '-':
    result.neg = true
    s = s[1..^1]
  var start: int= 0
  while start < s.len and s[start] == '0':
    start += 1
  if start == s.len: return
  s = s[start..^1]
  var i: int = s.len
  while i > 0:
    let chunkStart: int = max(0, i - BaseDigits)
    var chunk: string = s[chunkStart ..< i]
    if chunk.len == 0: break
    result.digits.add(parseInt(chunk))
    i = chunkStart

proc `$`*(a: BigInt): string =
  ## Converts a BigInt to its decimal string representation.
  if a.isZero: return "0"
  result = if a.neg: "-" else: ""
  for i in countdown(a.digits.high, 0):
    if i == a.digits.high:
      result.add($a.digits[i])
    else:
      result.add(($(a.digits[i] + Base))[1..^1])

# Internal: compare absolute values, ignoring sign.
proc cmpAbs(a, b: BigInt): int =
  if a.digits.len < b.digits.len: return -1
  if a.digits.len > b.digits.len: return 1
  for i in countdown(a.digits.high, 0):
    if a.digits[i] < b.digits[i]: return -1
    if a.digits[i] > b.digits[i]: return 1
  return 0

proc `==`*(a, b: BigInt): bool =
  ## Returns true if `a` == `b`.
  if a.isZero and b.isZero: return true
  a.neg == b.neg and cmpAbs(a, b) == 0

proc `<`*(a, b: BigInt): bool =
  ## Returns true if `a` < `b`.
  if a.isZero and b.isZero: return false
  if a.neg != b.neg: return a.neg
  if a.neg: return cmpAbs(a, b) > 0
  return cmpAbs(a, b) < 0

proc `<=`*(a, b: BigInt): bool = a < b or a == b
proc `>=`*(a, b: BigInt): bool = a > b or a == b
proc `>`*(a, b: BigInt): bool = b < a

proc `-`*(a: BigInt): BigInt =
  ## Negates a BigInt.
  if a.isZero: return a
  BigInt(neg: not a.neg, digits: a.digits)

# Internal: add absolute values, result always positive.
proc addAbs(a, b: BigInt): BigInt =
  let maxLen: int = max(a.digits.len, b.digits.len)
  var carry: int = 0
  result.digits = newSeq[int](maxLen)
  for i in 0..<maxLen:
    let da: int = if i < a.digits.len: a.digits[i] else: 0
    let db: int = if i < b.digits.len: b.digits[i] else: 0
    let s: int = da + db + carry
    result.digits[i] = s mod Base
    carry = s div Base
  if carry > 0:
    result.digits.add(carry)

# Internal: subtract absolute values, assumes |a| >= |b|, result always positive.
proc subAbs(a, b: BigInt): BigInt =
  result.digits = newSeq[int](a.digits.len)
  var borrow: int = 0
  for i in 0..<a.digits.len:
    let da: int = a.digits[i]
    let db: int = if i < b.digits.len: b.digits[i] else: 0
    var d: int = da - db - borrow
    if d < 0:
      d += Base
      borrow = 1
    else:
      borrow = 0
    result.digits[i] = d
  while result.digits.len > 1 and result.digits[^1] == 0:
    result.digits.setLen(result.digits.len - 1)

proc `+`*(a, b: BigInt): BigInt =
  ## Adds two BigInts.
  if a.neg == b.neg:
    result = addAbs(a, b)
    result.neg = a.neg
  else:
    let cmp = cmpAbs(a, b)
    if cmp == 0: return BigInt()
    if cmp > 0:
      result = subAbs(a, b)
      result.neg = a.neg
    else:
      result = subAbs(b, a)
      result.neg = b.neg

proc `-`*(a, b: BigInt): BigInt = a + (-b)
  ## Subtracts `b` from `a`.

proc `*`*(a, b: BigInt): BigInt =
  ## Multiplies two BigInts (O(n*m) schoolbook algorithm).
  if a.isZero or b.isZero: return BigInt()
  result.digits = newSeq[int](a.digits.len + b.digits.len)
  for i in 0..<a.digits.len:
    var carry: int = 0
    for j in 0..<b.digits.len:
      let prod: int = a.digits[i] * b.digits[j] + result.digits[i + j] + carry
      result.digits[i + j] = prod mod Base
      carry = prod div Base
    result.digits[i + b.digits.len] = carry
  while result.digits.len > 1 and result.digits[^1] == 0:
    result.digits.setLen(result.digits.len - 1)
  result.neg = a.neg xor b.neg

proc abs*(a: BigInt): BigInt =
  ## Returns the absolute value of `a`.
  result = a
  result.neg = false

proc sign*(a: BigInt): int =
  ## Returns -1 if `a` < 0, 0 if `a` == 0, 1 if `a` > 0.
  if a.isZero: return 0
  if a.neg: return -1
  return 1

# Internal: multiply a BigInt by a single base-Base digit.
proc mulDigit(a: BigInt, digit: int): BigInt =
  if digit == 0 or a.isZero: return BigInt()
  result.digits = newSeq[int](a.digits.len + 1)
  var carry: int = 0
  for i in 0..<a.digits.len:
    let prod: int = a.digits[i] * digit + carry
    result.digits[i] = prod mod Base
    carry = prod div Base
  result.digits[^1] = carry
  if carry == 0:
    result.digits.setLen(result.digits.len - 1)
  result.neg = a.neg

proc `divMod`*(a, b: BigInt): tuple[quot, rem: BigInt] =
  ## Returns `(quotient, remainder)` of `a` divided by `b`.
  ## Uses truncated division (remainder has same sign as dividend).
  ## Raises `AssertionError` on division by zero.
  assert(not b.isZero, "division by zero")
  if a.isZero:
    return (BigInt(), BigInt())
  let absCmp = cmpAbs(a, b)
  if absCmp < 0:
    return (BigInt(), a)
  if absCmp == 0:
    let one: BigInt = initBigInt(1)
    let q: BigInt = if a.neg xor b.neg: -one else: one
    return (q, BigInt())

  var rem: BigInt = abs(a)
  let absB: BigInt = abs(b)
  let kMax: int = rem.digits.len - absB.digits.len
  var qDigits: seq[int] = newSeq[int](kMax + 1)
  let divisorTop: int = absB.digits[^1]

  for k in countdown(kMax, 0):
    var lo: int = 0
    var hi: int = Base - 1

    let remTop: int = if k + absB.digits.len - 1 < rem.digits.len: rem.digits[k + absB.digits.len - 1] else: 0
    let remTop2: int = if k + absB.digits.len - 2 < rem.digits.len and k + absB.digits.len - 2 >= 0: rem.digits[k + absB.digits.len - 2] else: 0

    let estimated: uint64 = (uint64(remTop) * uint64(Base) + uint64(remTop2)) div uint64(max(1, divisorTop))
    if estimated < uint64(Base):
      if int(estimated) > lo:
        lo = int(estimated)
    if lo > hi: lo = hi

    var shiftedDigits: seq[int] = newSeq[int](absB.digits.len + k)
    for i in 0..<absB.digits.len:
      shiftedDigits[i + k] = absB.digits[i]
    let shifted: BigInt = BigInt(neg: false, digits: shiftedDigits)

    while lo < hi:
      let mid: int = (lo + hi + 1) div 2
      let prod: BigInt = mulDigit(shifted, mid)
      if cmpAbs(prod, rem) <= 0:
        lo = mid
      else:
        hi = mid - 1

    qDigits[k] = lo
    let sub: BigInt = mulDigit(shifted, lo)
    rem = subAbs(rem, sub)
    if rem.isZero:
      rem.neg = false

  while qDigits.len > 1 and qDigits[^1] == 0:
    qDigits.setLen(qDigits.len - 1)

  result.quot = BigInt(neg: a.neg xor b.neg, digits: qDigits)
  result.rem = BigInt(neg: a.neg, digits: rem.digits)
  if result.rem.isZero:
    result.rem.neg = false

proc `div`*(a, b: BigInt): BigInt = divMod(a, b).quot
  ## Divides `a` by `b`, returning the quotient (truncated toward zero).

proc `mod`*(a, b: BigInt): BigInt = divMod(a, b).rem
  ## Returns the remainder of `a` divided by `b` (sign matches dividend).

proc pow*(a: BigInt, exp: int): BigInt =
  ## Raises `a` to the non-negative integer power `exp` using binary exponentiation.
  if exp == 0: return initBigInt(1)
  if exp == 1: return a
  var base: BigInt = a
  var e: int = exp
  if e < 0:
    raise newException(ValueError, "negative exponent not supported")
  result = initBigInt(1)
  while e > 0:
    if (e and 1) == 1:
      result = result * base
    e = e shr 1
    if e > 0:
      base = base * base

proc gcd*(a, b: BigInt): BigInt =
  ## Returns the greatest common divisor of `a` and `b` (always non-negative).
  var x: BigInt = abs(a)
  var y: BigInt = abs(b)
  while not y.isZero:
    (x, y) = (y, x mod y)
  return x

proc `^`*(a: BigInt, exp: int): BigInt = pow(a, exp)
  ## Alias for `pow(a, exp)`. Usage: `a ^ 3`.
