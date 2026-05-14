# プログラミングB演習対策 トグル版チートシート

対象範囲：§2.1 データ抽象入門 / §2.1.4 区間演算 / §2.2.2 階層構造 近辺  
想定問題：練習問題 2.1〜2.16、2.24〜2.32 付近

> 使い方：各項目は `<details>` タグでトグル形式にしている。Markdown対応環境では折りたたみ表示できる。

---

<details open>
<summary><strong>0. 共通で使うデバッグ補助</strong></summary>

有理数や区間は、そのまま表示するとペア表示になって見づらい。最初にこの補助関数を置くと確認しやすい。

```racket
#lang racket

(define (print-rat x)
  (display (numer x))
  (display "/")
  (display (denom x))
  (newline))

(define (print-interval x)
  (display "[")
  (display (lower-bound x))
  (display ", ")
  (display (upper-bound x))
  (display "]")
  (newline))
```

trace を使う場合：

```racket
(require racket/trace)

(trace 関数名)
```

例：

```racket
(trace fringe)
(fringe '((1 2) (3 4)))
```

</details>

---

<details open>
<summary><strong>1. まず覚える基本骨組み</strong></summary>

## 1-1. コンストラクタ・セレクタ型

データを作る手続きと、取り出す手続きを分ける型。

```racket
(define (make-data a b)
  (cons a b))

(define (first-data x)
  (car x))

(define (second-data x)
  (cdr x))
```

意味：

```text
make-data  : データを作る
first-data : 1つ目の情報を取り出す
second-data: 2つ目の情報を取り出す
```

## 1-2. 条件分岐型

```racket
(define (f x)
  (cond ((条件1) 値1)
        ((条件2) 値2)
        (else 値3)))
```

例：

```racket
(define (sign x)
  (cond ((< x 0) -1)
        ((= x 0) 0)
        (else 1)))
```

## 1-3. 木構造再帰型

```racket
(define (tree-proc tree)
  (cond ((null? tree) 空の場合の値)
        ((not (pair? tree)) 葉の場合の値)
        (else
         (car側とcdr側を再帰する式))))
```

典型形：

```racket
(define (tree-proc tree)
  (cond ((null? tree) '())
        ((not (pair? tree)) tree)
        (else
         (cons (tree-proc (car tree))
               (tree-proc (cdr tree))))))
```

</details>

---

<details>
<summary><strong>練習問題 2.1：有理数の符号正規化</strong></summary>

## 問題要約

有理数を `n/d` として表す。  
`make-rat` を改良し、正の有理数なら分子・分母が正、負の有理数なら分子だけが負になるようにする。

## 問題の型

- `make-rat / numer / denom` 型
- 抽象化の壁型

## 骨組み

```racket
(define (make-rat n d)
  (let ((g (gcd n d)))
    (let ((nn ...)
          (dd ...))
      (if ...
          ...
          ...))))
```

## 解答

```racket
(define (make-rat n d)
  (let ((g (gcd n d)))
    (let ((nn (/ n g))
          (dd (/ d g)))
      (if (< dd 0)
          (cons (- nn) (- dd))
          (cons nn dd)))))

(define (numer x)
  (car x))

(define (denom x)
  (cdr x))
```

## デバッグ用呼び出し例

```racket
(print-rat (make-rat 6 8))
; 3/4
```

```racket
(print-rat (make-rat 6 -8))
; -3/4
```

```racket
(print-rat (make-rat -6 -8))
; 3/4
```

## 数学発展

### 分数の代表元

```text
6/-8 = -3/4
-6/-8 = 3/4
```

同じ有理数に複数の表し方があるため、`make-rat` で標準形にそろえる。

## 追記コード：分母0チェック

元の `make-rat` を残す場合、追記コードだけで安全版を作れる。

```racket
(define (make-rat-safe n d)
  (if (= d 0)
      (error "denominator must not be zero")
      (make-rat n d)))
```

デバッグ：

```racket
(print-rat (make-rat-safe 4 6))
; 2/3
```

```racket
(make-rat-safe 1 0)
; error
```

## 発展：有理数の大小比較

数学でいうと、分母が正なら：

```text
a/b < c/d  ⇔  a*d < c*b
```

追記コード：

```racket
(define (less-rat? x y)
  (< (* (numer x) (denom y))
     (* (numer y) (denom x))))
```

デバッグ：

```racket
(less-rat? (make-rat 1 2) (make-rat 2 3))
; #t
```

```racket
(less-rat? (make-rat 3 4) (make-rat 2 3))
; #f
```

</details>

---

<details>
<summary><strong>練習問題 2.2：点と線分の中点</strong></summary>

## 問題要約

点を `(x, y)` として表し、線分を始点と終点から作る。  
線分の中点を返す `midpoint-segment` を定義する。

## 問題の型

点・線分のコンストラクタ・セレクタ型。

## 骨組み

```racket
(define (make-point x y)
  ...)

(define (x-point p)
  ...)

(define (y-point p)
  ...)

(define (make-segment start end)
  ...)

(define (midpoint-segment s)
  (make-point
   x座標の平均
   y座標の平均))
```

## 解答

```racket
(define (make-point x y)
  (cons x y))

(define (x-point p)
  (car p))

(define (y-point p)
  (cdr p))

(define (make-segment start end)
  (cons start end))

(define (start-segment s)
  (car s))

(define (end-segment s)
  (cdr s))

(define (midpoint-segment s)
  (make-point
   (/ (+ (x-point (start-segment s))
         (x-point (end-segment s)))
      2)
   (/ (+ (y-point (start-segment s))
         (y-point (end-segment s)))
      2)))
```

## デバッグ用呼び出し例

```racket
(define p1 (make-point 2 4))
(define p2 (make-point 8 10))
(define s1 (make-segment p1 p2))

(x-point (midpoint-segment s1))
; 5
```

```racket
(y-point (midpoint-segment s1))
; 7
```

## 数学発展

### 距離公式

2点間の距離：

```text
√((x2 - x1)^2 + (y2 - y1)^2)
```

追記コード：

```racket
(define (square x)
  (* x x))

(define (distance-point p q)
  (sqrt (+ (square (- (x-point q) (x-point p)))
           (square (- (y-point q) (y-point p))))))

(define (length-segment s)
  (distance-point (start-segment s)
                  (end-segment s)))
```

