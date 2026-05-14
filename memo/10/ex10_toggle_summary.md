# プログラミングB演習 ex10 解答整理メモ

対象ファイル：`ex10-1.rkt` 〜 `ex10-7.rkt`  
範囲：SICP / 教科書 練習問題 1.40〜1.46 付近  
中心テーマ：高階手続き、手続きを返す手続き、`compose`、`repeated`、`average-damp`、`iterative-improve`

---

## 使い方

このメモでは、各課題をトグル形式で整理している。  
提出ファイルに貼るときは、基本的に

- `========== ここから上を書き換えてはいけません ==========`
- `========== ここから下を書き換えてはいけません ==========`

の間だけを変更する。

特に今回、`???` が残っているのは次の3つである。

- `ex10-2.rkt`
- `ex10-4.rkt`
- `ex10-6.rkt`

---

<details>
<summary>最短修正版：??? が残っている3問だけ</summary>

## ex10-2.rkt

```racket
(define (double f)
  (lambda (x)
    (f (f x))))
```

## ex10-4.rkt

```racket
(define (repeated f n)
  (if (= n 0)
      (lambda (x) x)
      (compose f (repeated f (- n 1)))))
```

## ex10-6.rkt

```racket
(define (nth-root n x)
  (define damp-count
    (floor (/ (log n) (log 2))))
  (fixed-point
   ((repeated average-damp damp-count)
    (lambda (y)
      (/ x (expt y (- n 1)))))
   1.0))
```

</details>

---

<details>
<summary>全体対応表</summary>

| 課題 | 対応する教科書練習問題 | 主な型 | 実装するもの |
|---|---:|---|---|
| ex10-1 | 1.40 | Newton法 / 手続きを返す手続き | `cubic` |
| ex10-2 | 1.41 | 高階手続き | `double` |
| ex10-3 | 1.42 | 手続き合成 | `compose` |
| ex10-4 | 1.43 | repeated / 再帰 | `repeated` |
| ex10-5 | 1.44 | 関数変換 / 平滑化 | `smooth`, `n-fold-smooth` |
| ex10-6 | 1.45 | fixed-point / average-damp | `nth-root` |
| ex10-7 | 1.46 | iterative-improve | `iterative-improve`, `sqrt`, `fixed-point` |

</details>

---

<details>
<summary>ex10-1：cubic</summary>

## 1. 問題の型

**手続きを返す手続き型 / Newton法型**である。

`cubic` は三次式の値を直接返すのではなく、`x` を受け取って三次式を計算する手続きを返す。

式は次の形である。

```text
x^3 + a x^2 + b x + c
```

## 2. 考え方

`(cubic a b c)` が返すべきものは、数値ではなく手続きである。  
そのため、`lambda` を使って次のような手続きを作る。

```racket
(lambda (x)
  ...)
```

この `x` に対して、三次式を Racket の前置記法で書く。

```racket
(+ (* x x x)
   (* a x x)
   (* b x)
   c)
```

## 3. 埋める箇所

`define` 全体を書く場所である。  
`========== ここから上を書き換えてはいけません ==========` の下にある `cubic` の定義を確認する。

## 4. 解答

```racket
(define (cubic a b c)
  (lambda (x)
    (+ (* x x x)
       (* a x x)
       (* b x)
       c)))
```

## 5. テストコードとの対応

```racket
(newtons-method (cubic -9 26 -24) 1)
```

これは、次の三次式の根を Newton法で求める。

```text
x^3 - 9x^2 + 26x - 24
```

この式は、

```text
(x - 2)(x - 3)(x - 4)
```

なので、初期値 `1` から始めると根 `2` に近づく。

## 6. 確認用呼び出し

```racket
((cubic -9 26 -24) 2)
((cubic -9 26 -24) 3)
((cubic -9 26 -24) 4)
```

いずれも `0` になる。

## 7. よくあるミス

`cubic` の返り値は数値ではなく、手続きである。  
そのため、次のように `x` がない式を書いてはいけない。

```racket
(+ (* a a a) (* a a) b c)
```

</details>

---

<details>
<summary>ex10-2：double</summary>

## 1. 問題の型

**高階手続き型 / 手続きを返す手続き型**である。

`double` は、手続き `f` を受け取り、`f` を2回適用する新しい手続きを返す。

## 2. 考え方

`(double f)` は、次のような手続きを返す。

```text
x ↦ f(f(x))
```

Racket では次のように書く。

```racket
(lambda (x)
  (f (f x)))
```

## 3. 埋める箇所

`???` の部分である。

もとの形は次のようになっている。

