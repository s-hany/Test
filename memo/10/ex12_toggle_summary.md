# ex12 演習対策まとめ

このまとめは、`ex12-1.rkt` 〜 `ex12-10.rkt` の演習対策用である。  
今回の範囲は、SICP §2.1「データ抽象入門」、特に **cons / car / cdr、有理数、点と線分、手続きによるデータ表現、区間演算** に対応する。

---

## 最短修正まとめ

`???` が残っている場合に、まず直すべき主なファイルは次の通りである。

- `ex12-2.rkt`
- `ex12-4.rkt`
- `ex12-6.rkt`
- `ex12-8.rkt`
- `ex12-10.rkt`

---

<details>
<summary>ex12-1：make-rat</summary>

## 1. 問題の型

**データ抽象型 / make-rat・numer・denom 型**

有理数を `cons` で表し、分子と分母を `car`, `cdr` で取り出す問題である。  
`make-rat` では、分母が負にならないように符号を正規化する。

## 2. 考え方

有理数 `n/d` は、内部的には

```racket
(cons n d)
```

で表す。  
ただし、`2/-4` のように分母が負の場合は、`-2/4` の形に直す。  
さらに `gcd` を使って約分する。

## 3. 埋める箇所

`make-rat` の手続き全体。

## 4. 解答

```racket
(define (make-rat n d)
  (let ((n2 (if (< d 0) (- n) n))
        (d2 (if (< d 0) (- d) d)))
    (let ((g (gcd n2 d2)))
      (cons (/ n2 g) (/ d2 g)))))
```

## 5. テストコードとの対応

```racket
(make-rat 2 -4)
```

では、分母が負なので、まず

```racket
2 / -4
```

を

```racket
-2 / 4
```

に直す。  
さらに `gcd` で約分して、結果は `-1/2` になる。

## 6. よくあるミス

- 分母が負のまま残る。
- 分子だけ、または分母だけに符号を反映してしまう。
- `gcd` による約分を忘れる。
- `cons` の中に計算前の `n`, `d` をそのまま入れてしまう。

</details>

---

<details>
<summary>ex12-2：線分と点</summary>

## 1. 問題の型

**cons / car / cdr を使うデータ抽象型**

点を `(x . y)` として表し、線分を `(start . end)` として表す問題である。

## 2. 考え方

点は、x座標とy座標をまとめたデータである。

```racket
(make-point x y)
```

は内部的には

```racket
(cons x y)
```

と表せる。  
線分は、始点と終点をまとめたデータなので、これも `cons` で表せる。

中点は、始点と終点の x 座標の平均、y 座標の平均で求める。

```racket
x座標 = (/ (+ 始点のx 終点のx) 2)
y座標 = (/ (+ 始点のy 終点のy) 2)
```

## 3. 埋める箇所

`make-segment`, `start-segment`, `end-segment`, `make-point`, `x-point`, `y-point`, `midpoint-segment` の定義部分。

## 4. 解答

```racket
(define (make-segment start end)
  (cons start end))

(define (start-segment seg)
  (car seg))

(define (end-segment seg)
  (cdr seg))

(define (make-point x y)
  (cons x y))

(define (x-point p)
  (car p))

(define (y-point p)
  (cdr p))

(define (midpoint-segment seg)
  (make-point
   (/ (+ (x-point (start-segment seg))
         (x-point (end-segment seg)))
      2)
   (/ (+ (y-point (start-segment seg))
         (y-point (end-segment seg)))
      2)))
```

## 5. テストコードとの対応

```racket
(make-segment (make-point 20 180)
              (make-point 80 100))
```

の中点は、

```racket
x = (/ (+ 20 80) 2) = 50
y = (/ (+ 180 100) 2) = 140
```

である。  
したがって、`(50, 140)` を表す点が返る。

## 6. よくあるミス

- 始点と終点を逆に取り出してしまう。
- `x-point` と `y-point` の `car`, `cdr` を逆にする。
- 中点で x 座標と y 座標を混ぜて計算してしまう。
- `make-point` を使わずに直接 `cons` で返し、抽象化の壁を壊す。

</details>

---

<details>
<summary>ex12-3：手続きによる cons の cdr</summary>

## 1. 問題の型

**データとは何か / 手続きによるペア表現型**