デバッグ：

```racket
(length-segment (make-segment (make-point 0 0)
                              (make-point 3 4)))
; 5
```

```racket
(length-segment (make-segment (make-point 1 1)
                              (make-point 1 6)))
; 5
```

### 傾き

```text
m = (y2 - y1) / (x2 - x1)
```

追記コード：

```racket
(define (slope-segment s)
  (/ (- (y-point (end-segment s))
        (y-point (start-segment s)))
     (- (x-point (end-segment s))
        (x-point (start-segment s)))))
```

デバッグ：

```racket
(slope-segment (make-segment (make-point 0 0)
                             (make-point 2 4)))
; 2
```

```racket
(slope-segment (make-segment (make-point 1 3)
                             (make-point 5 11)))
; 2
```

</details>

---

<details>
<summary><strong>練習問題 2.3：長方形の面積と周の長さ</strong></summary>

## 問題要約

長方形をデータとして表し、面積と周の長さを求める。  
内部表現を変えても、面積や周の計算は変えずに済むようにする。

## 問題の型

- 抽象化の壁型
- 複数表現型

## 骨組み

```racket
(define (make-rect ...)
  ...)

(define (width-rect r)
  ...)

(define (height-rect r)
  ...)

(define (area-rect r)
  (* (width-rect r) (height-rect r)))

(define (perimeter-rect r)
  (* 2 (+ (width-rect r) (height-rect r))))
```

## 解答：左下点と右上点で表す版

```racket
(define (make-rect p1 p2)
  (cons p1 p2))

(define (left-bottom r)
  (car r))

(define (right-top r)
  (cdr r))

(define (width-rect r)
  (abs (- (x-point (right-top r))
          (x-point (left-bottom r)))))

(define (height-rect r)
  (abs (- (y-point (right-top r))
          (y-point (left-bottom r)))))

(define (area-rect r)
  (* (width-rect r) (height-rect r)))

(define (perimeter-rect r)
  (* 2 (+ (width-rect r) (height-rect r))))
```

## デバッグ用呼び出し例

```racket
(define r1 (make-rect (make-point 1 2)
                      (make-point 6 5)))

(area-rect r1)
; 15
```

```racket
(perimeter-rect r1)
; 16
```

## 数学発展

### 点が長方形の内部にあるか

```text
xmin <= x <= xmax
ymin <= y <= ymax
```

追記コード：

```racket
(define (inside-rect? p r)
  (and (<= (x-point (left-bottom r))
           (x-point p)
           (x-point (right-top r)))
       (<= (y-point (left-bottom r))
           (y-point p)
           (y-point (right-top r)))))
```

デバッグ：

```racket
(inside-rect? (make-point 3 3) r1)
; #t
```

```racket
(inside-rect? (make-point 10 3) r1)
; #f
```

</details>

---

<details>
<summary><strong>練習問題 2.4：手続きで cons を表す</strong></summary>

## 問題要約

`cons` を普通のペアではなく、手続きとして表す。  
与えられた `cons` に対して `car` と `cdr` を定義する。

## 問題の型

- lambda 型
- データとは何か型

## 注意

この問題では `cons`, `car`, `cdr` を再定義するので、他の問題とは別ファイルで試すのが安全。

## 骨組み

```racket
(define (cons x y)
  (lambda (m)
    ...))

(define (car z)
  (z ...))

(define (cdr z)
  (z ...))
```

## 解答

```racket
(define (cons x y)
  (lambda (m)
    (m x y)))

(define (car z)
  (z (lambda (p q) p)))

(define (cdr z)
  (z (lambda (p q) q)))
```

## デバッグ用呼び出し例

```racket
(car (cons 1 2))
; 1
```

```racket
(cdr (cons 1 2))
; 2
```

## 数学発展

順序対を「値」ではなく「操作」で定義している例。

```text
pair(x, y) に first を渡すと x
pair(x, y) に second を渡すと y
```

## 追記コード：swap

```racket
(define (swap-pair z)
  (cons (cdr z) (car z)))
```

デバッグ：

```racket
(car (swap-pair (cons 1 2)))
; 2
```

```racket
(cdr (swap-pair (cons 1 2)))
; 1
```

</details>

---

<details>
<summary><strong>練習問題 2.5：素因数分解でペアを表す</strong></summary>

## 問題要約

非負整数のペア `(a, b)` を次の形で表す。

```text
2^a * 3^b
```

この表現に対して `cons`, `car`, `cdr` を定義する。

## 問題の型

- 素因数分解型
- データ表現型

## 注意

この問題も `cons`, `car`, `cdr` を再定義するので、別ファイル推奨。

## 骨組み

```racket
(define (cons a b)
  (* ... ...))

(define (count-factor n factor)
  (define (iter n count)
    (if ...
        ...
        ...))
  (iter n 0))

(define (car z)
  ...)

(define (cdr z)
  ...)
```

## 解答

```racket
(define (cons a b)
  (* (expt 2 a)
     (expt 3 b)))

(define (count-factor n factor)
  (define (iter n count)
    (if (= (remainder n factor) 0)
        (iter (/ n factor) (+ count 1))
        count))
  (iter n 0))

(define (car z)
  (count-factor z 2))

(define (cdr z)
  (count-factor z 3))
```

## デバッグ用呼び出し例

```racket
(define z1 (cons 3 2))
z1
; 72
```

```racket
(car z1)
; 3
```

```racket
(cdr z1)
; 2
```

## 数学発展

### 素因数分解の一意性

```text
n = 2^a * 3^b
```

と表したとき、`a` と `b` は一意に決まる。

## 追記コード：3要素版

3要素 `(a, b, c)` を、

```text
2^a * 3^b * 5^c
```

で表す。

```racket
(define (make-triple a b c)
  (* (expt 2 a)
     (expt 3 b)
     (expt 5 c)))

(define (first-triple z)
  (count-factor z 2))

(define (second-triple z)
  (count-factor z 3))

(define (third-triple z)
  (count-factor z 5))
```

デバッグ：

```racket
(define t1 (make-triple 2 3 1))
(first-triple t1)
; 2
```

```racket
(second-triple t1)
; 3
```