```racket
(define (double f)
  (???))
```

## 4. 解答

```racket
(define (double f)
  (lambda (x)
    (f (f x))))
```

## 5. テストコードとの対応

```racket
((double inc) 100)
```

これは次のように評価できる。

```racket
(inc (inc 100))
```

したがって結果は `102` である。

もう一つのテストは次である。

```racket
(((double (double double)) inc) 5)
```

これは `inc` を16回適用する形になる。  
したがって、`5 + 16 = 21` となる。

## 6. 確認用呼び出し

```racket
((double inc) 10)
((double square) 2)
(((double (double double)) inc) 5)
```

期待される結果は順に、`12`, `16`, `21` である。

## 7. よくあるミス

次のように書くのは違う。

```racket
(define (double f)
  (f f))
```

`f` は手続きであり、`f` 自身を引数として渡す問題ではない。  
`f` を適用する対象 `x` を受け取るために、`lambda` が必要である。

</details>

---

<details>
<summary>ex10-3：compose</summary>

## 1. 問題の型

**手続き合成型**である。

`compose` は、2つの手続き `f`, `g` を受け取り、次の合成手続きを返す。

```text
x ↦ f(g(x))
```

## 2. 考え方

`g` を先に適用し、その結果に `f` を適用する。

Racket では、内側から評価されるので次の形になる。

```racket
(f (g x))
```

## 3. 埋める箇所

`compose` の手続き全体を書く場所である。  
このファイルでは、すでに解答が入っている。

## 4. 解答

```racket
(define (compose f g)
  (lambda (x)
    (f (g x))))
```

## 5. テストコードとの対応

```racket
((compose square inc) 6)
```

これは次の意味である。

```racket
(square (inc 6))
```

つまり、

```racket
(square 7)
```

なので結果は `49` である。

```racket
((compose inc square) 6)
```

こちらは、

```racket
(inc (square 6))
```

なので、`37` である。

## 6. 確認用呼び出し

```racket
((compose square inc) 6)
((compose inc square) 6)
```

## 7. よくあるミス

`(f g x)` のようには書かない。  
Racket では、これは「`f` に `g` と `x` の2つの引数を渡す」という意味になる。  
合成は必ず次の形で書く。

```racket
(f (g x))
```

</details>

---

<details>
<summary>ex10-4：repeated</summary>

## 1. 問題の型

**compose / repeated 型**である。

`repeated` は、手続き `f` と回数 `n` を受け取り、`f` を `n` 回適用する手続きを返す。

## 2. 考え方

たとえば、

```racket
((repeated square 2) 5)
```

は、

```racket
(square (square 5))
```

という意味になる。

再帰的には次のように考える。

```text
f を 0 回適用する手続き = 何もしない手続き
f を n 回適用する手続き = f と「f を n-1 回適用する手続き」の合成
```

「何もしない手続き」は次のように書ける。

```racket
(lambda (x) x)
```

## 3. 埋める箇所

`???` の部分である。

もとの形は次のようになっている。

```racket
(define (repeated f n)
  (???))
```

## 4. 解答

```racket
(define (repeated f n)
  (if (= n 0)
      (lambda (x) x)
      (compose f (repeated f (- n 1)))))
```

## 5. テストコードとの対応

```racket
((repeated square 2) 5)
```

これは、

```racket
(square (square 5))
```

なので、

```racket
(square 25)
```

となり、結果は `625` である。

また、

```racket
((repeated inc 8) 5)
```

は `inc` を8回適用するので、結果は `13` である。

## 6. 確認用呼び出し

```racket
((repeated square 2) 5)
((repeated inc 8) 5)
((repeated inc 0) 5)
```

期待される結果は順に、`625`, `13`, `5` である。

## 7. よくあるミス

終了条件を書かないと無限再帰になる。  
そのため、`n = 0` の場合を必ず用意する。

また、`compose` は `ex10-3.rkt` から読み込まれているので、自分で再定義しない。

</details>

---

<details>
<summary>ex10-5：smooth / n-fold-smooth</summary>

## 1. 問題の型

**関数変換型 / repeated 応用型**である。

`smooth` は、手続き `f` を受け取り、平滑化された新しい手続きを返す。

## 2. 考え方

平滑化では、`x` の近くの3点を使う。

```text
f(x - dx), f(x), f(x + dx)
```

この3つの平均を返す。

Racket では次のように考える。

```racket
(/ (+ (f (- x dx))
      (f x)
      (f (+ x dx)))
   3)
```

`n-fold-smooth` は、`smooth` を `n` 回繰り返す。  
これは `repeated` を使うと短く書ける。

