# プログラミングB 教科書内容まとめ（練習問題ではない本文まとめ）

対象：§2.1 データ抽象入門 / §2.1.1 有理数 / §2.1.2 抽象化の壁 / §2.1.3 データとは何か / §2.1.4 区間演算 / §2.2.1 列の表現 / §2.2.2 階層構造

> このファイルは「練習問題の解答」ではなく、教科書本文で出てくる考え方・型・基本コード・デバッグ用呼び出しをまとめたものです。  
> 演習で発展問題が出たときは、ここにある「型」から考えると解きやすいです。

---

## 目次

- §2.1 データ抽象入門
- §2.1.1 有理数の数値演算
- §2.1.2 抽象化の壁
- §2.1.3 データとは何か
- §2.1.4 区間演算
- §2.2.1 列の表現
- §2.2.2 階層構造
- 当日用：型別テンプレート集
- 当日用：デバッグ呼び出し例まとめ

---

<details>
<summary>§2.1 データ抽象入門：何を学ぶ節か</summary>

## 要点

§2.1 の中心は、**データの中身を直接いじらず、作る手続きと取り出す手続きを通して扱う**という考え方です。

教科書では、これを **データ抽象** として扱っています。

## 重要語

| 用語 | 意味 |
|---|---|
| コンストラクタ | データを作る手続き |
| セレクタ | データから必要な部分を取り出す手続き |
| 抽象データ | 中身ではなく、操作のしかたで扱うデータ |
| 抽象化の壁 | データを使う側と、データの内部表現を分ける境界 |

## 基本の型

```racket
(define (make-data a b)
  (cons a b))

(define (first-data x)
  (car x))

(define (second-data x)
  (cdr x))
```

## 日本語でいうと

- `make-data` は「データを作る」
- `first-data` は「1つ目の情報を取り出す」
- `second-data` は「2つ目の情報を取り出す」

という役割です。

## 演習で問われやすい形

「内部では `cons` を使ってよいが、外側の演算では直接 `car` / `cdr` を使わず、セレクタを使うこと」が問われやすいです。

悪い例：

```racket
(car x)
(cdr x)
```

良い例：

```racket
(numer x)
(denom x)
```

</details>

---

<details>
<summary>§2.1.1 有理数の数値演算：make-rat / numer / denom</summary>

## 問題の型

**有理数をデータ抽象として扱う型**です。

有理数 `n/d` を扱うとき、直接 `cons` を操作するのではなく、

```racket
(make-rat n d)
(numer x)
(denom x)
```

を使います。

## 数学でいうと

有理数は分数です。

```text
n / d
```

2つの有理数を、

```text
x = n1 / d1
y = n2 / d2
```

とすると、演算は次のようになります。

```text
x + y = (n1*d2 + n2*d1) / (d1*d2)
x - y = (n1*d2 - n2*d1) / (d1*d2)
x * y = (n1*n2) / (d1*d2)
x / y = (n1*d2) / (d1*n2)
x = y ⇔ n1*d2 = n2*d1
```

## 基本コード

```racket
#lang racket

(define (make-rat n d)
  (cons n d))

(define (numer x)
  (car x))

(define (denom x)
  (cdr x))
```

## 有理数の演算

```racket
(define (add-rat x y)
  (make-rat
   (+ (* (numer x) (denom y))
      (* (numer y) (denom x)))
   (* (denom x) (denom y))))

(define (sub-rat x y)
  (make-rat
   (- (* (numer x) (denom y))
      (* (numer y) (denom x)))
   (* (denom x) (denom y))))

(define (mul-rat x y)
  (make-rat
   (* (numer x) (numer y))
   (* (denom x) (denom y))))

(define (div-rat x y)
  (make-rat
   (* (numer x) (denom y))
   (* (denom x) (numer y))))

(define (equal-rat? x y)
  (= (* (numer x) (denom y))
     (* (numer y) (denom x))))
```

## 表示用

```racket
(define (print-rat x)
  (display (numer x))
  (display "/")
  (display (denom x))
  (newline))
```