```racket
(third-triple t1)
; 1
```

</details>

---

<details>
<summary><strong>練習問題 2.6：Church 数</strong></summary>

## 問題要約

自然数を「関数を何回適用するか」として表す。  
`zero`, `add-1` から `one`, `two`, 足し算を定義する。

## 問題の型

- 高階手続き型
- lambda 型
- 数を手続きで表す型

## 骨組み

```racket
(define zero
  (lambda (f)
    (lambda (x)
      ...)))

(define one
  (lambda (f)
    (lambda (x)
      ...)))

(define two
  (lambda (f)
    (lambda (x)
      ...)))
```

## 解答

```racket
(define zero
  (lambda (f)
    (lambda (x)
      x)))

(define (add-1 n)
  (lambda (f)
    (lambda (x)
      (f ((n f) x)))))

(define one
  (lambda (f)
    (lambda (x)
      (f x))))

(define two
  (lambda (f)
    (lambda (x)
      (f (f x)))))

(define (church-plus m n)
  (lambda (f)
    (lambda (x)
      ((m f) ((n f) x)))))
```

## デバッグ用呼び出し例

```racket
((zero add1) 0)
; 0
```

```racket
((one add1) 0)
; 1
```

```racket
((two add1) 0)
; 2
```

```racket
(((church-plus one two) add1) 0)
; 3
```

## 数学発展

### 関数合成と自然数

```text
2 = fを2回適用する操作
3 = fを3回適用する操作
```

足し算は「適用回数を足す」こと。

## 追記コード：掛け算

```racket
(define (church-mul m n)
  (lambda (f)
    (m (n f))))
```

デバッグ：

```racket
(((church-mul two two) add1) 0)
; 4
```

```racket
(((church-mul two (church-plus one two)) add1) 0)
; 6
```

</details>

---

<details>
<summary><strong>練習問題 2.7：区間のセレクタ</strong></summary>

## 問題要約

区間 `[a, b]` を作る `make-interval` がある。  
下限と上限を取り出す `lower-bound`, `upper-bound` を定義する。

## 問題の型

コンストラクタ・セレクタ型。

## 骨組み

```racket
(define (make-interval a b)
  (cons a b))

(define (lower-bound x)
  ...)

(define (upper-bound x)
  ...)
```

## 解答

```racket
(define (make-interval a b)
  (cons a b))

(define (lower-bound x)
  (car x))

(define (upper-bound x)
  (cdr x))
```

## デバッグ用呼び出し例

```racket
(define i1 (make-interval 2 5))
(lower-bound i1)
; 2
```

```racket
(upper-bound i1)
; 5
```

## 数学発展

区間は誤差つきの値。

```text
[2, 5] は 2以上5以下のどれか
```

## 追記コード：区間の中心と幅

```racket
(define (center i)
  (/ (+ (lower-bound i) (upper-bound i)) 2))

(define (width i)
  (/ (- (upper-bound i) (lower-bound i)) 2))
```

デバッグ：

```racket
(center (make-interval 2 6))
; 4
```

```racket
(width (make-interval 2 6))
; 2
```

</details>

---

<details>
<summary><strong>練習問題 2.8：区間の引き算</strong></summary>

## 問題要約

2つの区間の差を計算する `sub-interval` を定義する。

## 問題の型

区間演算型。

## 数学でいう式

```text
[a, b] - [c, d] = [a - d, b - c]
```

## 骨組み

```racket
(define (sub-interval x y)
  (make-interval
   下限
   上限))
```

## 解答

```racket
(define (sub-interval x y)
  (make-interval
   (- (lower-bound x) (upper-bound y))
   (- (upper-bound x) (lower-bound y))))
```

## デバッグ用呼び出し例

```racket
(print-interval
 (sub-interval (make-interval 10 20)
               (make-interval 3 5)))
; [5, 17]
```

```racket
(print-interval
 (sub-interval (make-interval 1 4)
               (make-interval -2 3)))
; [-2, 6]
```

## 数学発展

### 区間の符号反転

```text
-[a, b] = [-b, -a]
```

## 追記コード

```racket
(define (neg-interval x)
  (make-interval
   (- (upper-bound x))
   (- (lower-bound x))))
```

デバッグ：

```racket
(print-interval (neg-interval (make-interval 2 5)))
; [-5, -2]
```

```racket
(print-interval (neg-interval (make-interval -3 4)))
; [-4, 3]
```

</details>

---

<details>
<summary><strong>練習問題 2.9：区間の幅</strong></summary>

## 問題要約

区間の幅は `(上限 - 下限) / 2`。  
和や差の幅は元の幅だけで決まるが、積や商ではそうならないことを示す。

## 問題の型

証明・反例型。

## 解答コード

```racket
(define (width x)
  (/ (- (upper-bound x) (lower-bound x)) 2))
```

加算も必要なら：

```racket
(define (add-interval x y)
  (make-interval
   (+ (lower-bound x) (lower-bound y))
   (+ (upper-bound x) (upper-bound y))))
```

掛け算も必要なら：

```racket
(define (mul-interval x y)
  (let ((p1 (* (lower-bound x) (lower-bound y)))
        (p2 (* (lower-bound x) (upper-bound y)))
        (p3 (* (upper-bound x) (lower-bound y)))
        (p4 (* (upper-bound x) (upper-bound y))))
    (make-interval
     (min p1 p2 p3 p4)
     (max p1 p2 p3 p4))))
```

## デバッグ用呼び出し例

```racket
(width (add-interval (make-interval 1 3)
                     (make-interval 10 14)))
; 3
```

```racket
(+ (width (make-interval 1 3))
   (width (make-interval 10 14)))
; 3
```

反例：

```racket
(width (mul-interval (make-interval 1 3)
                     (make-interval 1 3)))
; 4
```

```racket
(width (mul-interval (make-interval 10 12)
                     (make-interval 10 12)))
; 22
```

## 数学発展

### 和の幅

```text
width([a,b] + [c,d])
= ((b+d) - (a+c)) / 2
= ((b-a) + (d-c)) / 2
= width([a,b]) + width([c,d])
```

### 積は幅だけでは決まらない

幅が同じでも、中心が違うと積の幅は変わる。

## 追記コード：幅が等しいかの確認