`cons` を普通のペアではなく、「2つの値を覚えた手続き」として表す問題である。

## 2. 考え方

この問題では、`cons` は次のように考える。

```racket
(define (cons x y)
  (lambda (m)
    (m x y)))
```

つまり、`cons` は `x` と `y` を保持し、あとから渡された手続き `m` に `x` と `y` を渡す。  
`car` は1つ目を選ぶ手続きを渡す。  
`cdr` は2つ目を選ぶ手続きを渡せばよい。

## 3. 埋める箇所

`cdr` の手続き全体。

## 4. 解答

```racket
(define (cdr z)
  (z (lambda (p q) q)))
```

## 5. テストコードとの対応

```racket
(cdr (cons 9 5))
```

では、`cons` が保持している `x = 9`, `y = 5` に対して、

```racket
(lambda (p q) q)
```

を適用する。  
この手続きは2番目の値を返すので、結果は `5` になる。

## 6. よくあるミス

- `cdr` なのに `(lambda (p q) p)` を渡してしまう。
- `z` を普通のペアだと思って `(cdr z)` のように書いてしまう。
- `lambda` を返す問題なのか、`lambda` を引数として渡す問題なのかを混同する。

</details>

---

<details>
<summary>ex12-4：2 と 3 の指数で cons を表す</summary>

## 1. 問題の型

**数値によるデータ表現型 / 素因数分解型**

`(cons a b)` を

```racket
(* (expt 2 a) (expt 3 b))
```

として表す問題である。

## 2. 考え方

整数は素因数分解できる。  
2 と 3 は異なる素数なので、

```racket
2^a * 3^b
```

という数を作れば、2で何回割れるかから `a`、3で何回割れるかから `b` を復元できる。

つまり、

- `car` は 2 で割れる回数を数える。
- `cdr` は 3 で割れる回数を数える。

## 3. 埋める箇所

`car`, `cdr` の手続き全体。  
補助手続きとして `count-factor` を追加してよい。

## 4. 解答

```racket
(define (count-factor n factor)
  (define (iter n count)
    (if (= (remainder n factor) 0)
        (iter (/ n factor) (+ count 1))
        count))
  (iter n 0))

(define (car c)
  (count-factor c 2))

(define (cdr c)
  (count-factor c 3))
```

## 5. テストコードとの対応

```racket
(cons 9 5)
```

は内部的には

```racket
(* (expt 2 9) (expt 3 5))
```

である。  
この数は 2 で 9 回割れるので、`car` は `9` を返す。  
また、3 で 5 回割れるので、`cdr` は `5` を返す。

## 6. よくあるミス

- `remainder` の書き方を間違える。

```racket
(remainder n factor)
```

と書く。

- 反復のたびに `count` を増やし忘れる。
- 2で割る処理と3で割る処理を別々に重複して書いてしまう。
- `car` と `cdr` の factor を逆にする。

</details>

---

<details>
<summary>ex12-5：Church 数</summary>

## 1. 問題の型

**lambda 型 / 手続きによる数の表現型**

数を「手続き `f` を何回適用するか」として表す問題である。

## 2. 考え方

Church 数では、

- `zero` は `f` を0回適用する。
- `one` は `f` を1回適用する。
- `two` は `f` を2回適用する。

と考える。

`+` は、2つの Church 数の適用回数を足し合わせる手続きである。

## 3. 埋める箇所

`one`, `two`, `+` の定義部分。

## 4. 解答

```racket
(define one
  (lambda (f)
    (lambda (x)
      (f x))))

(define two
  (lambda (f)
    (lambda (x)
      (f (f x)))))

(define (+ n m)
  (lambda (f)
    (lambda (x)
      ((n f) ((m f) x)))))
```

## 5. テストコードとの対応

```racket
(((+ one two) s) z)
```

は、`s` を合計3回適用するという意味である。  
`z = 0`、`s` が1増やす手続きなら、結果は `3` になる。

## 6. よくあるミス

- `lambda` の階層を1つ減らしてしまう。
- `((n f) ((m f) x))` の括弧を間違える。
- `+` を数値の足し算と同じように考えてしまう。
- この問題では `+` を再定義するので、ファイル内での `+` の意味に注意する。

</details>

---

<details>
<summary>ex12-6：upper-bound / lower-bound</summary>