## デバッグ用呼び出し例

```racket
(define one-half (make-rat 1 2))
(define one-third (make-rat 1 3))

(print-rat (add-rat one-half one-third))
; 5/6
```

```racket
(print-rat (mul-rat one-half one-third))
; 1/6
```

```racket
(equal-rat? (make-rat 1 2)
            (make-rat 2 4))
; #t
```

## ここで理解すること

`add-rat` の中で直接 `car` や `cdr` を使わず、

```racket
(numer x)
(denom x)
```

を使うのが重要です。

この書き方にしておくと、あとで有理数の内部表現を変えても、`add-rat` などを直さずに済みます。

</details>

---

<details>
<summary>§2.1.1 補足：make-rat を約分つきにする</summary>

## 要点

最初の `make-rat` は、

```racket
(make-rat 2 4)
```

を `2/4` のまま表します。

しかし数学では、

```text
2/4 = 1/2
```

なので、`gcd` を使って約分できます。

## コード

```racket
(define (make-rat n d)
  (let ((g (gcd n d)))
    (cons (/ n g)
          (/ d g))))
```

## デバッグ用呼び出し例

```racket
(print-rat (make-rat 2 4))
; 1/2
```

```racket
(print-rat (add-rat (make-rat 1 3)
                    (make-rat 1 3)))
; 2/3
```

## 発展で出やすい考え

さらに分母が負の場合を正規化します。

```text
1/-2 = -1/2
-1/-2 = 1/2
```

</details>

---

<details>
<summary>§2.1.2 抽象化の壁：どこを変更してよいか</summary>

## 要点

抽象化の壁とは、**プログラムをいくつかのレベルに分け、上のレベルが下のレベルの中身を直接知らなくてもよいようにする考え方**です。

有理数の例では、次のような階層になります。

```text
有理数を使うプログラム
  ↓
add-rat / sub-rat / mul-rat / div-rat / equal-rat?
  ↓
make-rat / numer / denom
  ↓
cons / car / cdr
```

## 大事なルール

上の層では、下の層の内部表現を直接使わない。

例えば、有理数の演算を書くときは、

```racket
(numer x)
(denom x)
```

を使い、

```racket
(car x)
(cdr x)
```

を直接使わないようにします。

## なぜ重要か

もし内部表現を変えても、

```racket
make-rat
numer
denom
```

だけを直せばよくなります。

## 演習で出やすい聞かれ方

- 「内部表現を変えたとき、どこを直せばよいか」
- 「なぜ `add-rat` の中で `car` を直接使わないのか」
- 「抽象化の壁とは何か」
- 「コンストラクタとセレクタの役割を説明せよ」

## 解答の言い方テンプレート

```text
この問題では、データの内部表現を直接使わず、コンストラクタとセレクタを通して扱う。
そのため、内部表現が変わっても、外側の演算手続きは変更しなくてよい。
これが抽象化の壁の利点である。
```

</details>

---

<details>
<summary>§2.1.3 データとは何か：cons / car / cdr の約束</summary>

## 要点

この節では、データとは「物そのもの」ではなく、**それに対してどんな操作ができるかで決まる**という考え方が出ます。

ペアについては、次の関係が成り立つことが重要です。

```racket
(car (cons x y)) ; x
(cdr (cons x y)) ; y
```

## つまり

`cons` の内部がどう実装されているかよりも、

```text
cons で作ったものに car を使うと1つ目が返る
cons で作ったものに cdr を使うと2つ目が返る
```

という約束が大事です。

## 基本確認

```racket
(car (cons 1 2))
; 1

(cdr (cons 1 2))
; 2
```

## 手続きでペアを表す例

```racket
(define (my-cons x y)
  (lambda (m)
    (m x y)))

(define (my-car z)
  (z (lambda (p q) p)))

(define (my-cdr z)
  (z (lambda (p q) q)))
```

## デバッグ用呼び出し例

```racket
(my-car (my-cons 10 20))
; 10
```