```racket
(define (same-width? x y)
  (= (width x) (width y)))
```

デバッグ：

```racket
(same-width? (make-interval 1 3)
             (make-interval 10 12))
; #t
```

```racket
(width (mul-interval (make-interval 1 3)
                     (make-interval 10 12)))
; 17
```

</details>

---

<details>
<summary><strong>練習問題 2.10：ゼロをまたぐ区間で割らない</strong></summary>

## 問題要約

区間で割り算するとき、割る側の区間が 0 を含むならエラーを出すようにする。

## 問題の型

- 条件分岐型
- エラーチェック型

## 数学でいう式

```text
x / y = x * (1/y)
```

ただし：

```text
0 ∈ y
```

なら `1/y` は定義できない。

## 骨組み

```racket
(define (spans-zero? x)
  ...)

(define (div-interval x y)
  (if (spans-zero? y)
      エラー
      通常の割り算))
```

## 解答

```racket
(define (spans-zero? x)
  (and (<= (lower-bound x) 0)
       (<= 0 (upper-bound x))))

(define (div-interval x y)
  (if (spans-zero? y)
      (error "division by interval that spans zero")
      (mul-interval
       x
       (make-interval
        (/ 1.0 (upper-bound y))
        (/ 1.0 (lower-bound y))))))
```

## デバッグ用呼び出し例

```racket
(print-interval
 (div-interval (make-interval 2 4)
               (make-interval 2 5)))
; [0.4, 2.0]
```

```racket
(div-interval (make-interval 2 4)
              (make-interval -1 3))
; error
```

## 数学発展

### 定義域

関数 `f(x)=1/x` の定義域は：

```text
x ≠ 0
```

区間が 0 を含むかどうかは、定義域チェックに対応する。

## 追記コード：安全な逆数

```racket
(define (reciprocal-interval x)
  (if (spans-zero? x)
      (error "reciprocal of interval spanning zero")
      (make-interval
       (/ 1.0 (upper-bound x))
       (/ 1.0 (lower-bound x)))))
```

デバッグ：

```racket
(print-interval (reciprocal-interval (make-interval 2 4)))
; [0.25, 0.5]
```

```racket
(reciprocal-interval (make-interval -1 1))
; error
```

</details>

---

<details>
<summary><strong>練習問題 2.11：区間の掛け算の場合分け</strong></summary>

## 問題要約

区間の両端の符号によって場合分けし、`mul-interval` をより効率よく書き直す。

## 問題の型

- 条件分岐型
- 場合分け最適化型

## 骨組み

```racket
(define (mul-interval x y)
  (cond ((xが正でyが正) ...)
        ((xが正でyが負) ...)
        ((xが正でyが0またぎ) ...)
        ...
        (else ...)))
```

## 解答

```racket
(define (positive-interval? x)
  (>= (lower-bound x) 0))

(define (negative-interval? x)
  (<= (upper-bound x) 0))

(define (mixed-interval? x)
  (and (< (lower-bound x) 0)
       (> (upper-bound x) 0)))

(define (mul-interval x y)
  (let ((xl (lower-bound x))
        (xu (upper-bound x))
        (yl (lower-bound y))
        (yu (upper-bound y)))
    (cond
      ((and (positive-interval? x) (positive-interval? y))
       (make-interval (* xl yl) (* xu yu)))

      ((and (positive-interval? x) (negative-interval? y))
       (make-interval (* xu yl) (* xl yu)))

      ((and (positive-interval? x) (mixed-interval? y))
       (make-interval (* xu yl) (* xu yu)))

      ((and (negative-interval? x) (positive-interval? y))
       (make-interval (* xl yu) (* xu yl)))

      ((and (negative-interval? x) (negative-interval? y))
       (make-interval (* xu yu) (* xl yl)))

      ((and (negative-interval? x) (mixed-interval? y))
       (make-interval (* xl yu) (* xl yl)))

      ((and (mixed-interval? x) (positive-interval? y))
       (make-interval (* xl yu) (* xu yu)))

      ((and (mixed-interval? x) (negative-interval? y))
       (make-interval (* xu yl) (* xl yl)))

      (else
       (make-interval
        (min (* xl yu) (* xu yl))
        (max (* xl yl) (* xu yu)))))))
```

## デバッグ用呼び出し例

```racket
(print-interval
 (mul-interval (make-interval 2 5)
               (make-interval 3 7)))
; [6, 35]
```

```racket
(print-interval
 (mul-interval (make-interval -5 -2)
               (make-interval 3 7)))
; [-35, -6]
```

```racket
(print-interval
 (mul-interval (make-interval -2 3)
               (make-interval -5 7)))
; [-15, 21]
```

## 数学発展

### 符号による最大最小

積の最大・最小は、端点の積で決まる。

```text
[a,b] * [c,d] の候補:
ac, ad, bc, bd
```

この4つの最小値と最大値が区間の端になる。

## 追記コード：安全版との比較

```racket
(define (mul-interval-general x y)
  (let ((p1 (* (lower-bound x) (lower-bound y)))
        (p2 (* (lower-bound x) (upper-bound y)))
        (p3 (* (upper-bound x) (lower-bound y)))
        (p4 (* (upper-bound x) (upper-bound y))))
    (make-interval
     (min p1 p2 p3 p4)
     (max p1 p2 p3 p4))))
```

デバッグ：

```racket
(print-interval
 (mul-interval-general (make-interval -2 3)
                       (make-interval -5 7)))
; [-15, 21]
```

```racket
(print-interval
 (mul-interval (make-interval -2 3)
               (make-interval -5 7)))
; [-15, 21]
```

</details>

---

<details>
<summary><strong>練習問題 2.12：中心とパーセントで区間を作る</strong></summary>

## 問題要約

区間を「中心値」と「許容誤差率」から作れるようにする。  
また、区間からパーセント誤差を取り出す。

## 問題の型

- 別表現追加型
- 区間演算型

## 数学でいう式

中心 `c`、誤差率 `p%` なら：

```text
幅 = c * p / 100
区間 = [c - 幅, c + 幅]
```

## 骨組み

```racket
(define (make-center-percent c p)
  ...)

(define (percent i)
  ...)
```

## 解答