## 3. 埋める箇所

`smooth` と `n-fold-smooth` の手続き全体を書く場所である。  
このファイルでは、すでに解答が入っている。

## 4. 解答

```racket
(define (smooth f)
  (lambda (x)
    (/ (+ (f (- x dx))
          (f x)
          (f (+ x dx)))
       3)))

(define (n-fold-smooth f n)
  ((repeated smooth n) f))
```

## 5. テストコードとの対応

`step` は、`n >= 0` なら `100.0`、そうでなければ `0.0` を返す。

```racket
((smooth step) 0)
```

を考えると、`dx = 0.00001` なので、

```racket
(step (- 0 dx)) ; 0.0
(step 0)        ; 100.0
(step (+ 0 dx)) ; 100.0
```

となる。  
したがって、

```racket
(/ (+ 0.0 100.0 100.0) 3)
```

なので、約 `66.6666` になる。

## 6. 確認用呼び出し

```racket
((smooth step) 0)
((n-fold-smooth step 5) 0)
((n-fold-smooth step 10) 0)
```

## 7. よくあるミス

`n-fold-smooth` では、次のように書く必要がある。

```racket
((repeated smooth n) f)
```

`(repeated smooth n)` は、まだ「手続き」を返しただけである。  
その手続きに `f` を渡すことで、`f` に対して `smooth` を `n` 回適用できる。

</details>

---

<details>
<summary>ex10-6：nth-root</summary>

## 1. 問題の型

**fixed-point / average-damp / repeated 型**である。

`x` の `n` 乗根を求める問題である。

## 2. 考え方

`x` の `n` 乗根を `y` とすると、

```text
y^n = x
```

である。  
これを fixed-point の形に変形する。

```text
y = x / y^(n - 1)
```

したがって、fixed-point に渡す関数は次の形になる。

```racket
(lambda (y)
  (/ x (expt y (- n 1))))
```

ただし、このままだと収束しにくい場合がある。  
そこで `average-damp` を何回かかける。

平均緩和の回数は、今回のテストでは次の式でよい。

```racket
(floor (/ (log n) (log 2)))
```

これは、おおよそ `log2(n)` 回という意味である。

## 3. 埋める箇所

`???` の部分である。

もとの形は次のようになっている。

```racket
(define (nth-root n x)
  (???))
```

## 4. 解答

```racket
(define (nth-root n x)
  (define damp-count
    (floor (/ (log n) (log 2))))
  (fixed-point
   ((repeated average-damp damp-count)
    (lambda (y)
      (/ x (expt y (- n 1)))))
   1.0))
```

## 5. テストコードとの対応

```racket
(expt (nth-root 4 5) 4)
```

これは、`5` の4乗根を求めてから、それを4乗している。  
正しく近似できていれば、結果は `5` に近くなる。

同様に、テストでは `2`, `4`, `8`, `16`, `32` 乗根を確認している。

## 6. 確認用呼び出し

```racket
(expt (nth-root 2 5) 2)
(expt (nth-root 4 5) 4)
(expt (nth-root 8 5) 8)
(expt (nth-root 16 5) 16)
(expt (nth-root 32 5) 32)
```

どれも `5` に近い値になればよい。

## 7. よくあるミス

`fixed-point` に渡すのは、`f(y) = 0` の形ではない。  
必ず次のような形にする。

```text
y = g(y)
```

今回の `g` は次である。

```racket
(lambda (y)
  (/ x (expt y (- n 1))))
```

また、`average-damp` は値にかけるのではなく、手続きにかける。

</details>

---

<details>
<summary>ex10-7：iterative-improve / sqrt / fixed-point</summary>

## 1. 問題の型

**iterative-improve 型 / 抽象化型**である。

「十分よくなるまで改善を繰り返す」という共通パターンを、`iterative-improve` として抽象化する問題である。

## 2. 考え方

共通の形は次の通りである。

```text
今の推定値 guess が十分よいなら、それを返す。
そうでなければ、guess を improve して繰り返す。
```

これを高階手続きとして書く。

`good-enough?` は「十分よいかを判定する手続き」である。  
`improve` は「推定値を改善する手続き」である。

## 3. 埋める箇所

`iterative-improve`, `sqrt`, `fixed-point` の手続き全体を書く場所である。  
このファイルでは、すでに解答が入っている。

## 4. 解答