```racket
(my-cdr (my-cons 10 20))
; 20
```

## 日本語トレース

```racket
(my-car (my-cons 10 20))
```

は、まず

```racket
(my-cons 10 20)
```

が

```racket
(lambda (m) (m 10 20))
```

を返します。

そこに

```racket
(lambda (p q) p)
```

を渡すので、

```racket
((lambda (p q) p) 10 20)
```

となり、結果は `10` です。

## 演習で出やすい理解

この節は「データを手続きで表せる」という高階手続きの考えとつながっています。

</details>

---

<details>
<summary>§2.1.4 区間演算：誤差を範囲として扱う</summary>

## 要点

区間演算では、数値を1つの値ではなく、

```text
[下限, 上限]
```

という範囲として扱います。

これは誤差を含む値を扱うときに使えます。

## 例

```text
[2, 5]
```

は、2以上5以下のどれかの値を表します。

## 基本コード

```racket
(define (make-interval a b)
  (cons a b))

(define (lower-bound x)
  (car x))

(define (upper-bound x)
  (cdr x))
```

## 表示用

```racket
(define (print-interval x)
  (display "[")
  (display (lower-bound x))
  (display ", ")
  (display (upper-bound x))
  (display "]")
  (newline))
```

## 足し算

数学では、

```text
[a,b] + [c,d] = [a+c, b+d]
```

コード：

```racket
(define (add-interval x y)
  (make-interval
   (+ (lower-bound x) (lower-bound y))
   (+ (upper-bound x) (upper-bound y))))
```

## 引き算

数学では、

```text
[a,b] - [c,d] = [a-d, b-c]
```

コード：

```racket
(define (sub-interval x y)
  (make-interval
   (- (lower-bound x) (upper-bound y))
   (- (upper-bound x) (lower-bound y))))
```

## 掛け算

端点同士の積の最小値と最大値を取ります。

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

## 割り算

```racket
(define (div-interval x y)
  (mul-interval
   x
   (make-interval
    (/ 1.0 (upper-bound y))
    (/ 1.0 (lower-bound y)))))
```

## デバッグ用呼び出し例

```racket
(print-interval
 (add-interval (make-interval 1 3)
               (make-interval 10 20)))
; [11, 23]
```

```racket
(print-interval
 (sub-interval (make-interval 10 20)
               (make-interval 3 5)))
; [5, 17]
```

```racket
(print-interval
 (mul-interval (make-interval 2 5)
               (make-interval 3 7)))
; [6, 35]
```

</details>

---

<details>
<summary>§2.1.4 区間演算：幅・中心・パーセント誤差</summary>

## 幅

区間 `[a,b]` の幅は、

```text
width = (b - a) / 2
```

コード：

```racket
(define (width x)
  (/ (- (upper-bound x) (lower-bound x)) 2))
```

## 中心

```text
center = (a + b) / 2
```

コード：

```racket
(define (center x)
  (/ (+ (lower-bound x) (upper-bound x)) 2))
```

## 中心と幅から区間を作る

```racket
(define (make-center-width c w)
  (make-interval (- c w) (+ c w)))
```

## パーセント誤差

中心 `c`、誤差率 `p%` なら、

```text
幅 = c * p / 100
区間 = [c - 幅, c + 幅]
```

コード：

```racket
(define (make-center-percent c p)
  (make-center-width c (* c (/ p 100))))

(define (percent x)
  (* 100 (/ (width x) (center x))))
```

## デバッグ用呼び出し例

```racket
(print-interval (make-center-percent 100 5))
; [95, 105]
```

```racket
(center (make-interval 95 105))
; 100
```

```racket
(width (make-interval 95 105))
; 5
```

```racket
(percent (make-interval 95 105))
; 5
```

## 数学発展

相対誤差は、

```text
relative error = width / center
```

コード：

```racket
(define (relative-error x)
  (/ (width x) (center x)))
```

</details>

---

<details>
<summary>§2.1.4 区間演算：0をまたぐ区間で割ってはいけない</summary>

## 要点