```racket
(define (make-center-width c w)
  (make-interval (- c w) (+ c w)))

(define (make-center-percent c p)
  (make-center-width c (* c (/ p 100))))

(define (percent i)
  (* 100 (/ (width i) (center i))))
```

## デバッグ用呼び出し例

```racket
(print-interval (make-center-percent 100 5))
; [95, 105]
```

```racket
(percent (make-interval 95 105))
; 5
```

## 数学発展

### 相対誤差

```text
相対誤差 = 幅 / 中心
パーセント誤差 = 100 * 幅 / 中心
```

## 追記コード：相対誤差

```racket
(define (relative-error i)
  (/ (width i) (center i)))
```

デバッグ：

```racket
(relative-error (make-interval 95 105))
; 1/20 または 0.05
```

```racket
(* 100 (relative-error (make-interval 90 110)))
; 10
```

</details>

---

<details>
<summary><strong>練習問題 2.13：積のパーセント誤差</strong></summary>

## 問題要約

小さいパーセント誤差をもつ区間同士の積では、積の誤差率がおよそ誤差率の和になることを説明する。

## 問題の型

数学的近似型。

## 数学でいう式

```text
(1 ± p)(1 ± q)
= 1 ± p ± q + pq
```

`p` と `q` が小さいなら、`pq` はとても小さいので無視する。

```text
積の誤差率 ≒ p + q
```

## 確認用コード

```racket
(define (percent-of-product x y)
  (percent (mul-interval x y)))
```

## デバッグ用呼び出し例

```racket
(percent-of-product (make-center-percent 100 1)
                    (make-center-percent 200 2))
; 約3に近い値
```

```racket
(percent-of-product (make-center-percent 100 0.5)
                    (make-center-percent 200 0.5))
; 約1に近い値
```

## 数学発展

### 一次近似

```text
p, q が小さいとき pq を無視する
```

これは微分や近似で出てくる一次近似の考え方。

## 追記コード：近似式だけで計算

```racket
(define (approx-product-percent p q)
  (+ p q))
```

デバッグ：

```racket
(approx-product-percent 1 2)
; 3
```

```racket
(approx-product-percent 0.5 0.5)
; 1.0
```

</details>

---

<details>
<summary><strong>練習問題 2.14：並列抵抗 par1 / par2</strong></summary>

## 問題要約

並列抵抗の2つの等価な式を区間演算で計算し、結果が異なることを確認する。

## 問題の型

区間演算の依存性型。

## 数学でいう式

```text
par1 = (R1 * R2) / (R1 + R2)
```

```text
par2 = 1 / (1/R1 + 1/R2)
```

実数では同じ。

## 解答

```racket
(define (par1 r1 r2)
  (div-interval
   (mul-interval r1 r2)
   (add-interval r1 r2)))

(define (par2 r1 r2)
  (let ((one (make-interval 1 1)))
    (div-interval
     one
     (add-interval
      (div-interval one r1)
      (div-interval one r2)))))
```

## デバッグ用呼び出し例

```racket
(define rA (make-center-percent 100 1))
(define rB (make-center-percent 200 1))

(print-interval (par1 rA rB))
```

```racket
(print-interval (par2 rA rB))
```

## 数学発展

### 同値変形と区間演算の違い

実数では：

```text
x/x = 1
```

しかし区間では：

```text
[2,3] / [2,3] = [2/3, 3/2]
```

のように広がることがある。

## 追記コード：A/A の確認

```racket
(define (interval-self-div x)
  (div-interval x x))
```

デバッグ：

```racket
(print-interval (interval-self-div (make-interval 2 3)))
; [0.666..., 1.5]
```

```racket
(print-interval (interval-self-div (make-interval 10 10)))
; [1.0, 1.0]
```

</details>

---

<details>
<summary><strong>練習問題 2.15：par1 と par2 のどちらがよいか</strong></summary>

## 問題要約

同じ不確かな変数を何度も使う式は、区間演算で誤差が広がりやすい。  
`par1` と `par2` のどちらがよいか説明する。

## 問題の型

考察型。

## 解答の考え方

`par2` の方がよいと考えられる。  
`par1` は `r1`, `r2` を複数回使うため、依存性の問題で区間が広がりやすい。  
`par2` は各抵抗を比較的少ない回数で使うため、結果が狭くなりやすい。

## デバッグ用呼び出し例

```racket
(percent (par1 rA rB))
```

```racket
(percent (par2 rA rB))
```

## 数学発展

### 誤差の依存性

```text
同じ x なのに、式の中で複数回出ると別々の値のように扱われる
```

これが区間演算の弱点。

## 追記コード：区間幅の比較

```racket
(define (narrower? x y)
  (< (width x) (width y)))
```

デバッグ：

```racket
(narrower? (par2 rA rB) (par1 rA rB))
; #t になりやすい
```

```racket
(width (par1 rA rB))
(width (par2 rA rB))
```

</details>

---

<details>
<summary><strong>練習問題 2.16：等価な式でも結果が違う問題</strong></summary>

## 問題要約

代数的に同じ式が、区間演算では違う結果になる理由を説明する。  
一般的にこの問題を解くのは難しいことを述べる。

## 問題の型

理論・考察型。

## 解答の考え方

普通の区間演算では、同じ変数に由来する不確かさを覚えていない。  
そのため、代数的には同じでも区間の結果は異なる。

## デバッグ用呼び出し例

```racket
(print-interval
 (div-interval (make-interval 2 3)
               (make-interval 2 3)))
; [0.666..., 1.5]
```

```racket
(print-interval
 (make-interval 1 1))
; [1, 1]
```

## 数学発展

### 記号計算との違い

記号計算なら：

```text
x/x = 1
```

と変形できる。  
しかし区間演算では、`x` が同じ変数だという情報を保持しないため、単純にはできない。

## 追記コード：単位区間判定

```racket
(define (unit-interval? x)
  (and (= (lower-bound x) 1)
       (= (upper-bound x) 1)))
```

デバッグ：

```racket
(unit-interval? (make-interval 1 1))
; #t
```

```racket
(unit-interval? (div-interval (make-interval 2 3)
                              (make-interval 2 3)))
; #f
```

</details>

---

<details>
<summary><strong>練習問題 2.24：入れ子リストの構造</strong></summary>

## 問題要約