## 1. 問題の型

**区間演算 / セレクタ型**

区間を作る構成子 `make-interval` に対して、上限と下限を取り出すセレクタを定義する問題である。

## 2. 考え方

`make-interval` が次のように定義されている場合、

```racket
(define (make-interval a b)
  (cons a b))
```

下限は `car`、上限は `cdr` で取り出せる。

## 3. 埋める箇所

`upper-bound`, `lower-bound` の定義部分。

## 4. 解答

```racket
(define upper-bound cdr)

(define lower-bound car)
```

手続きとして明示的に書くなら、次でも同じである。

```racket
(define (upper-bound i)
  (cdr i))

(define (lower-bound i)
  (car i))
```

## 5. テストコードとの対応

```racket
(make-interval 3 5)
```

は内部的には

```racket
(cons 3 5)
```

である。  
したがって、

```racket
(lower-bound (make-interval 3 5)) ; 3
(upper-bound (make-interval 3 5)) ; 5
```

となる。

## 6. よくあるミス

- `upper-bound` と `lower-bound` を逆にする。
- 区間の内部表現に直接依存したコードを書きすぎる。
- 他の区間演算で `car`, `cdr` を直接使い、抽象化の壁を壊す。

</details>

---

<details>
<summary>ex12-7：sub-interval</summary>

## 1. 問題の型

**区間演算型 / 区間の引き算**

区間同士の引き算を定義する問題である。

## 2. 考え方

区間

```racket
[xl, xu] - [yl, yu]
```

を考える。  
一番小さくなるのは、左の下限から右の上限を引いたときである。

```racket
xl - yu
```

一番大きくなるのは、左の上限から右の下限を引いたときである。

```racket
xu - yl
```

したがって、

```racket
[xl - yu, xu - yl]
```

を返せばよい。

## 3. 埋める箇所

`sub-interval` の手続き全体。

## 4. 解答

```racket
(define (sub-interval x y)
  (make-interval
   (- (lower-bound x) (upper-bound y))
   (- (upper-bound x) (lower-bound y))))
```

すでに `add-interval` を使って書くなら、次でもよい。

```racket
(define (sub-interval x y)
  (add-interval
   x
   (make-interval (- (upper-bound y))
                  (- (lower-bound y)))))
```

## 5. テストコードとの対応

```racket
(sub-interval (make-interval 6.12 7.48)
              (make-interval 2.85 3.15))
```

では、

```racket
lower = 6.12 - 3.15 = 2.97
upper = 7.48 - 2.85 = 4.63
```

となる。  
したがって、結果は `[2.97, 4.63]` である。

## 6. よくあるミス

- `[xl - yl, xu - yu]` としてしまう。
- 下限と上限の組み合わせを間違える。
- 区間を返すときに `make-interval` を使わない。

</details>

---

<details>
<summary>ex12-8：div-interval</summary>

## 1. 問題の型

**区間演算型 / 例外処理つき除算**

区間で割る処理を定義する問題である。  
割る側の区間が 0 を含む場合は、逆数が定義できないためエラーにする。

## 2. 考え方

区間の割り算は、逆数の区間を作って掛け算すればよい。

例えば、

```racket
[2, 4]
```

の逆数は、

```racket
[1/4, 1/2]
```

である。

ただし、

```racket
[-1, 2]
```

のように 0 を含む区間では、`1/0` が発生する可能性がある。  
そのため、この場合は `error` を出す。

## 3. 埋める箇所

`div-interval` の手続き全体。

## 4. 解答

```racket
(define (div-interval x y)
  (if (and (<= (lower-bound y) 0)
           (<= 0 (upper-bound y)))
      (error "division by an interval that spans zero:" y)
      (mul-interval
       x
       (make-interval (/ 1.0 (upper-bound y))
                      (/ 1.0 (lower-bound y))))))
```

## 5. テストコードとの対応

例えば、

```racket
(div-interval (make-interval 2 4)
              (make-interval 2 4))
```

なら、割る側は 0 を含まないので、逆数区間 `[1/4, 1/2]` を作って掛け算できる。

一方で、

```racket
(div-interval (make-interval 2 4)
              (make-interval -1 2))
```

のように、割る側が 0 を含む場合はエラーになる。