割り算は逆数を使います。

```text
x / y = x * (1/y)
```

しかし、`y` が 0 を含む区間なら、`1/0` が起きる可能性があります。

## 数学でいう条件

```text
0 ∈ [a,b] ⇔ a <= 0 <= b
```

## コード

```racket
(define (spans-zero? x)
  (and (<= (lower-bound x) 0)
       (<= 0 (upper-bound x))))

(define (div-interval-safe x y)
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
(spans-zero? (make-interval -1 3))
; #t
```

```racket
(spans-zero? (make-interval 2 5))
; #f
```

```racket
(print-interval
 (div-interval-safe (make-interval 2 4)
                    (make-interval 2 5)))
; [0.4, 2.0]
```

```racket
(div-interval-safe (make-interval 2 4)
                   (make-interval -1 3))
; error
```

</details>

---

<details>
<summary>§2.1.4 区間演算：同じ数式でも結果が違う理由</summary>

## 要点

通常の実数計算では、代数的に同じ式は同じ値になります。

しかし区間演算では、同じ式でも違う結果になることがあります。

## 代表例：並列抵抗

```text
par1 = (R1 * R2) / (R1 + R2)
par2 = 1 / (1/R1 + 1/R2)
```

実数では同じですが、区間演算では結果が違うことがあります。

## コード

```racket
(define (par1 r1 r2)
  (div-interval-safe
   (mul-interval r1 r2)
   (add-interval r1 r2)))

(define (par2 r1 r2)
  (let ((one (make-interval 1 1)))
    (div-interval-safe
     one
     (add-interval
      (div-interval-safe one r1)
      (div-interval-safe one r2)))))
```

## デバッグ用呼び出し例

```racket
(define r1 (make-center-percent 100 1))
(define r2 (make-center-percent 200 1))

(print-interval (par1 r1 r2))
(print-interval (par2 r1 r2))
```

## 理由

区間演算では、同じ変数を複数回使うと、そのたびに独立した値のように扱われます。

例えば実数なら、

```text
x / x = 1
```

ですが、区間で、

```text
x = [2,3]
```

とすると、

```text
[2,3] / [2,3] = [2/3, 3/2]
```

のように広がってしまいます。

## 確認コード

```racket
(print-interval
 (div-interval-safe (make-interval 2 3)
                    (make-interval 2 3)))
; [0.666..., 1.5]
```

</details>

---

<details>
<summary>§2.2.1 列の表現：list / cons / append の違い</summary>

## 要点

Racket のリストは、`cons` の連鎖で表されます。

```racket
(list 1 2 3)
```

は、内部的にはだいたい次のように見られます。

```racket
(cons 1 (cons 2 (cons 3 '())))
```

## 空リスト

```racket
'()
```

は空のリストです。

## 基本操作

| 操作 | 意味 |
|---|---|
| `car` | リストの先頭 |
| `cdr` | リストの残り |
| `cons` | 先頭に1要素を追加 |
| `list` | 引数たちを要素にしたリストを作る |
| `append` | リスト同士をつなぐ |
| `null?` | 空リストか判定 |
| `pair?` | ペアか判定 |

## append / cons / list の違い

```racket
(define x (list 1 2 3))
(define y (list 4 5 6))
```

```racket
(append x y)
; '(1 2 3 4 5 6)
```

```racket
(cons x y)
; '((1 2 3) 4 5 6)
```

```racket
(list x y)
; '((1 2 3) (4 5 6))
```

## デバッグ用呼び出し例

```racket
(length (append x y))
; 6
```

```racket
(length (cons x y))
; 4
```

```racket
(length (list x y))
; 2
```

## 使い分け

- `append`：リスト同士を連結したい
- `cons`：1つの要素を先頭に追加したい
- `list`：複数のものをまとめて新しいリストにしたい

</details>

---

<details>
<summary>§2.2.1 列の表現：list-ref / length / map</summary>

## list-ref

リストの n 番目の要素を取り出します。

```racket
(list-ref '(10 20 30) 0)
; 10
```