次の式がどのようなリスト構造・木構造になるかを考える。

```racket
(list 1 (list 2 (list 3 4)))
```

## 問題の型

リスト構造理解型。

## 解答

```racket
(list 1 (list 2 (list 3 4)))
; '(1 (2 (3 4)))
```

`cons` で見ると、おおよそ次。

```racket
(cons 1
      (cons (cons 2
                  (cons (cons 3
                              (cons 4 '()))
                        '()))
            '()))
```

## デバッグ用呼び出し例

```racket
(define x24 (list 1 (list 2 (list 3 4))))
x24
; '(1 (2 (3 4)))
```

```racket
(car x24)
; 1
```

```racket
(car (cdr x24))
; '(2 (3 4))
```

## 数学発展

### 木構造

```text
根
├─ 1
└─ 部分木
   ├─ 2
   └─ 部分木
      ├─ 3
      └─ 4
```

## 追記コード：葉の個数

```racket
(define (count-leaves tree)
  (cond ((null? tree) 0)
        ((not (pair? tree)) 1)
        (else
         (+ (count-leaves (car tree))
            (count-leaves (cdr tree))))))
```

デバッグ：

```racket
(count-leaves x24)
; 4
```

```racket
(count-leaves '((1 2) (3 4)))
; 4
```

</details>

---

<details>
<summary><strong>練習問題 2.25：car / cdr で値を取り出す</strong></summary>

## 問題要約

複雑なリストから、`car` と `cdr` だけを使って指定された値を取り出す。

## 問題の型

経路探索型。

## 骨組み

```racket
(car (cdr ...))
```

`car` は先頭、`cdr` は残り。

## 解答例1

```racket
(define x25a (list 1 3 (list 5 7) 9))

(car (cdr (car (cdr (cdr x25a)))))
; 7
```

## 解答例2

```racket
(define x25b (list (list 7)))

(car (car x25b))
; 7
```

## 解答例3

```racket
(define x25c (list 1
                   (list 2
                         (list 3
                               (list 4
                                     (list 5
                                           (list 6 7)))))))

(car (cdr (car (cdr (car (cdr (car (cdr (car (cdr (car (cdr x25c))))))))))))
; 7
```

## デバッグ用呼び出し例

```racket
(car (cdr (cdr x25a)))
; '(5 7)
```

```racket
(cdr (car (cdr (cdr x25a))))
; '(7)
```

## 数学発展

これは木の「経路」を指定する問題。

```text
car = 左へ行く
cdr = 右/残りへ行く
```

## 追記コード：car/cdr経路の確認補助

```racket
(define (second xs)
  (car (cdr xs)))

(define (third xs)
  (car (cdr (cdr xs))))
```

デバッグ：

```racket
(third x25a)
; '(5 7)
```

```racket
(second (third x25a))
; 7
```

</details>

---

<details>
<summary><strong>練習問題 2.26：append / cons / list の違い</strong></summary>

## 問題要約

`append`, `cons`, `list` に同じリストを渡したとき、結果がどう違うか確認する。

## 問題の型

リスト操作比較型。

## 解答

```racket
(define x26 (list 1 2 3))
(define y26 (list 4 5 6))

(append x26 y26)
; '(1 2 3 4 5 6)

(cons x26 y26)
; '((1 2 3) 4 5 6)

(list x26 y26)
; '((1 2 3) (4 5 6))
```

## デバッグ用呼び出し例

```racket
(length (append x26 y26))
; 6
```

```racket
(length (cons x26 y26))
; 4
```

```racket
(length (list x26 y26))
; 2
```

## 数学発展

### 連結と包含の違い

```text
append : 列をつなぐ
cons   : 先頭に1要素を追加する
list   : 引数全体を要素にする
```

## 追記コード：安全に1要素追加

```racket
(define (add-front item xs)
  (cons item xs))
```

デバッグ：

```racket
(add-front 0 '(1 2 3))
; '(0 1 2 3)
```

```racket
(add-front '(0) '(1 2 3))
; '((0) 1 2 3)
```

</details>

---

<details>
<summary><strong>練習問題 2.27：deep-reverse</strong></summary>

## 問題要約

普通の `reverse` は外側だけを逆にする。  
入れ子リストの内側まで逆にする `deep-reverse` を定義する。

## 問題の型

木構造再帰型。

## 骨組み

```racket
(define (deep-reverse x)
  (cond ((null? x) ...)
        ((not (pair? x)) ...)
        (else
         ...)))
```

## 解答

```racket
(define (deep-reverse x)
  (cond ((null? x) '())
        ((not (pair? x)) x)
        (else
         (append (deep-reverse (cdr x))
                 (list (deep-reverse (car x)))))))
```

## デバッグ用呼び出し例

```racket
(deep-reverse '((1 2) (3 4)))
; '((4 3) (2 1))
```

```racket
(deep-reverse '(1 (2 3) 4))
; '(4 (3 2) 1)
```

## 数学発展

### 木の左右反転

木構造のすべての枝を反転する操作。

## 追記コード：普通の reverse との比較

```racket
(define sample-tree '((1 2) (3 4)))
```

デバッグ：

```racket
(reverse sample-tree)
; '((3 4) (1 2))
```

```racket
(deep-reverse sample-tree)
; '((4 3) (2 1))
```

</details>

---

<details>
<summary><strong>練習問題 2.28：fringe</strong></summary>

## 問題要約

木構造から葉だけを左から順に取り出してリストにする。

## 問題の型

- 木構造再帰型
- 葉を集める型

## 骨組み

```racket
(define (fringe tree)
  (cond ((null? tree) '())
        ((not (pair? tree)) (list tree))
        (else
         (append ... ...))))
```

## 解答

```racket
(define (fringe tree)
  (cond ((null? tree) '())
        ((not (pair? tree)) (list tree))
        (else
         (append (fringe (car tree))
                 (fringe (cdr tree))))))
```

## デバッグ用呼び出し例

```racket
(fringe '((1 2) (3 4)))
; '(1 2 3 4)
```

```racket
(fringe '(1 (2 (3 4)) 5))
; '(1 2 3 4 5)
```

## 数学発展

### 深さ優先探索

左から順に葉を集める処理は、木の深さ優先探索に近い。

## 追記コード：葉の合計