## 6. よくあるミス

- 0 を含むかどうかの判定を忘れる。
- 判定を `and` ではなく `or` にしてしまう。
- 逆数区間の下限と上限を逆に考えてしまう。
- `(/ 1 (upper-bound y))` ではなく、誤って `(/ (upper-bound y) 1)` と書く。

</details>

---

<details>
<summary>ex12-9：mul-interval</summary>

## 1. 問題の型

**区間演算型 / 場合分け最適化型**

区間の両端の符号によって場合分けし、必要な掛け算を減らす問題である。

## 2. 考え方

区間の掛け算は、基本的には4通りの積を計算して、その最小値と最大値を取ればよい。

```racket
xl * yl
xl * yu
xu * yl
xu * yu
```

ただし、区間が正だけ、負だけ、0をまたぐ、のどれかによって最小値・最大値が決まる。  
そのため、符号ごとに9通りに場合分けできる。

## 3. 埋める箇所

`mul-interval` の手続き全体。

## 4. 解答

```racket
(define (mul-interval x y)
  (let ((xl (lower-bound x)) (xu (upper-bound x))
        (yl (lower-bound y)) (yu (upper-bound y)))
    (cond
      ((>= xl 0)
       (cond ((>= yl 0)
              (make-interval (* xl yl) (* xu yu)))
             ((and (< yl 0) (>= yu 0))
              (make-interval (* xu yl) (* xu yu)))
             ((< yu 0)
              (make-interval (* xu yl) (* xl yu)))))
      ((and (< xl 0) (>= xu 0))
       (cond ((>= yl 0)
              (make-interval (* xl yu) (* xu yu)))
             ((and (< yl 0) (>= yu 0))
              (make-interval (min (* xl yu)
                                  (* xu yl))
                             (max (* xl yl)
                                  (* xu yu))))
             ((< yu 0)
              (make-interval (* xu yl) (* xl yl)))))
      ((< xu 0)
       (cond ((>= yl 0)
              (make-interval (* xl yu) (* xu yl)))
             ((and (< yl 0) (>= yu 0))
              (make-interval (* xl yu) (* xl yl)))
             ((< yu 0)
              (make-interval (* xu yu) (* xl yl))))))))
```

## 5. テストコードとの対応

テストでは、次のような組み合わせが確認される。

- 正の区間 × 正の区間
- 正の区間 × 0をまたぐ区間
- 正の区間 × 負の区間
- 0をまたぐ区間 × 0をまたぐ区間
- 負の区間 × 負の区間

どの場合でも、通常の4通り全部計算する版と同じ下限・上限になればよい。

## 6. よくあるミス

- 符号の場合分けで `0` を含む場合を落とす。
- 下限と上限を逆にしてしまう。
- `min` と `max` が必要な、両方とも0をまたぐケースを単純化しすぎる。
- `lower-bound` / `upper-bound` を使わず、内部表現に直接依存する。

</details>

---

<details>
<summary>ex12-10：make-center-percent / percent</summary>

## 1. 問題の型

**区間演算型 / 中心値と誤差率による区間表現**

中心値と誤差率から区間を作り、逆に区間から誤差率を求める問題である。

## 2. 考え方

中心 `c`、誤差率 `p%` のとき、幅は

```racket
(* c (/ p 100))
```

で求められる。  
したがって区間は、

```racket
[c - 幅, c + 幅]
```

である。

逆に、区間から誤差率を求めるときは、

```racket
幅 = (/ (- 上限 下限) 2)
中心 = (/ (+ 上限 下限) 2)
誤差率 = (* (/ 幅 中心) 100)
```

で計算する。

## 3. 埋める箇所

`make-center-percent`, `percent` の手続き全体。

## 4. 解答

```racket
(define (make-center-percent c p)
  (let ((w (* c (/ p 100))))
    (make-interval (- c w)
                   (+ c w))))

(define (percent i)
  (* (/ (/ (- (upper-bound i) (lower-bound i)) 2)
        (center i))
     100))
```

中心が負の場合も正のパーセントとして返したいなら、次のように `abs` を使ってもよい。

```racket
(define (percent i)
  (* (abs (/ (/ (- (upper-bound i) (lower-bound i)) 2)
             (center i)))
     100))
```

## 5. テストコードとの対応