```racket
(list-ref '(10 20 30) 2)
; 30
```

## 自作 list-ref

```racket
(define (my-list-ref items n)
  (if (= n 0)
      (car items)
      (my-list-ref (cdr items) (- n 1))))
```

## length

リストの長さを返します。

```racket
(length '(1 2 3 4))
; 4
```

## 自作 length

再帰版：

```racket
(define (my-length items)
  (if (null? items)
      0
      (+ 1 (my-length (cdr items)))))
```

反復版：

```racket
(define (my-length-iter items)
  (define (iter rest count)
    (if (null? rest)
        count
        (iter (cdr rest) (+ count 1))))
  (iter items 0))
```

## map

リストの各要素に同じ手続きを適用します。

```racket
(map square '(1 2 3 4))
; '(1 4 9 16)
```

```racket
(map (lambda (x) (+ x 10))
     '(1 2 3))
; '(11 12 13)
```

## デバッグ用呼び出し例

```racket
(my-list-ref '(a b c d) 2)
; 'c
```

```racket
(my-length '(a b c d))
; 4
```

```racket
(map add1 '(1 2 3))
; '(2 3 4)
```

## 演習で出やすい発展

`map` の中に `lambda` を書かせる問題が出やすいです。

```racket
(map (lambda (x) (* x x))
     '(1 2 3 4))
; '(1 4 9 16)
```

</details>

---

<details>
<summary>§2.2.2 階層構造：木構造としてリストを見る</summary>

## 要点

リストの中にリストが入ると、階層構造になります。

```racket
(list 1 (list 2 (list 3 4)))
```

これは、

```racket
'(1 (2 (3 4)))
```

のように表示されます。

## 数学でいうと

単なる一次元の列ではなく、木構造として見ます。

```text
根
├─ 1
└─ 部分木
   ├─ 2
   └─ 部分木
      ├─ 3
      └─ 4
```

## 木構造再帰の基本形

```racket
(define (tree-proc tree)
  (cond ((null? tree) 空の場合の値)
        ((not (pair? tree)) 葉の場合の値)
        (else
         (car側とcdr側を再帰する式))))
```

## 典型テンプレート

```racket
(define (tree-proc tree)
  (cond ((null? tree) '())
        ((not (pair? tree)) tree)
        (else
         (cons (tree-proc (car tree))
               (tree-proc (cdr tree))))))
```

## 注意

木構造では、`cdr` だけでなく、`car` 側にもリストが入っている可能性があります。

そのため、

```racket
(tree-proc (car tree))
(tree-proc (cdr tree))
```

の両方を見ることが多いです。

</details>

---

<details>
<summary>§2.2.2 count-leaves：葉の数を数える</summary>

## 要点

木構造の葉の数を数える手続きです。

## コード

```racket
(define (count-leaves x)
  (cond ((null? x) 0)
        ((not (pair? x)) 1)
        (else
         (+ (count-leaves (car x))
            (count-leaves (cdr x))))))
```

## 場合分け

| 場合 | 返す値 |
|---|---|
| 空リスト | 0 |
| ペアでない値 | 葉なので 1 |
| ペア | `car` 側と `cdr` 側を足す |

## デバッグ用呼び出し例

```racket
(count-leaves '((1 2) (3 4)))
; 4
```

```racket
(count-leaves '(1 (2 (3 4)) 5))
; 5
```

## 日本語トレース

```racket
(count-leaves '((1 2) (3 4)))
```

は、

```text
左側 (1 2) の葉 = 2
右側 ((3 4)) の葉 = 2
合計 = 4
```

です。

</details>

---

<details>
<summary>§2.2.2 deep-reverse：内側まで逆順にする</summary>

## 要点

普通の `reverse` は外側の順番だけを逆にします。

```racket
(reverse '((1 2) (3 4)))
; '((3 4) (1 2))
```

`deep-reverse` は内側のリストまで逆にします。

```racket
(deep-reverse '((1 2) (3 4)))
; '((4 3) (2 1))
```

## コード

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