```racket
(define (sum-leaves tree)
  (apply + (fringe tree)))
```

デバッグ：

```racket
(sum-leaves '((1 2) (3 4)))
; 10
```

```racket
(sum-leaves '(1 (2 (3 4)) 5))
; 15
```

</details>

---

<details>
<summary><strong>練習問題 2.29：モービル</strong></summary>

## 問題要約

モービルを左右の枝からなる構造として表す。  
枝には長さと重り、または別のモービルがぶら下がる。  
総重量と、つり合い判定を定義する。

## 問題の型

- データ抽象型
- 木構造再帰型
- 物理のモーメント型

## 骨組み

```racket
(define (total-weight mobile)
  (if 葉なら
      重さ
      左右の重さの合計))

(define (balanced? mobile)
  (if 葉なら
      #t
      左右のモーメントが等しく、左右の部分モービルもつり合う))
```

## 解答

```racket
(define (make-mobile left right)
  (list left right))

(define (make-branch length structure)
  (list length structure))

(define (left-branch mobile)
  (car mobile))

(define (right-branch mobile)
  (car (cdr mobile)))

(define (branch-length branch)
  (car branch))

(define (branch-structure branch)
  (car (cdr branch)))

(define (total-weight mobile)
  (if (not (pair? mobile))
      mobile
      (+ (total-weight
          (branch-structure (left-branch mobile)))
         (total-weight
          (branch-structure (right-branch mobile))))))

(define (torque branch)
  (* (branch-length branch)
     (total-weight (branch-structure branch))))

(define (balanced? mobile)
  (if (not (pair? mobile))
      #t
      (and (= (torque (left-branch mobile))
              (torque (right-branch mobile)))
           (balanced?
            (branch-structure (left-branch mobile)))
           (balanced?
            (branch-structure (right-branch mobile)))))))
```

## デバッグ用呼び出し例

```racket
(define m1
  (make-mobile
   (make-branch 2 3)
   (make-branch 3 2)))

(total-weight m1)
; 5
```

```racket
(balanced? m1)
; #t
```

```racket
(define m2
  (make-mobile
   (make-branch 1 10)
   (make-branch 3 2)))

(balanced? m2)
; #f
```

## 数学発展

### モーメントのつり合い

```text
左の長さ * 左の重さ = 右の長さ * 右の重さ
```

物理でいう回転のつり合い。

## 追記コード：左右のモーメント差

```racket
(define (torque-difference mobile)
  (abs (- (torque (left-branch mobile))
          (torque (right-branch mobile)))))
```

デバッグ：

```racket
(torque-difference m1)
; 0
```

```racket
(torque-difference m2)
; 4
```

</details>

---

<details>
<summary><strong>練習問題 2.30：square-tree</strong></summary>

## 問題要約

木構造のすべての葉を二乗する `square-tree` を定義する。  
直接再帰版と `map` 版がある。

## 問題の型

- 木構造再帰型
- map 型

## 骨組み

```racket
(define (square-tree tree)
  (cond ((null? tree) '())
        ((not (pair? tree)) ...)
        (else
         (cons ... ...))))
```

## 解答：直接再帰版

```racket
(define (square x)
  (* x x))

(define (square-tree tree)
  (cond ((null? tree) '())
        ((not (pair? tree)) (square tree))
        (else
         (cons (square-tree (car tree))
               (square-tree (cdr tree))))))
```

## 解答：map版

```racket
(define (square-tree-map tree)
  (map (lambda (sub-tree)
         (if (pair? sub-tree)
             (square-tree-map sub-tree)
             (square sub-tree)))
       tree))
```

## デバッグ用呼び出し例

```racket
(square-tree '(1 (2 3) 4))
; '(1 (4 9) 16)
```

```racket
(square-tree-map '(1 (2 (3 4)) 5))
; '(1 (4 (9 16)) 25)
```

## 数学発展

### 関数を木の各葉へ適用

数列の各項に `f(x)=x^2` を適用するのを、木構造に拡張したもの。

## 追記コード：cube-tree

```racket
(define (cube x)
  (* x x x))

(define (cube-tree tree)
  (cond ((null? tree) '())
        ((not (pair? tree)) (cube tree))
        (else
         (cons (cube-tree (car tree))
               (cube-tree (cdr tree))))))
```

デバッグ：

```racket
(cube-tree '(1 (2 3) 4))
; '(1 (8 27) 64)
```

```racket
(cube-tree '((2 3) (4 5)))
; '((8 27) (64 125))
```

</details>

---

<details>
<summary><strong>練習問題 2.31：tree-map</strong></summary>

## 問題要約

`square-tree` を一般化し、木の葉に任意の手続き `f` を適用する `tree-map` を定義する。

## 問題の型

- 高階手続き型
- 木構造再帰型

## 骨組み

```racket
(define (tree-map f tree)
  (cond ((null? tree) '())
        ((not (pair? tree)) (f tree))
        (else
         (cons ... ...))))
```

## 解答

```racket
(define (tree-map f tree)
  (cond ((null? tree) '())
        ((not (pair? tree)) (f tree))
        (else
         (cons (tree-map f (car tree))
               (tree-map f (cdr tree))))))

(define (square-tree2 tree)
  (tree-map square tree))
```

## デバッグ用呼び出し例

```racket
(tree-map add1 '(1 (2 3) 4))
; '(2 (3 4) 5)
```

```racket
(square-tree2 '(1 (2 3) 4))
; '(1 (4 9) 16)
```

## 数学発展

### 写像

数学でいう写像 `f` を、集合や木の各要素に適用するイメージ。

```text
tree-map f '(1 (2 3))
→ '(f(1) (f(2) f(3)))
```

## 追記コード：abs-tree

```racket
(define (abs-tree tree)
  (tree-map abs tree))
```

デバッグ：

```racket
(abs-tree '(-1 (-2 3) -4))
; '(1 (2 3) 4)
```

```racket
(tree-map (lambda (x) (* 10 x))
          '(1 (2 3) 4))
; '(10 (20 30) 40)
```

</details>

---

<details>
<summary><strong>練習問題 2.32：subsets</strong></summary>

## 問題要約

集合をリストで表し、そのすべての部分集合を返す `subsets` を定義する。

## 問題の型