```racket
(define (iterative-improve good-enough? improve)
  (lambda (guess)
    (define (iter g)
      (if (good-enough? g)
          g
          (iter (improve g))))
    (iter guess)))

(define (sqrt x)
  (define (average a b) (/ (+ a b) 2))
  (define (improve guess)
    (average guess (/ x guess)))
  (define (good-enough? guess)
    (< (abs (- (square guess) x)) 0.001))
  ((iterative-improve good-enough? improve) 1.0))

(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2))
       tolerance))
  (define (good-enough? guess)
    (close-enough? guess (f guess)))
  ((iterative-improve good-enough? f) first-guess))
```

## 5. テストコードとの対応

```racket
(square (sqrt 5))
```

これは、`sqrt` で求めた値を2乗したときに `5` に近いかを確認している。

また、

```racket
(fixed-point cos 1.0)
```

は、

```text
x = cos(x)
```

を満たす値に近づくかを確認している。

## 6. 確認用呼び出し

```racket
(square (sqrt 5))
(square (sqrt 23))
(fixed-point cos 1.0)
(fixed-point (lambda (y) (+ (sin y) (cos y))) 1.0)
```

## 7. よくあるミス

`iterative-improve` は、改善をすぐに始めるのではなく、「初期値を受け取る手続き」を返す。  
そのため、次のように二段階で使う。

```racket
((iterative-improve good-enough? improve) 1.0)
```

また、`fixed-point` では `improve` に相当するものが `f` である。  
つまり、現在の推定値 `guess` から次の値 `(f guess)` を作る。

</details>

---

<details>
<summary>今回の範囲で毎回確認するミス</summary>

## 1. 手続きと値を混同しない

今回の課題では、手続きそのものを渡すことが多い。

```racket
(double inc)
(repeated smooth n)
(average-damp f)
```

これらはすべて、手続きを材料にして新しい手続きを作っている。

## 2. `lambda` は無名手続きを作る構文

次の式は、`x` を受け取る手続きを作る。

```racket
(lambda (x)
  (f (f x)))
```

ただし、`lambda` を書いただけでは実行されない。  
実行するには、引数を渡す必要がある。

```racket
((lambda (x) (+ x 1)) 10)
```

## 3. Racket は前置記法

比較は次のように書く。

```racket
(< x 4)
(= n 0)
(>= n 0)
```

次のようには書かない。

```racket
(x < 4)
(n = 0)
```

## 4. `=` は代入ではなく比較

Racket で値を定義するときは `define` を使う。

```racket
(define x 10)
```

比較するときは `=` を使う。

```racket
(= x 10)
```

## 5. `fixed-point` は `f(x) = 0` ではなく `x = g(x)`

`fixed-point` に渡すのは、次の形の `g` である。

```text
x = g(x)
```

今回の `nth-root` では、

```text
y = x / y^(n - 1)
```

に変形してから使う。

## 6. `repeated` の返り値は手続き

```racket
(repeated square 2)
```

は、まだ手続きである。  
実際に値へ適用するには、さらに引数を渡す。

```racket
((repeated square 2) 5)
```

## 7. 変更禁止部分を変えない

`require`, `provide`, `test`, `check-equal?`, `check-within` は基本的に変更しない。  
今回変更するのは、指定された定義部分だけである。

</details>

---

<details>
<summary>英語の変数名・手続き名の意味メモ</summary>

| 名前 | 意味 | この課題での役割 |
|---|---|---|
| `double` | 2倍にする、2回にする | 手続き `f` を2回適用する |
| `compose` | 合成する | `f(g(x))` を作る |
| `repeated` | 繰り返された | 手続きの n 回適用を作る |
| `smooth` | なめらかにする | 関数の値を近傍平均との差にする |
| `average-damp` | 平均緩和 | `x` と `f(x)` の平均を取って収束しやすくする |
| `fixed-point` | 不動点 | `x = f(x)` となる値を探す |
| `iterative-improve` | 反復的改善 | よくなるまで改善を繰り返す抽象パターン |
| `guess` | 推定値 | 現在の近似値 |
| `improve` | 改善する | 推定値を次の推定値へ変える |
| `good-enough?` | 十分よいか？ | 停止条件を判定する |
| `tolerance` | 許容誤差 | どれくらい近ければよいか |
| `dx` | 微小変化量 | 微分や平滑化で使う小さな値 |

</details>

---

## 最終チェック

- `ex10-2`, `ex10-4`, `ex10-6` の `???` を埋めたか。
- `lambda` で「手続きを返す」形になっているか。
- `compose` の順番を逆にしていないか。
- `repeated` の停止条件 `n = 0` を書いたか。
- `n-fold-smooth` で `((repeated smooth n) f)` と二段階適用しているか。
- `fixed-point` に `y = g(y)` の形を渡しているか。
- 変更禁止部分を編集していないか。