## ポイント

葉の場合はそのまま返します。

```racket
((not (pair? x)) x)
```

木の形を保ちながら反転するので、葉を `(list x)` にしません。

</details>

---

<details>
<summary>§2.2.2 fringe：葉を左から順に集める</summary>

## 要点

`fringe` は、木構造から葉だけを取り出して、普通のリストにします。

## コード

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

## ポイント

葉の場合は、

```racket
(list tree)
```

にします。

理由は、最後に `append` でつなげるためです。

## よくあるミス

```racket
((not (pair? tree)) tree)
```

としてしまうと、葉がリストではなく値そのものになるので、`append` がうまくいかない場合があります。

</details>

---

<details>
<summary>§2.2.2 square-tree：木の葉を二乗する</summary>

## 要点

木構造の葉だけを二乗し、木の形は保ちます。

## 直接再帰版

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

## map版

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

## ポイント

木の形を残すので、葉の場合は

```racket
(square tree)
```

を返します。

`fringe` とは違い、

```racket
(list (square tree))
```

にはしません。

</details>

---

<details>
<summary>§2.2.2 tree-map：木の葉に任意の手続きを適用する</summary>

## 要点

`square-tree` を一般化すると、木の葉に任意の関数 `f` を適用できます。

## コード

```racket
(define (tree-map f tree)
  (cond ((null? tree) '())
        ((not (pair? tree)) (f tree))
        (else
         (cons (tree-map f (car tree))
               (tree-map f (cdr tree))))))
```

## square-tree を tree-map で書く

```racket
(define (square-tree2 tree)
  (tree-map square tree))
```

## デバッグ用呼び出し例

```racket
(tree-map add1 '(1 (2 3) 4))
; '(2 (3 4) 5)
```

```racket
(tree-map (lambda (x) (* 10 x))
          '(1 (2 3) 4))
; '(10 (20 30) 40)
```

## 数学でいうと

写像 `f` を木の葉すべてに適用するイメージです。

```text
tree-map f '(1 (2 3))
→ '(f(1) (f(2) f(3)))
```

## 発展しやすいコード

```racket
(define (abs-tree tree)
  (tree-map abs tree))

(define (cube x)
  (* x x x))

(define (cube-tree tree)
  (tree-map cube tree))
```

</details>

---

<details>
<summary>§2.2.2 subsets：部分集合を作る考え方</summary>

## 要点

集合をリストで表し、すべての部分集合を作る手続きです。

## 数学でいうと

集合 `{1,2,3}` の部分集合は、

```text
{}
{1}
{2}
{3}
{1,2}
{1,3}
{2,3}
{1,2,3}
```

です。

要素数が `n` 個なら、部分集合は `2^n` 個あります。

## 再帰的な考え方

集合 `s` の先頭を `x`、残りを `rest` とすると、

```text
s の部分集合
= rest の部分集合
+ rest の部分集合それぞれに x を追加したもの
```

## コード

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

## 部分集合の個数

```racket
(define (number-of-subsets s)
  (length (subsets s)))
```

```racket
(number-of-subsets '(1 2 3))
; 8
```

```racket
(number-of-subsets '(a b c d))
; 16
```

## 発展：k個選ぶ

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

```racket
(choose-subsets '(1 2 3) 2)
; '((2 3) (1 3) (1 2))
```

</details>

---

# 当日用：型別テンプレート集

<details>
<summary>コンストラクタ・セレクタ型</summary>

```racket
(define (make-data a b)
  (cons a b))

(define (first-data x)
  (car x))

(define (second-data x)
  (cdr x))
```

使う場面：

- 有理数
- 点
- 線分
- 長方形
- 区間
- モービル
- 枝

</details>

---

<details>
<summary>有理数演算型</summary>

```racket
(define (op-rat x y)
  (make-rat
   分子の式
   分母の式))
```

足し算：

```racket
(define (add-rat x y)
  (make-rat
   (+ (* (numer x) (denom y))
      (* (numer y) (denom x)))
   (* (denom x) (denom y))))
```