- 組み合わせ列挙型
- 再帰型

## 数学でいう式

集合 `S` の先頭を `x`、残りを `R` とすると：

```text
Sの部分集合
= Rの部分集合
+ Rの部分集合それぞれにxを追加したもの
```

## 骨組み

```racket
(define (subsets s)
  (if (null? s)
      (list '())
      (let ((rest (subsets (cdr s))))
        (append rest
                (map ... rest)))))
```

## 解答

```racket
(define (subsets s)
  (if (null? s)
      (list '())
      (let ((rest (subsets (cdr s))))
        (append rest
                (map (lambda (x)
                       (cons (car s) x))
                     rest)))))
```

## デバッグ用呼び出し例

```racket
(subsets '(1 2))
; '(() (2) (1) (1 2))
```

```racket
(subsets '(1 2 3))
; '(() (3) (2) (2 3) (1) (1 3) (1 2) (1 2 3))
```

## 数学発展

### 部分集合の個数

要素数が `n` 個の集合の部分集合は：

```text
2^n 個
```

各要素について「選ぶ / 選ばない」の2通りがあるから。

## 追記コード：部分集合の個数

```racket
(define (number-of-subsets s)
  (length (subsets s)))
```

デバッグ：

```racket
(number-of-subsets '(1 2 3))
; 8
```

```racket
(number-of-subsets '(a b c d))
; 16
```

## 発展：k個選ぶ組み合わせ

数学でいう式：

```text
C(n,k) = C(n-1,k) + C(n-1,k-1)
```

これは、

```text
先頭を選ばない場合 + 先頭を選ぶ場合
```

に分ける考え方。

追記コード：

```racket
(define (choose-subsets s k)
  (cond ((= k 0) (list '()))
        ((null? s) '())
        (else
         (append
          (choose-subsets (cdr s) k)
          (map (lambda (x)
                 (cons (car s) x))
               (choose-subsets (cdr s) (- k 1)))))))
```

デバッグ：

```racket
(choose-subsets '(1 2 3) 2)
; '((2 3) (1 3) (1 2))
```

```racket
(choose-subsets '(a b c d) 3)
; '((b c d) (a c d) (a b d) (a b c))
```

組み合わせ数：

```racket
(define (combination-count s k)
  (length (choose-subsets s k)))
```

デバッグ：

```racket
(combination-count '(1 2 3 4) 2)
; 6
```

```racket
(combination-count '(1 2 3 4 5) 3)
; 10
```

</details>

---

<details open>
<summary><strong>明日の演習で特に狙われそうな数学発展まとめ</strong></summary>

## 1. 有理数：通分・約分・大小比較

```text
a/b + c/d = (ad + bc) / bd
a/b < c/d ⇔ ad < cb
```

コード化：

```racket
(define (add-rat x y)
  (make-rat
   (+ (* (numer x) (denom y))
      (* (numer y) (denom x)))
   (* (denom x) (denom y))))

(define (less-rat? x y)
  (< (* (numer x) (denom y))
     (* (numer y) (denom x))))
```

## 2. 座標幾何：距離・中点・傾き

```text
中点 = ((x1+x2)/2, (y1+y2)/2)
距離 = √((x2-x1)^2 + (y2-y1)^2)
傾き = (y2-y1)/(x2-x1)
```

コード化：

```racket
(define (midpoint-segment s)
  (make-point
   (/ (+ (x-point (start-segment s))
         (x-point (end-segment s)))
      2)
   (/ (+ (y-point (start-segment s))
         (y-point (end-segment s)))
      2)))

(define (distance-point p q)
  (sqrt (+ (square (- (x-point q) (x-point p)))
           (square (- (y-point q) (y-point p))))))

(define (slope-segment s)
  (/ (- (y-point (end-segment s))
        (y-point (start-segment s)))
     (- (x-point (end-segment s))
        (x-point (start-segment s)))))
```

## 3. 区間演算：誤差・定義域・一次近似

```text
width([a,b]) = (b-a)/2
center([a,b]) = (a+b)/2
relative error = width / center
```

コード化：

```racket
(define (center i)
  (/ (+ (lower-bound i) (upper-bound i)) 2))

(define (width i)
  (/ (- (upper-bound i) (lower-bound i)) 2))

(define (relative-error i)
  (/ (width i) (center i)))
```

## 4. 区間の割り算：0をまたぐか

```text
0 ∈ [a,b] ⇔ a <= 0 <= b
```

コード化：

```racket
(define (spans-zero? x)
  (and (<= (lower-bound x) 0)
       (<= 0 (upper-bound x))))
```

## 5. モービル：モーメント

```text
左の長さ * 左の重さ = 右の長さ * 右の重さ
```

コード化：

```racket
(define (torque branch)
  (* (branch-length branch)
     (total-weight (branch-structure branch))))
```

## 6. 部分集合：二項係数

```text
|P(S)| = 2^n
C(n,k) = C(n-1,k) + C(n-1,k-1)
```

コード化：

```racket
(define (number-of-subsets s)
  (length (subsets s)))

(define (choose-subsets s k)
  (cond ((= k 0) (list '()))
        ((null? s) '())
        (else
         (append
          (choose-subsets (cdr s) k)
          (map (lambda (x)
                 (cons (car s) x))
               (choose-subsets (cdr s) (- k 1)))))))
```

</details>

---

<details open>
<summary><strong>当日、迷ったときの判断表</strong></summary>

| 出題の形 | 使う骨組み |
|---|---|
| 分子・分母を扱う | `make-rat`, `numer`, `denom` |
| 点・線分・長方形 | コンストラクタ・セレクタ |
| 範囲・誤差 | `make-interval`, `lower-bound`, `upper-bound` |
| 0を含むか | `(and (<= lower 0) (<= 0 upper))` |
| 入れ子リスト | 木構造再帰 |
| 葉だけ集める | `fringe` 型 |
| 木の葉に関数を適用 | `tree-map` 型 |
| 全組み合わせ | `subsets` 型 |
| k個選ぶ | `choose-subsets` 型 |
| つり合い | モーメント `長さ * 重さ` |

特に、演習で追加定義が出るなら、**元の解答を変えずに、セレクタや既存手続きを使って追記する**のが一番安全。

</details>