```racket
(make-center-percent 6.8 10)
```

では、

```racket
幅 = (* 6.8 (/ 10 100)) = 0.68
```

なので、区間は

```racket
[6.12, 7.48]
```

になる。  
この区間の中心は `6.8`、幅は `0.68` なので、誤差率は `10%` である。

## 6. よくあるミス

- `p` を百分率のまま使い、`(/ p 100)` を忘れる。
- 幅を `(+ upper lower)` で求めてしまう。
- `center` と `width` の意味を混同する。
- 区間を返すときに `make-interval` を使わない。

</details>

---

## 今回の全体まとめ

<details>
<summary>今回の演習で特に重要な型</summary>

## 1. データ抽象型

内部表現が `cons` であっても、使う側は `make-rat`, `numer`, `denom` のような構成子・選択子を通して扱う。

## 2. cons / car / cdr 型

複数の値を1つのデータとしてまとめる。  
点、線分、有理数、区間などはすべてこの考え方で表せる。

## 3. 手続きによるデータ表現型

`cons` を手続きとして表すことで、「データとは何か」を考える問題である。  
値を保存する箱だけでなく、値を返す規則としてもデータを表せる。

## 4. Church 数型

数を「手続きを何回適用するか」として表す。  
`lambda` の階層が多いので、括弧の対応を丁寧に追う必要がある。

## 5. 区間演算型

下限と上限を持つ区間を使い、不確かさを含んだ計算を行う。  
特に、加算・減算・乗算・除算では、下限と上限の決まり方に注意する。

</details>

---

<details>
<summary>毎回確認するミス</summary>

- Racketでは `(x < 4)` ではなく `(< x 4)` と書く。
- `=` は代入ではなく比較である。
- `define` と `set!` を混同しない。
- `if` / `cond` では、条件式と返す値を分けて考える。
- `cons` は2つの値をまとめる。
- `car` は基本的に1つ目を取り出す。
- `cdr` は基本的に2つ目を取り出す。
- ただし、ファイルによって `cons`, `car`, `cdr` を自作している場合がある。
- 抽象化の壁を守り、区間ではできるだけ `lower-bound`, `upper-bound` を使う。
- 区間の引き算では `[xl - yu, xu - yl]` になる。
- 区間の割り算では、割る側が0を含まないか確認する。
- `lambda` は無名手続きを作る構文であり、実行するには引数を渡す必要がある。

</details>

---

## `???` が残っているファイル用コピペまとめ

<details>
<summary>ex12-2 用コード</summary>

```racket
(define (make-segment start end)
  (cons start end))

(define (start-segment seg)
  (car seg))

(define (end-segment seg)
  (cdr seg))

(define (make-point x y)
  (cons x y))

(define (x-point p)
  (car p))

(define (y-point p)
  (cdr p))

(define (midpoint-segment seg)
  (make-point
   (/ (+ (x-point (start-segment seg))
         (x-point (end-segment seg)))
      2)
   (/ (+ (y-point (start-segment seg))
         (y-point (end-segment seg)))
      2)))
```

</details>

<details>
<summary>ex12-4 用コード</summary>

```racket
(define (count-factor n factor)
  (define (iter n count)
    (if (= (remainder n factor) 0)
        (iter (/ n factor) (+ count 1))
        count))
  (iter n 0))

(define (car c)
  (count-factor c 2))

(define (cdr c)
  (count-factor c 3))
```

</details>

<details>
<summary>ex12-6 用コード</summary>

```racket
(define upper-bound cdr)

(define lower-bound car)
```

</details>

<details>
<summary>ex12-8 用コード</summary>

```racket
(define (div-interval x y)
  (if (and (<= (lower-bound y) 0)
           (<= 0 (upper-bound y)))
      (error "division by an interval that spans zero:" y)
      (mul-interval
       x
       (make-interval (/ 1.0 (upper-bound y))
                      (/ 1.0 (lower-bound y))))))
```

</details>

<details>
<summary>ex12-10 用コード</summary>

```racket
(define (make-center-percent c p)
  (let ((w (* c (/ p 100))))
    (make-interval (- c w)
                   (+ c w))))

(define (percent i)
  (* (/ (/ (- (upper-bound i) (lower-bound i)) 2)
        (center i))
     100))
```

</details>