比較：

```racket
(define (less-rat? x y)
  (< (* (numer x) (denom y))
     (* (numer y) (denom x))))
```

</details>

---

<details>
<summary>条件分岐型</summary>

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

</details>

---

<details>
<summary>区間演算型</summary>

```racket
(define (interval-op x y)
  (make-interval
   下限の式
   上限の式))
```

足し算：

```racket
(define (add-interval x y)
  (make-interval
   (+ (lower-bound x) (lower-bound y))
   (+ (upper-bound x) (upper-bound y))))
```

引き算：

```racket
(define (sub-interval x y)
  (make-interval
   (- (lower-bound x) (upper-bound y))
   (- (upper-bound x) (lower-bound y))))
```

</details>

---

<details>
<summary>木構造再帰型</summary>

```racket
(define (tree-proc tree)
  (cond ((null? tree) 空の場合)
        ((not (pair? tree)) 葉の場合)
        (else
         (car側とcdr側を再帰する式))))
```

木の形を保つ：

```racket
(cons (tree-proc (car tree))
      (tree-proc (cdr tree)))
```

葉を集める：

```racket
(append (tree-proc (car tree))
        (tree-proc (cdr tree)))
```

</details>

---

<details>
<summary>map 型</summary>

```racket
(map 手続き リスト)
```

例：

```racket
(map square '(1 2 3))
; '(1 4 9)
```

lambda を使う：

```racket
(map (lambda (x) (* x 10))
     '(1 2 3))
; '(10 20 30)
```

</details>

---

<details>
<summary>部分集合型</summary>

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

考え方：

```text
先頭を選ばない場合 + 先頭を選ぶ場合
```

</details>

---

# 当日用：デバッグ呼び出し例まとめ

```racket
(print-rat (add-rat (make-rat 1 2)
                    (make-rat 1 3)))
; 5/6
```

```racket
(print-interval
 (add-interval (make-interval 1 3)
               (make-interval 10 20)))
; [11, 23]
```

```racket
(print-interval
 (sub-interval (make-interval 10 20)
               (make-interval 3 5)))
; [5, 17]
```

```racket
(spans-zero? (make-interval -1 3))
; #t
```

```racket
(count-leaves '((1 2) (3 4)))
; 4
```

```racket
(fringe '(1 (2 (3 4)) 5))
; '(1 2 3 4 5)
```

```racket
(square-tree '(1 (2 3) 4))
; '(1 (4 9) 16)
```

```racket
(tree-map add1 '(1 (2 3) 4))
; '(2 (3 4) 5)
```

```racket
(subsets '(1 2 3))
; '(() (3) (2) (2 3) (1) (1 3) (1 2) (1 2 3))
```

```racket
(choose-subsets '(1 2 3) 2)
; '((2 3) (1 3) (1 2))
```

---

# よくあるミスまとめ

| ミス | 正しい考え方 |
|---|---|
| `(x < 4)` と書く | `(< x 4)` |
| `car` / `cdr` を直接使いすぎる | セレクタを作って使う |
| `add-rat` の中で `car` を使う | `numer` を使う |
| `fringe` の葉で `tree` を返す | `(list tree)` を返す |
| `square-tree` の葉で `(list (square tree))` にする | `(square tree)` を返す |
| `append` と `cons` を混同する | `append` は連結、`cons` は先頭追加 |
| 木構造で `cdr` だけ再帰する | `car` 側も再帰する |
| `map` に値を渡す | `map` には手続きを渡す |
| `lambda` を実行結果だと思う | `lambda` は手続きを作る式 |
| `=` を代入だと思う | `=` は数値比較 |

---

# 直前確認：この範囲の理解の軸

この範囲で大事なのは、次の3つです。

1. **データを作る手続きと取り出す手続きを分ける**
2. **内部表現を直接使わず、抽象化の壁を守る**
3. **入れ子リストは木構造として再帰で処理する**

演習で発展問題が出た場合も、まずはこのどれに当たるかを分類すると解きやすいです。
