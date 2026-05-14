# プログラミングで使われやすい数学まとめ Racket版

プログラミングB / SICP 系の演習で使いやすいように、数学で有名な考え方を **数学での定義** と **Racketで書ける形** に対応させて整理したメモである。

この `.md` は Notion や Markdown ビューアで見やすいように、各項目を `<details>` トグル形式で格納している。

---

## 使い方

1. Racketで試す場合は、まず下の「共通補助手続き」をファイルの先頭に貼る。
2. 各トグルのコードを必要に応じて追加する。
3. `確認用の呼び出し` を実行して、値の変化を見る。
4. プログラミングB演習では、「これは再帰型か」「反復型か」「高階手続き型か」「データ抽象型か」を意識する。

---

## 共通補助手続き

<details open>
<summary><strong>共通補助手続き</strong>：多くの項目で使う基本関数</summary>

### 数学での意味

よく使う基本操作を名前付き手続きとして用意する。SICPでは、このように小さな手続きを組み合わせて大きな計算を作る。

### Racketコード

```racket
#lang racket

(define tolerance 0.00001)
(define dx 0.00001)

(define (square x) (* x x))
(define (cube x) (* x x x))
(define (average x y) (/ (+ x y) 2))
(define (close-enough? x y)
  (< (abs (- x y)) tolerance))

(define (inc x) (+ x 1))
(define (identity x) x)

(define (enumerate-interval low high)
  (if (> low high)
      '()
      (cons low (enumerate-interval (+ low 1) high))))
```

</details>

---

# 1. 再帰・反復・数列

<details>
<summary><strong>1. 階乗</strong>：再帰・反復の最基本</summary>

### 数学での定義

`n!` は `1` から `n` までの整数の積である。

- `0! = 1`
- `n! = n × (n - 1)!`

### 問題の型

線形再帰プロセス、または線形反復プロセス。

### Racketコード：再帰版

```racket
(define (factorial n)
  (if (= n 0)
      1
      (* n (factorial (- n 1)))))
```

### Racketコード：反復版

```racket
(define (factorial-iter n)
  (define (iter counter product)
    (if (> counter n)
        product
        (iter (+ counter 1) (* counter product))))
  (iter 1 1))
```

### 確認用の呼び出し

```racket
(factorial 5)
(factorial-iter 5)
```

### よくあるミス

`n! = n * (n - 1)` としてしまうと、再帰にならない。正しくは `n! = n × (n - 1)!` である。

</details>

<details>
<summary><strong>2. フィボナッチ数列</strong>：木構造再帰と反復の比較に使いやすい</summary>

### 数学での定義

- `F(0) = 0`
- `F(1) = 1`
- `F(n) = F(n - 1) + F(n - 2)`

### 問題の型

木構造再帰、反復プロセス、計算量比較。

### Racketコード：木構造再帰版

```racket
(define (fib n)
  (cond ((= n 0) 0)
        ((= n 1) 1)
        (else (+ (fib (- n 1))
                 (fib (- n 2))))))
```

### Racketコード：反復版

```racket
(define (fib-iter n)
  (define (iter a b count)
    (if (= count 0)
        a
        (iter b (+ a b) (- count 1))))
  (iter 0 1 n))
```

### 確認用の呼び出し

```racket
(fib 10)
(fib-iter 10)
```

### プログラミングでの用途

再帰の重複計算、メモ化、動的計画法の説明に使われる。

</details>

<details>
<summary><strong>3. トリボナッチ数列</strong>：フィボナッチの発展</summary>

### 数学での定義

- `T(0) = 0`
- `T(1) = 0`
- `T(2) = 1`
- `T(n) = T(n - 1) + T(n - 2) + T(n - 3)`

### 問題の型

再帰プロセス、反復プロセス。

### Racketコード

```racket
(define (trib n)
  (cond ((= n 0) 0)
        ((= n 1) 0)
        ((= n 2) 1)
        (else (+ (trib (- n 1))
                 (trib (- n 2))
                 (trib (- n 3))))))
```

### 反復版

```racket
(define (trib-iter n)
  (define (iter a b c count)
    (if (= count 0)
        a
        (iter b c (+ a b c) (- count 1))))
  (iter 0 0 1 n))
```

### 確認用の呼び出し

```racket
(trib 6)
(trib-iter 6)
```

</details>

<details>
<summary><strong>4. 等差数列</strong>：一定の差で増える数列</summary>

### 数学での定義

初項を `a`、公差を `d` とすると、

`a_n = a + (n - 1)d`

### 問題の型

式をそのまま手続きに直す問題。

### Racketコード

```racket
(define (arithmetic-term a d n)
  (+ a (* (- n 1) d)))
```

### 確認用の呼び出し

```racket
(arithmetic-term 3 2 5)
```

</details>

<details>
<summary><strong>5. 等比数列</strong>：一定の倍率で増える数列</summary>

### 数学での定義

初項を `a`、公比を `r` とすると、

`a_n = a r^(n - 1)`

### 問題の型

累乗を使う数学的定義の実装。

### Racketコード

```racket
(define (geometric-term a r n)
  (* a (expt r (- n 1))))
```

### 確認用の呼び出し

```racket
(geometric-term 3 2 5)
```

</details>

<details>
<summary><strong>6. 三角数</strong>：1からnまでの和</summary>

### 数学での定義

`T_n = 1 + 2 + ... + n = n(n + 1) / 2`

### 問題の型

総和、閉じた公式、再帰の比較。

### Racketコード：公式版

```racket
(define (triangle-number n)
  (/ (* n (+ n 1)) 2))
```

### Racketコード：再帰版

```racket
(define (triangle-number-rec n)
  (if (= n 0)
      0
      (+ n (triangle-number-rec (- n 1)))))
```

### 確認用の呼び出し

```racket
(triangle-number 10)
(triangle-number-rec 10)
```

</details>

<details>
<summary><strong>7. コラッツ数列</strong>：条件分岐と再帰の練習</summary>

### 数学での定義

正の整数 `n` について、

- `n` が偶数なら `n / 2`
- `n` が奇数なら `3n + 1`

を繰り返す。

### 問題の型

`cond` による条件分岐、再帰プロセス。

### Racketコード

```racket
(define (collatz n)
  (cond ((= n 1) '(1))
        ((even? n)
         (cons n (collatz (/ n 2))))
        (else
         (cons n (collatz (+ (* 3 n) 1))))))
```

### 確認用の呼び出し

```racket
(collatz 7)
```

### よくあるミス

Racketでは `(n even?)` ではなく `(even? n)` と書く。

</details>

---

# 2. 数論・整数計算

<details>
<summary><strong>8. ユークリッドの互除法</strong>：最大公約数を求める古典的アルゴリズム</summary>

### 数学での定義

`gcd(a, b) = gcd(b, a mod b)`

ただし、`b = 0` のとき `gcd(a, 0) = a`。

### 問題の型

再帰プロセス、余り `remainder` の利用。

### Racketコード

```racket
(define (my-gcd a b)
  (if (= b 0)
      (abs a)
      (my-gcd b (remainder a b))))
```

### 確認用の呼び出し

```racket
(my-gcd 206 40)
```

### プログラミングでの用途

分数の約分、暗号、合同式、数論アルゴリズムに使う。

</details>

<details>
<summary><strong>9. 最小公倍数</strong>：最大公約数から求める</summary>

### 数学での定義

`lcm(a, b) = |ab| / gcd(a, b)`

### 問題の型

既存手続きの組み合わせ。

### Racketコード

```racket
(define (my-lcm a b)
  (/ (abs (* a b)) (my-gcd a b)))
```

### 確認用の呼び出し

```racket
(my-lcm 12 18)
```

</details>

<details>
<summary><strong>10. 素数判定</strong>：割り切れる数があるか調べる</summary>

### 数学での定義

`n` が `1` と `n` 以外に正の約数を持たないとき、`n` は素数である。

### 問題の型

条件分岐、再帰、探索。

### Racketコード

```racket
(define (divides? a b)
  (= (remainder b a) 0))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor n (+ test-divisor 1)))))

(define (smallest-divisor n)
  (find-divisor n 2))

(define (prime? n)
  (and (> n 1)
       (= n (smallest-divisor n))))
```

### 確認用の呼び出し

```racket
(prime? 17)
(prime? 21)
```

</details>

<details>
<summary><strong>11. エラトステネスの篩</strong>：素数をまとめて列挙する</summary>

### 数学での定義

`2` から始めて、見つけた素数の倍数を消していくことで、指定範囲内の素数を列挙する。

### 問題の型

リスト処理、`filter`、再帰。

### Racketコード

```racket
(define (sieve xs)
  (if (null? xs)
      '()
      (cons (car xs)
            (sieve
             (filter (lambda (x)
                       (not (= (remainder x (car xs)) 0)))
                     (cdr xs))))))

(define (primes-up-to n)
  (sieve (enumerate-interval 2 n)))
```

### 確認用の呼び出し

```racket
(primes-up-to 30)
```

</details>

<details>
<summary><strong>12. 累乗</strong>：再帰でべき乗を計算する</summary>

### 数学での定義

- `b^0 = 1`
- `b^n = b × b^(n - 1)`

### 問題の型

線形再帰。

### Racketコード

```racket
(define (power b n)
  (if (= n 0)
      1
      (* b (power b (- n 1)))))
```

### 確認用の呼び出し

```racket
(power 2 10)
```

</details>

<details>
<summary><strong>13. 高速累乗</strong>：繰り返し二乗法</summary>

### 数学での定義

`n` が偶数なら、

`b^n = (b^(n/2))^2`

`n` が奇数なら、

`b^n = b × b^(n-1)`

### 問題の型

計算量を減らす再帰。

### Racketコード

```racket
(define (fast-expt b n)
  (cond ((= n 0) 1)
        ((even? n) (square (fast-expt b (/ n 2))))
        (else (* b (fast-expt b (- n 1))))))
```

### 確認用の呼び出し

```racket
(fast-expt 2 10)
```

</details>

<details>
<summary><strong>14. 高速掛け算</strong>：倍加と半減による計算</summary>

### 数学での定義

`a × b` を、

- `b` が偶数なら `(2a) × (b/2)`
- `b` が奇数なら `a + a × (b - 1)`

として計算する。

### 問題の型

高速累乗の考え方を掛け算へ応用する問題。

### Racketコード

```racket
(define (double x) (+ x x))
(define (halve x) (/ x 2))

(define (fast-mul a b)
  (cond ((= b 0) 0)
        ((even? b) (fast-mul (double a) (halve b)))
        (else (+ a (fast-mul a (- b 1))))))
```

### 確認用の呼び出し

```racket
(fast-mul 13 12)
```

</details>

<details>
<summary><strong>15. 二項係数</strong>：組合せの数</summary>

### 数学での定義

`n` 個から `k` 個を選ぶ数は、

`C(n, k) = n! / (k!(n-k)!)`

またはパスカルの関係で、

`C(n, k) = C(n-1, k-1) + C(n-1, k)`

### 問題の型

再帰、組合せ、パスカル三角形。

### Racketコード：再帰版

```racket
(define (choose n k)
  (cond ((or (< k 0) (> k n)) 0)
        ((or (= k 0) (= k n)) 1)
        (else (+ (choose (- n 1) (- k 1))
                 (choose (- n 1) k)))))
```

### 確認用の呼び出し

```racket
(choose 5 2)
(choose 6 3)
```

</details>

<details>
<summary><strong>16. パスカルの三角形</strong>：二項係数を並べたもの</summary>

### 数学での定義

第 `n` 段の第 `k` 番目は `C(n, k)` である。

### 問題の型

二項係数、再帰、リスト生成。

### Racketコード

```racket
(define (pascal-row n)
  (map (lambda (k) (choose n k))
       (enumerate-interval 0 n)))
```

### 確認用の呼び出し

```racket
(pascal-row 5)
```

</details>

<details>
<summary><strong>17. カタラン数</strong>：木構造・括弧列で出てくる数</summary>

### 数学での定義

`n` 番目のカタラン数は、

`C_n = (1 / (n + 1)) C(2n, n)`

### 問題の型

組合せ、木構造、二項係数の応用。

### Racketコード

```racket
(define (catalan n)
  (/ (choose (* 2 n) n)
     (+ n 1)))
```

### 確認用の呼び出し

```racket
(map catalan '(0 1 2 3 4 5))
```

### プログラミングでの用途

二分木の数、正しい括弧列の数、構文木の数え上げに出る。

</details>

<details>
<summary><strong>18. モジュラ累乗</strong>：暗号・合同式で使う</summary>

### 数学での定義

`b^n mod m` を大きな数にせず計算する。

### 問題の型

高速累乗、剰余計算、数論。

### Racketコード

```racket
(define (expmod base exp m)
  (cond ((= exp 0) 1)
        ((even? exp)
         (remainder (square (expmod base (/ exp 2) m)) m))
        (else
         (remainder (* base (expmod base (- exp 1) m)) m))))
```

### 確認用の呼び出し

```racket
(expmod 2 10 7)
```

</details>

<details>
<summary><strong>19. 完全数</strong>：約数の和が自分自身になる数</summary>

### 数学での定義

自分自身を除く正の約数の和が `n` と等しいとき、`n` は完全数である。

例：`6 = 1 + 2 + 3`

### 問題の型

約数判定、総和、条件分岐。

### Racketコード

```racket
(define (proper-divisors n)
  (filter (lambda (d) (= (remainder n d) 0))
          (enumerate-interval 1 (- n 1))))

(define (perfect? n)
  (= n (apply + (proper-divisors n))))
```

### 確認用の呼び出し

```racket
(perfect? 6)
(perfect? 28)
(perfect? 12)
```

</details>

---

# 3. 総和・総乗・高階手続き

<details>
<summary><strong>20. 総和記号 Σ</strong>：term と next を渡す型</summary>

### 数学での定義

`Σ_{i=a}^{b} f(i)` は、`i` を `a` から `b` まで変化させながら `f(i)` を足す。

### 問題の型

高階手続き、手続きを引数として渡す問題。

### Racketコード

```racket
(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
         (sum term (next a) next b))))
```

### 確認用の呼び出し

```racket
(sum identity 1 inc 10)
(sum square 1 inc 5)
```

### よくあるミス

`sum` に渡すのは値ではなく手続きである。例えば `(sum square 1 inc 5)` と書く。

</details>

<details>
<summary><strong>21. 総乗記号 Π</strong>：product 型</summary>

### 数学での定義

`Π_{i=a}^{b} f(i)` は、`f(a) × f(a+1) × ... × f(b)` を表す。

### 問題の型

`sum` の足し算を掛け算に変える問題。

### Racketコード

```racket
(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
         (product term (next a) next b))))
```

### 確認用の呼び出し

```racket
(product identity 1 inc 5)
(product square 1 inc 3)
```

</details>

<details>
<summary><strong>22. accumulate</strong>：sum と product を一般化する</summary>

### 数学での定義

足し算や掛け算のような「結合の仕方」を引数にして、範囲内の値をまとめる。

### 問題の型

高階手続き、抽象化。

### Racketコード

```racket
(define (accumulate combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (term a)
                (accumulate combiner null-value term (next a) next b))))
```

### sum と product の再定義

```racket
(define (sum2 term a next b)
  (accumulate + 0 term a next b))

(define (product2 term a next b)
  (accumulate * 1 term a next b))
```

### 確認用の呼び出し

```racket
(sum2 square 1 inc 5)
(product2 identity 1 inc 5)
```

</details>

<details>
<summary><strong>23. filtered-accumulate</strong>：条件を満たすものだけ集積する</summary>

### 数学での定義

条件 `P(i)` を満たす項だけを集める。

例：`1` から `n` までの素数だけを足す。

### 問題の型

高階手続き、条件付き集積。

### Racketコード

```racket
(define (filtered-accumulate predicate combiner null-value term a next b)
  (cond ((> a b) null-value)
        ((predicate a)
         (combiner (term a)
                   (filtered-accumulate predicate combiner null-value term (next a) next b)))
        (else
         (filtered-accumulate predicate combiner null-value term (next a) next b))))
```

### 確認用の呼び出し

```racket
(filtered-accumulate prime? + 0 identity 1 inc 20)
```

</details>

<details>
<summary><strong>24. 数値積分</strong>：関数の面積を近似する</summary>

### 数学での定義

`∫_a^b f(x) dx` を小さい幅 `dx` の長方形の和で近似する。

### 問題の型

高階手続き、sum 型、数値計算。

### Racketコード

```racket
(define (integral f a b dx)
  (* (sum f (+ a (/ dx 2.0))
          (lambda (x) (+ x dx))
          b)
     dx))
```

### 確認用の呼び出し

```racket
(integral cube 0 1 0.01)
```

</details>

<details>
<summary><strong>25. シンプソンの公式</strong>：数値積分の精度を上げる</summary>

### 数学での定義

区間 `[a, b]` を偶数個 `n` に分け、重み `1, 4, 2, 4, ..., 2, 4, 1` をつけて足す。

### 問題の型

数値積分、sum 型、条件分岐。

### Racketコード

```racket
(define (simpson f a b n)
  (define h (/ (- b a) n))
  (define (y k) (f (+ a (* k h))))
  (define (coef k)
    (cond ((or (= k 0) (= k n)) 1)
          ((even? k) 2)
          (else 4)))
  (* (/ h 3)
     (sum (lambda (k) (* (coef k) (y k)))
          0 inc n)))
```

### 確認用の呼び出し

```racket
(simpson cube 0 1 100)
```

</details>

<details>
<summary><strong>26. lambda</strong>：その場で無名手続きを作る</summary>

### 数学での定義

関数 `f(x) = x^2 + 1` のような対応を、名前をつけずに直接書く。

### 問題の型

lambda 型、高階手続き。

### Racketコード

```racket
((lambda (x) (+ (square x) 1)) 5)
```

### sum と組み合わせる例

```racket
(sum (lambda (x) (+ (square x) 1))
     1 inc 5)
```

### よくあるミス

`lambda` は手続きを作るだけである。実行するには、後ろに引数を渡す必要がある。

</details>

<details>
<summary><strong>27. compose</strong>：関数の合成</summary>

### 数学での定義

`(f ∘ g)(x) = f(g(x))`

### 問題の型

返り値として手続きを返す高階手続き。

### Racketコード

```racket
(define (compose f g)
  (lambda (x) (f (g x))))
```

### 確認用の呼び出し

```racket
((compose square inc) 6)
```

</details>

<details>
<summary><strong>28. repeated</strong>：同じ関数をn回適用する</summary>

### 数学での定義

`f` を `n` 回合成したものを作る。

例：`f(f(f(x)))`

### 問題の型

compose、返り値として手続きを返す問題。

### Racketコード

```racket
(define (repeated f n)
  (if (= n 0)
      identity
      (compose f (repeated f (- n 1)))))
```

### 確認用の呼び出し

```racket
((repeated square 2) 5)
((repeated inc 10) 0)
```

</details>

<details>
<summary><strong>29. average-damp</strong>：平均緩和法</summary>

### 数学での定義

関数 `f` に対して、

`x -> (x + f(x)) / 2`

という関数を作る。

### 問題の型

fixed-point、average-damp、返り値として手続きを返す問題。

### Racketコード

```racket
(define (average-damp f)
  (lambda (x) (average x (f x))))
```

### 確認用の呼び出し

```racket
((average-damp square) 10)
```

</details>

<details>
<summary><strong>30. smooth</strong>：関数を平滑化する</summary>

### 数学での定義

`f(x - dx)`, `f(x)`, `f(x + dx)` の平均を取る。

### 問題の型

高階手続き、返り値として手続きを返す問題。

### Racketコード

```racket
(define (smooth f)
  (lambda (x)
    (/ (+ (f (- x dx))
          (f x)
          (f (+ x dx)))
       3)))
```

### 確認用の呼び出し

```racket
((smooth square) 5)
```

</details>

---

# 4. 不動点・ニュートン法・近似計算

<details>
<summary><strong>31. 不動点 fixed-point</strong>：x = g(x) の形を解く</summary>

### 数学での定義

`x = g(x)` を満たす `x` を、関数 `g` の不動点という。

### 問題の型

fixed-point 型、反復改良法。

### Racketコード

```racket
(define (fixed-point f first-guess)
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
          next
          (try next))))
  (try first-guess))
```

### 確認用の呼び出し

```racket
(fixed-point cos 1.0)
```

### よくあるミス

`fixed-point` に渡すのは `f(x) = 0` ではなく、`x = g(x)` の形に直した `g` である。

</details>

<details>
<summary><strong>32. 平方根</strong>：平均緩和つき fixed-point</summary>

### 数学での定義

`y = sqrt(x)` なら、

`y^2 = x`

したがって、

`y = x / y`

となる。ただしこのままだと振動しやすいので平均緩和する。

### 問題の型

fixed-point、average-damp、数値計算。

### Racketコード

```racket
(define (sqrt-fixed x)
  (fixed-point (average-damp (lambda (y) (/ x y)))
               1.0))
```

### 確認用の呼び出し

```racket
(sqrt-fixed 2)
(sqrt-fixed 9)
```

</details>

<details>
<summary><strong>33. n乗根</strong>：xのn乗根を不動点で求める</summary>

### 数学での定義

`y = x^(1/n)` なら、

`y^n = x`

つまり、

`y = x / y^(n-1)`

### 問題の型

fixed-point、average-damp、repeated の応用。

### Racketコード

```racket
(define (nth-root x n)
  (fixed-point
   ((repeated average-damp 2)
    (lambda (y) (/ x (expt y (- n 1)))))
   1.0))
```

### 確認用の呼び出し

```racket
(nth-root 27 3)
(nth-root 16 4)
```

### 注意

平均緩和の回数は、問題によって調整が必要である。ここでは学習用に2回としている。

</details>

<details>
<summary><strong>34. ニュートン法</strong>：接線で方程式を近似的に解く</summary>

### 数学での定義

`g(x) = 0` を解きたいとき、

`x_{n+1} = x_n - g(x_n) / g'(x_n)`

で近似する。

### 問題の型

Newton法、導関数、fixed-point。

### Racketコード

```racket
(define (deriv g)
  (lambda (x)
    (/ (- (g (+ x dx)) (g x)) dx)))

(define (newton-transform g)
  (lambda (x)
    (- x (/ (g x) ((deriv g) x)))))

(define (newtons-method g guess)
  (fixed-point (newton-transform g) guess))
```

### 確認用の呼び出し

```racket
(newtons-method (lambda (y) (- (square y) 2)) 1.0)
```

</details>

<details>
<summary><strong>35. 区間二分法</strong>：符号が変わる区間を半分にする</summary>

### 数学での定義

連続関数 `f` について、`f(a)` と `f(b)` の符号が異なれば、`a` と `b` の間に零点がある。

### 問題の型

区間二分法、条件分岐、再帰。

### Racketコード

```racket
(define (search f neg-point pos-point)
  (let ((midpoint (average neg-point pos-point)))
    (if (close-enough? neg-point pos-point)
        midpoint
        (let ((test-value (f midpoint)))
          (cond ((positive? test-value)
                 (search f neg-point midpoint))
                ((negative? test-value)
                 (search f midpoint pos-point))
                (else midpoint))))))

(define (half-interval-method f a b)
  (let ((a-value (f a))
        (b-value (f b)))
    (cond ((and (negative? a-value) (positive? b-value))
           (search f a b))
          ((and (negative? b-value) (positive? a-value))
           (search f b a))
          (else (error "values are not of opposite sign" a b)))))
```

### 確認用の呼び出し

```racket
(half-interval-method sin 2.0 4.0)
```

</details>

<details>
<summary><strong>36. iterative-improve</strong>：反復改良法を一般化する</summary>

### 数学での定義

初期推測値から始め、

1. 十分よいか判定する
2. よくなければ改善する
3. 改善後の値で繰り返す

という形を一般化する。

### 問題の型

反復改良法、返り値として手続きを返す問題。

### Racketコード

```racket
(define (iterative-improve good-enough? improve)
  (lambda (guess)
    (define (iter guess)
      (let ((next (improve guess)))
        (if (good-enough? guess next)
            next
            (iter next))))
    (iter guess)))
```

### sqrt を書く例

```racket
(define (sqrt-improve x)
  ((iterative-improve close-enough?
                      (lambda (y) (average y (/ x y))))
   1.0))
```

### 確認用の呼び出し

```racket
(sqrt-improve 2)
```

</details>

<details>
<summary><strong>37. 勾配降下法</strong>：値を小さくする方向に進む</summary>

### 数学での定義

関数 `f(x)` を小さくしたいとき、導関数 `f'(x)` を使って、

`x_{n+1} = x_n - α f'(x_n)`

と更新する。

### 問題の型

数値最適化、反復計算。

### Racketコード

```racket
(define (gradient-descent f guess alpha steps)
  (define df (deriv f))
  (define (iter x count)
    (if (= count 0)
        x
        (iter (- x (* alpha (df x)))
              (- count 1))))
  (iter guess steps))
```

### 確認用の呼び出し

```racket
(gradient-descent (lambda (x) (square (- x 3)))
                  0.0
                  0.1
                  100)
```

</details>

---

# 5. 展開・級数

<details>
<summary><strong>38. マクローリン展開：e^x</strong></summary>

### 数学での定義

`e^x = 1 + x + x^2/2! + x^3/3! + ...`

つまり、

`e^x = Σ_{k=0}^{∞} x^k / k!`

### 問題の型

sum 型、階乗、近似計算。

### Racketコード

```racket
(define (exp-approx x n)
  (sum (lambda (k) (/ (expt x k) (factorial k)))
       0 inc n))
```

### 確認用の呼び出し

```racket
(exp-approx 1.0 10)
(exp 1)
```

</details>

<details>
<summary><strong>39. マクローリン展開：sin x</strong></summary>

### 数学での定義

`sin x = x - x^3/3! + x^5/5! - x^7/7! + ...`

### 問題の型

sum 型、交代級数、近似計算。

### Racketコード

```racket
(define (sin-approx x n)
  (sum (lambda (k)
         (let ((sign (if (even? k) 1 -1))
               (power (+ (* 2 k) 1)))
           (* sign (/ (expt x power)
                      (factorial power)))))
       0 inc n))
```

### 確認用の呼び出し

```racket
(sin-approx 1.0 8)
(sin 1.0)
```

</details>

<details>
<summary><strong>40. マクローリン展開：cos x</strong></summary>

### 数学での定義

`cos x = 1 - x^2/2! + x^4/4! - x^6/6! + ...`

### 問題の型

sum 型、交代級数、近似計算。

### Racketコード

```racket
(define (cos-approx x n)
  (sum (lambda (k)
         (let ((sign (if (even? k) 1 -1))
               (power (* 2 k)))
           (* sign (/ (expt x power)
                      (factorial power)))))
       0 inc n))
```

### 確認用の呼び出し

```racket
(cos-approx 1.0 8)
(cos 1.0)
```

</details>

<details>
<summary><strong>41. log(1+x) の展開</strong>：交代級数</summary>

### 数学での定義

`log(1+x) = x - x^2/2 + x^3/3 - x^4/4 + ...`

ただし、主に `-1 < x <= 1` の範囲で考える。

### 問題の型

sum 型、級数近似。

### Racketコード

```racket
(define (log1p-approx x n)
  (sum (lambda (k)
         (let ((sign (if (odd? k) 1 -1)))
           (* sign (/ (expt x k) k))))
       1 inc n))
```

### 確認用の呼び出し

```racket
(log1p-approx 0.5 20)
(log 1.5)
```

</details>

<details>
<summary><strong>42. 幾何級数</strong>：等比数列の和</summary>

### 数学での定義

`1 + r + r^2 + ... + r^n`

`|r| < 1` のとき、無限和は `1 / (1 - r)` に近づく。

### 問題の型

sum 型、等比数列。

### Racketコード

```racket
(define (geometric-sum r n)
  (sum (lambda (k) (expt r k))
       0 inc n))
```

### 確認用の呼び出し

```racket
(geometric-sum 0.5 10)
(/ 1 (- 1 0.5))
```

</details>

<details>
<summary><strong>43. 調和級数</strong>：1/n の和</summary>

### 数学での定義

`H_n = 1 + 1/2 + 1/3 + ... + 1/n`

### 問題の型

sum 型、分数計算。

### Racketコード

```racket
(define (harmonic n)
  (sum (lambda (k) (/ 1.0 k))
       1 inc n))
```

### 確認用の呼び出し

```racket
(harmonic 10)
```

</details>

<details>
<summary><strong>44. 連分数</strong>：分数が入れ子になる表現</summary>

### 数学での定義

`n_1 / (d_1 + n_2 / (d_2 + n_3 / ...))`

### 問題の型

高階手続き、反復、近似。

### Racketコード

```racket
(define (cont-frac n d k)
  (define (iter i result)
    (if (= i 0)
        result
        (iter (- i 1)
              (/ (n i) (+ (d i) result)))))
  (iter k 0))
```

### 確認用の呼び出し

```racket
(cont-frac (lambda (i) 1.0)
           (lambda (i) 1.0)
           10)
```

</details>

<details>
<summary><strong>45. 黄金比</strong>：不動点として求める</summary>

### 数学での定義

黄金比 `φ` は、

`φ = 1 + 1/φ`

を満たす。

### 問題の型

fixed-point、連分数、数列。

### Racketコード

```racket
(define golden-ratio
  (fixed-point (lambda (x) (+ 1 (/ 1 x)))
               1.0))
```

### 確認用の呼び出し

```racket
golden-ratio
```

</details>

---

# 6. 確率・統計・乱数シミュレーション

<details>
<summary><strong>46. ベルヌーイ試行</strong>：成功か失敗か</summary>

### 数学での定義

成功確率 `p` の試行で、成功なら `1`、失敗なら `0` を返す。

### 問題の型

乱数、条件分岐。

### Racketコード

```racket
(define (bernoulli p)
  (if (< (random) p) 1 0))
```

### 確認用の呼び出し

```racket
(bernoulli 0.3)
```

</details>

<details>
<summary><strong>47. 二項分布</strong>：成功回数の確率</summary>

### 数学での定義

`n` 回中 `k` 回成功する確率は、

`C(n,k) p^k (1-p)^(n-k)`

### 問題の型

二項係数、確率、関数の組み合わせ。

### Racketコード

```racket
(define (binomial-pmf n k p)
  (* (choose n k)
     (expt p k)
     (expt (- 1 p) (- n k))))
```

### 確認用の呼び出し

```racket
(binomial-pmf 10 3 0.5)
```

</details>

<details>
<summary><strong>48. 期待値</strong>：平均的な値</summary>

### 数学での定義

確率変数 `X` の期待値は、

`E[X] = Σ x P(X=x)`

### 問題の型

リスト処理、確率、accumulate 的な考え方。

### Racketコード

```racket
(define (expected dist)
  (foldl (lambda (p acc)
           (+ acc (* (car p) (cdr p))))
         0
         dist))
```

### 確認用の呼び出し

```racket
(expected (list (cons 1 1/6)
                (cons 2 1/6)
                (cons 3 1/6)
                (cons 4 1/6)
                (cons 5 1/6)
                (cons 6 1/6)))
```

</details>

<details>
<summary><strong>49. 分散</strong>：期待値からのずれの平均</summary>

### 数学での定義

`Var(X) = E[(X - μ)^2]`

ただし `μ = E[X]`。

### 問題の型

期待値、二乗、リスト処理。

### Racketコード

```racket
(define (variance dist)
  (let ((mu (expected dist)))
    (foldl (lambda (p acc)
             (+ acc (* (square (- (car p) mu))
                       (cdr p))))
           0
           dist)))
```

### 確認用の呼び出し

```racket
(variance (list (cons 1 1/6)
                (cons 2 1/6)
                (cons 3 1/6)
                (cons 4 1/6)
                (cons 5 1/6)
                (cons 6 1/6)))
```

</details>

<details>
<summary><strong>50. モンテカルロ法</strong>：乱数で近似する</summary>

### 数学での定義

確率的な実験を何度も行い、成功割合から値を近似する。

### 問題の型

乱数、反復、確率シミュレーション。

### Racketコード

```racket
(define (monte-carlo trials experiment)
  (define (iter trials-remaining trials-passed)
    (cond ((= trials-remaining 0)
           (/ trials-passed trials))
          ((experiment)
           (iter (- trials-remaining 1) (+ trials-passed 1)))
          (else
           (iter (- trials-remaining 1) trials-passed))))
  (iter trials 0))
```

### 確認用の呼び出し

```racket
(monte-carlo 1000 (lambda () (= (random 2) 0)))
```

</details>

<details>
<summary><strong>51. 円周率πのモンテカルロ近似</strong></summary>

### 数学での定義

正方形 `[-1,1] × [-1,1]` の中に点をランダムに打つ。単位円の中に入る確率は `π/4` である。

### 問題の型

モンテカルロ法、幾何、乱数。

### Racketコード

```racket
(define (random-between low high)
  (+ low (* (random) (- high low))))

(define (inside-unit-circle?)
  (let ((x (random-between -1.0 1.0))
        (y (random-between -1.0 1.0)))
    (<= (+ (square x) (square y)) 1.0)))

(define (estimate-pi trials)
  (* 4 (monte-carlo trials inside-unit-circle?)))
```

### 確認用の呼び出し

```racket
(estimate-pi 10000)
```

</details>

<details>
<summary><strong>52. ランダムウォーク</strong>：ランダムに左右へ動く</summary>

### 数学での定義

現在位置 `x` から、確率的に `x + 1` または `x - 1` に移動する。

### 問題の型

乱数、再帰、状態の更新。

### Racketコード

```racket
(define (random-step x)
  (if (= (random 2) 0)
      (- x 1)
      (+ x 1)))

(define (random-walk x steps)
  (if (= steps 0)
      x
      (random-walk (random-step x) (- steps 1))))
```

### 確認用の呼び出し

```racket
(random-walk 0 100)
```

</details>

---

# 7. データ抽象・リスト・木構造

<details>
<summary><strong>53. 有理数</strong>：分子と分母をデータとしてまとめる</summary>

### 数学での定義

有理数は `n/d` の形で表される。ただし `d ≠ 0`。

### 問題の型

データ抽象、`cons` / `car` / `cdr`、抽象化の壁。

### Racketコード

```racket
(define (make-rat n d)
  (let* ((g (my-gcd n d))
         (nn (/ n g))
         (dd (/ d g)))
    (if (< dd 0)
        (cons (- nn) (- dd))
        (cons nn dd))))

(define (numer x) (car x))
(define (denom x) (cdr x))

(define (add-rat x y)
  (make-rat (+ (* (numer x) (denom y))
               (* (numer y) (denom x)))
            (* (denom x) (denom y))))
```

### 確認用の呼び出し

```racket
(add-rat (make-rat 1 2) (make-rat 1 3))
```

### よくあるミス

`cons` で作った表現に直接依存しすぎない。外からは `numer` と `denom` を使う。

</details>

<details>
<summary><strong>54. 区間演算</strong>：誤差を含む値を扱う</summary>

### 数学での定義

値を一点ではなく `[下限, 上限]` の区間として扱う。

### 問題の型

データ抽象、数値計算、誤差。

### Racketコード

```racket
(define (make-interval a b) (cons a b))
(define (lower-bound x) (car x))
(define (upper-bound x) (cdr x))

(define (add-interval x y)
  (make-interval (+ (lower-bound x) (lower-bound y))
                 (+ (upper-bound x) (upper-bound y))))

(define (mul-interval x y)
  (let ((p1 (* (lower-bound x) (lower-bound y)))
        (p2 (* (lower-bound x) (upper-bound y)))
        (p3 (* (upper-bound x) (lower-bound y)))
        (p4 (* (upper-bound x) (upper-bound y))))
    (make-interval (min p1 p2 p3 p4)
                   (max p1 p2 p3 p4))))
```

### 確認用の呼び出し

```racket
(add-interval (make-interval 1 2)
              (make-interval 3 5))
```

</details>

<details>
<summary><strong>55. map</strong>：リストの全要素に同じ処理をする</summary>

### 数学での定義

リスト `(x1 x2 ... xn)` に関数 `f` を適用して、`(f(x1) f(x2) ... f(xn))` を作る。

### 問題の型

高階手続き、リスト処理。

### Racketコード

```racket
(define (my-map f xs)
  (if (null? xs)
      '()
      (cons (f (car xs))
            (my-map f (cdr xs)))))
```

### 確認用の呼び出し

```racket
(my-map square '(1 2 3 4 5))
```

</details>

<details>
<summary><strong>56. filter</strong>：条件を満たす要素だけ残す</summary>

### 数学での定義

集合や列から、条件 `P(x)` を満たす要素だけを取り出す。

### 問題の型

述語、高階手続き、リスト処理。

### Racketコード

```racket
(define (my-filter predicate xs)
  (cond ((null? xs) '())
        ((predicate (car xs))
         (cons (car xs)
               (my-filter predicate (cdr xs))))
        (else
         (my-filter predicate (cdr xs)))))
```

### 確認用の呼び出し

```racket
(my-filter prime? '(1 2 3 4 5 6 7 8 9 10))
```

</details>

<details>
<summary><strong>57. 木の再帰</strong>：入れ子リストを処理する</summary>

### 数学での定義

木は、部分木を再帰的に含む構造として考えられる。

### 問題の型

木構造再帰、`pair?`、`null?`。

### Racketコード：葉の合計

```racket
(define (tree-sum tree)
  (cond ((null? tree) 0)
        ((pair? tree)
         (+ (tree-sum (car tree))
            (tree-sum (cdr tree))))
        (else tree)))
```

### 確認用の呼び出し

```racket
(tree-sum '(1 (2 3) (4 (5))))
```

</details>

<details>
<summary><strong>58. square-tree</strong>：木の葉だけを二乗する</summary>

### 数学での定義

木の形は保ったまま、各葉 `x` を `x^2` に変える。

### 問題の型

木構造再帰、map 型。

### Racketコード

```racket
(define (square-tree tree)
  (cond ((null? tree) '())
        ((pair? tree)
         (cons (square-tree (car tree))
               (square-tree (cdr tree))))
        (else (square tree))))
```

### 確認用の呼び出し

```racket
(square-tree '(1 (2 3) (4 (5))))
```

</details>

---

# 8. 探索・アルゴリズム

<details>
<summary><strong>59. 二分探索</strong>：整列済みデータから高速に探す</summary>

### 数学での定義

探索範囲を毎回半分にして、目的の値を探す。

### 問題の型

反復、条件分岐、計算量 `O(log n)`。

### Racketコード

```racket
(define (binary-search vec target)
  (define (iter low high)
    (if (> low high)
        #f
        (let* ((mid (quotient (+ low high) 2))
               (value (vector-ref vec mid)))
          (cond ((= value target) mid)
                ((< value target) (iter (+ mid 1) high))
                (else (iter low (- mid 1)))))))
  (iter 0 (- (vector-length vec) 1)))
```

### 確認用の呼び出し

```racket
(binary-search #(1 3 5 7 9 11) 7)
```

</details>

<details>
<summary><strong>60. 深さ優先探索 DFS</strong>：先に奥へ進む探索</summary>

### 数学での定義

グラフの頂点から始め、未訪問の隣接頂点へ再帰的に進む。

### 問題の型

グラフ、再帰、リスト処理。

### Racketコード

```racket
(define sample-graph
  '((a b c)
    (b d)
    (c e)
    (d)
    (e)))

(define (neighbors node graph)
  (let ((entry (assoc node graph)))
    (if entry (cdr entry) '())))

(define (dfs graph start)
  (define (visit node visited)
    (if (member node visited)
        visited
        (foldl (lambda (next acc)
                 (visit next acc))
               (cons node visited)
               (neighbors node graph))))
  (reverse (visit start '())))
```

### 確認用の呼び出し

```racket
(dfs sample-graph 'a)
```

</details>

<details>
<summary><strong>61. 幅優先探索 BFS</strong>：近い順に探索する</summary>

### 数学での定義

始点から距離が近い頂点を先に調べる。

### 問題の型

グラフ、キュー、リスト処理。

### Racketコード

```racket
(define (bfs graph start)
  (define (iter queue visited)
    (cond ((null? queue) (reverse visited))
          ((member (car queue) visited)
           (iter (cdr queue) visited))
          (else
           (iter (append (cdr queue)
                         (neighbors (car queue) graph))
                 (cons (car queue) visited)))))
  (iter (list start) '()))
```

### 確認用の呼び出し

```racket
(bfs sample-graph 'a)
```

</details>

<details>
<summary><strong>62. ハミング距離</strong>：2つの列の違いを数える</summary>

### 数学での定義

同じ長さの列について、対応する位置で値が異なる個数を数える。

### 問題の型

再帰、リスト処理、情報理論。

### Racketコード

```racket
(define (hamming xs ys)
  (cond ((or (null? xs) (null? ys)) 0)
        ((equal? (car xs) (car ys))
         (hamming (cdr xs) (cdr ys)))
        (else
         (+ 1 (hamming (cdr xs) (cdr ys))))))
```

### 確認用の呼び出し

```racket
(hamming '(1 0 1 1) '(1 1 1 0))
```

</details>

---

# 9. 幾何・ゲーム・CGで使いやすい数学

<details>
<summary><strong>63. 2点間距離</strong>：座標から距離を求める</summary>

### 数学での定義

2点 `(x1, y1)`, `(x2, y2)` の距離は、

`sqrt((x2 - x1)^2 + (y2 - y1)^2)`

### 問題の型

ピタゴラスの定理、データ抽象。

### Racketコード

```racket
(define (make-point x y) (cons x y))
(define (point-x p) (car p))
(define (point-y p) (cdr p))

(define (distance p q)
  (sqrt (+ (square (- (point-x q) (point-x p)))
           (square (- (point-y q) (point-y p))))))
```

### 確認用の呼び出し

```racket
(distance (make-point 0 0) (make-point 3 4))
```

</details>

<details>
<summary><strong>64. 内積</strong>：向きの近さを調べる</summary>

### 数学での定義

`a・b = a1b1 + a2b2 + ... + anbn`

### 問題の型

リスト処理、ベクトル計算。

### Racketコード

```racket
(define (dot xs ys)
  (if (or (null? xs) (null? ys))
      0
      (+ (* (car xs) (car ys))
         (dot (cdr xs) (cdr ys)))))
```

### 確認用の呼び出し

```racket
(dot '(1 2 3) '(4 5 6))
```

### プログラミングでの用途

視野判定、向き判定、照明計算、AIの角度判定に使う。

</details>

<details>
<summary><strong>65. 線形補間 lerp</strong>：2つの値の間をなめらかに移動する</summary>

### 数学での定義

`t` を `0` から `1` の値として、

`(1 - t)a + tb`

### 問題の型

一次関数、補間。

### Racketコード

```racket
(define (lerp a b t)
  (+ (* (- 1 t) a)
     (* t b)))
```

### 確認用の呼び出し

```racket
(lerp 10 20 0.25)
```

</details>

<details>
<summary><strong>66. 二次ベジェ曲線</strong>：なめらかな曲線</summary>

### 数学での定義

制御点 `p0`, `p1`, `p2` について、

`B(t) = (1-t)^2 p0 + 2(1-t)t p1 + t^2 p2`

### 問題の型

補間、CG、アニメーション。

### Racketコード：1次元版

```racket
(define (quadratic-bezier p0 p1 p2 t)
  (+ (* (square (- 1 t)) p0)
     (* 2 (- 1 t) t p1)
     (* (square t) p2)))
```

### 確認用の呼び出し

```racket
(quadratic-bezier 0 10 0 0.5)
```

</details>

<details>
<summary><strong>67. 円運動</strong>：三角関数で円の座標を作る</summary>

### 数学での定義

半径 `r`、角度 `θ` の点は、

`x = r cos θ`

`y = r sin θ`

### 問題の型

三角関数、座標変換。

### Racketコード

```racket
(define (circle-point r theta)
  (make-point (* r (cos theta))
              (* r (sin theta))))
```

### 確認用の呼び出し

```racket
(circle-point 10 0)
(circle-point 10 (/ pi 2))
```

</details>

<details>
<summary><strong>68. サイン波</strong>：揺れ・周期運動</summary>

### 数学での定義

`A sin(ωt + φ)`

- `A`：振幅
- `ω`：角速度
- `φ`：位相

### 問題の型

三角関数、周期関数。

### Racketコード

```racket
(define (sine-wave amplitude omega phase t)
  (* amplitude (sin (+ (* omega t) phase))))
```

### 確認用の呼び出し

```racket
(sine-wave 2 3 0 1.0)
```

</details>

<details>
<summary><strong>69. 円同士の当たり判定</strong>：距離と半径で判定する</summary>

### 数学での定義

2つの円の中心距離が、半径の和以下なら衝突している。

### 問題の型

距離、条件分岐、ゲーム数学。

### Racketコード

```racket
(define (circle-collide? p1 r1 p2 r2)
  (<= (distance p1 p2) (+ r1 r2)))
```

### 確認用の呼び出し

```racket
(circle-collide? (make-point 0 0) 2
                 (make-point 3 0) 2)
```

</details>

---

# 10. 発展：少し高度だがプログラミングで使われる数学

<details>
<summary><strong>70. フーリエ級数の雰囲気</strong>：波を三角関数の和で近似する</summary>

### 数学での定義

周期的な波を、`sin` や `cos` の和で近似する。

矩形波の一例：

`4/π × (sin x + sin 3x/3 + sin 5x/5 + ...)`

### 問題の型

sum 型、三角関数、近似。

### Racketコード

```racket
(define (square-wave-approx x terms)
  (* (/ 4 pi)
     (sum (lambda (i)
            (let ((k (+ (* 2 i) 1)))
              (/ (sin (* k x)) k)))
          0 inc terms)))
```

### 確認用の呼び出し

```racket
(square-wave-approx 1.0 10)
```

</details>

<details>
<summary><strong>71. ロジスティック写像</strong>：単純な式から複雑な振る舞いが出る</summary>

### 数学での定義

`x_{n+1} = r x_n (1 - x_n)`

### 問題の型

反復、数列、カオスの入口。

### Racketコード

```racket
(define (logistic r x)
  (* r x (- 1 x)))

(define (logistic-list r x n)
  (if (= n 0)
      (list x)
      (cons x (logistic-list r (logistic r x) (- n 1)))))
```

### 確認用の呼び出し

```racket
(logistic-list 3.7 0.2 10)
```

</details>

<details>
<summary><strong>72. マンデルブロ集合の判定</strong>：複素数の反復</summary>

### 数学での定義

`z_0 = 0`

`z_{n+1} = z_n^2 + c`

を繰り返し、値が発散するかを見る。

### 問題の型

反復、複素数、フラクタル。

### Racketコード

```racket
(define (mandelbrot? c max-iter)
  (define (iter z count)
    (cond ((> (magnitude z) 2) #f)
          ((= count max-iter) #t)
          (else (iter (+ (* z z) c)
                      (+ count 1)))))
  (iter 0 0))
```

### 確認用の呼び出し

```racket
(mandelbrot? 0 50)
(mandelbrot? 2 50)
```

</details>

<details>
<summary><strong>73. ニュートンフラクタルの入口</strong>：複素数でニュートン法を回す</summary>

### 数学での定義

`z^3 - 1 = 0` の解に、ニュートン法で近づける。

### 問題の型

Newton法、複素数、反復。

### Racketコード

```racket
(define (newton-step-cubic z)
  (- z (/ (- (expt z 3) 1)
          (* 3 (square z)))))

(define (newton-cubic z steps)
  (if (= steps 0)
      z
      (newton-cubic (newton-step-cubic z)
                    (- steps 1))))
```

### 確認用の呼び出し

```racket
(newton-cubic 0.5+0.5i 20)
```

</details>

<details>
<summary><strong>74. メモ化</strong>：同じ計算を保存する</summary>

### 数学での定義

同じ入力に対する結果が変わらない関数について、一度計算した値を保存して再利用する。

### 問題の型

フィボナッチ、動的計画法、状態。

### Racketコード

```racket
(define (memoize f)
  (let ((table (make-hash)))
    (lambda (x)
      (hash-ref table x
                (lambda ()
                  (let ((result (f x)))
                    (hash-set! table x result)
                    result))))))

(define memo-fib
  (letrec ((mf (memoize
                (lambda (n)
                  (cond ((= n 0) 0)
                        ((= n 1) 1)
                        (else (+ (mf (- n 1))
                                 (mf (- n 2)))))))))
    mf))
```

### 確認用の呼び出し

```racket
(memo-fib 40)
```

### 注意

`set!` や `hash-set!` を使うので、純粋な再帰だけの話から一歩進んだ内容である。

</details>

<details>
<summary><strong>75. 動的計画法の考え方</strong>：小さい問題を保存して使う</summary>

### 数学での定義

大きな問題を小さな問題に分け、同じ小問題の答えを再利用する。

例：フィボナッチ数列では `F(n-1)` と `F(n-2)` を何度も計算しないようにする。

### 問題の型

反復、表、メモ化。

### Racketコード：リストでフィボナッチを作る

```racket
(define (fib-list n)
  (define (iter a b count result)
    (if (> count n)
        (reverse result)
        (iter b (+ a b) (+ count 1) (cons a result))))
  (iter 0 1 0 '()))
```

### 確認用の呼び出し

```racket
(fib-list 10)
```

</details>

---

# 11. どの型として覚えるか

| 型 | 代表例 | 見抜き方 |
|---|---|---|
| 条件分岐型 | コラッツ、素数判定 | 場合分けが定義にある |
| 線形再帰型 | 階乗、累乗 | `n` が `n-1` に変わる |
| 反復プロセス型 | 階乗反復、fib-iter | 補助関数に状態を持たせる |
| 木構造再帰型 | fib、tree-sum、square-tree | 再帰呼び出しが複数ある |
| sum 型 | 数値積分、級数 | `Σ` が出る |
| product 型 | 階乗、総乗 | `Π` が出る |
| accumulate 型 | sum/product一般化 | 足す・掛けるを引数にする |
| lambda 型 | 無名関数 | その場で関数を渡す |
| fixed-point 型 | 黄金比、平方根 | `x = g(x)` に直す |
| Newton法 型 | 平方根、方程式 | `g(x)=0` を解く |
| compose/repeated 型 | repeated、平均緩和の反復 | 手続きを返す |
| データ抽象型 | 有理数、区間、点 | `make-...` と selector がある |
| リスト処理型 | map/filter/sieve | `car` / `cdr` / `null?` を使う |
| グラフ探索型 | DFS/BFS | ノードと辺をたどる |

---

# 12. Racketで特に注意すること

- Racketでは `(x < 4)` ではなく `(< x 4)` と書く。
- `=` は代入ではなく比較である。
- 値を定義するには `define` を使う。
- 既存の値を変更するには `set!` を使うが、SICP前半ではなるべく使わない。
- `if` は「条件式」「真の場合」「偽の場合」を分けて書く。
- `cond` は複数の条件分岐に向いている。
- `sum`、`product`、`accumulate` には、値ではなく手続きを渡すことがある。
- `lambda` は無名手続きを作る構文であり、実行するには引数を渡す必要がある。
- `fixed-point` では `f(x)=0` ではなく `x=g(x)` の形に直した `g` を渡す。
- 再帰版と反復版は、同じ値を返しても、計算プロセスが異なる。
- `cons` / `car` / `cdr` を直接使いすぎず、`make-rat` / `numer` / `denom` のような抽象化の壁を作る。

---

# 13. 演習対策として優先して覚える順

1. 階乗
2. フィボナッチ数列
3. ユークリッドの互除法
4. 素数判定
5. 高速累乗
6. sum
7. product
8. accumulate
9. lambda
10. fixed-point
11. average-damp
12. Newton法
13. compose
14. repeated
15. iterative-improve
16. cons / car / cdr による有理数
17. map / filter
18. 木構造再帰
19. 数値積分
20. マクローリン展開



---

# 14. 追加拡張：数列・組合せ・符号化

この章以降は、前半の SICP / プログラミングB 範囲を越えて、  
ゲーム、数値計算、確率統計、アルゴリズム、CG、AI 入門などにもつながりやすい数学を追加したものである。

<details>
<summary><strong>76. リュカ数列</strong>：フィボナッチに近い漸化式</summary>

### 数学での定義

リュカ数列は、フィボナッチ数列と同じ形の漸化式を持つが、初期値が異なる。

- `L(0) = 2`
- `L(1) = 1`
- `L(n) = L(n - 1) + L(n - 2)`

### 問題の型

線形再帰、反復プロセス、フィボナッチ型。

### Racketコード

```racket
(define (lucas n)
  (cond ((= n 0) 2)
        ((= n 1) 1)
        (else (+ (lucas (- n 1))
                 (lucas (- n 2))))))
```

### 確認用の呼び出し

```racket
(lucas 0)
(lucas 1)
(lucas 5)
```

### 用途

フィボナッチの初期値だけを変えた発展例として、漸化式の理解に使える。

</details>

<details>
<summary><strong>77. ペル数列</strong>：平方根2に関係する数列</summary>

### 数学での定義

ペル数列は次の漸化式で定義される。

- `P(0) = 0`
- `P(1) = 1`
- `P(n) = 2P(n - 1) + P(n - 2)`

### 問題の型

漸化式、再帰プロセス。

### Racketコード

```racket
(define (pell n)
  (cond ((= n 0) 0)
        ((= n 1) 1)
        (else (+ (* 2 (pell (- n 1)))
                 (pell (- n 2))))))
```

### 確認用の呼び出し

```racket
(pell 0)
(pell 1)
(pell 5)
```

### 用途

フィボナッチ型の漸化式で、係数を変えると数列の増え方が変わることを確認できる。

</details>

<details>
<summary><strong>78. ベル数</strong>：集合の分割数</summary>

### 数学での定義

ベル数 `B(n)` は、`n` 個の要素をいくつかのグループに分ける方法の数である。

例として、`B(0)=1`, `B(1)=1`, `B(2)=2`, `B(3)=5` である。

### 問題の型

組合せ、再帰、二項係数との組み合わせ。

### Racketコード

```racket
(define (comb n k)
  (cond ((or (< k 0) (> k n)) 0)
        ((or (= k 0) (= k n)) 1)
        (else (+ (comb (- n 1) (- k 1))
                 (comb (- n 1) k)))))

(define (bell n)
  (if (= n 0)
      1
      (define (sum k)
        (if (> k (- n 1))
            0
            (+ (* (comb (- n 1) k) (bell k))
               (sum (+ k 1)))))
      (sum 0)))
```

### 確認用の呼び出し

```racket
(bell 0)
(bell 3)
(bell 4)
```

### 注意

このコードは数学の形を見せるための素朴な再帰版であり、大きな `n` ではかなり遅くなる。

</details>

<details>
<summary><strong>79. スターリング数 第2種</strong>：集合をk個の非空グループに分ける数</summary>

### 数学での定義

`S(n, k)` は、`n` 個の要素を `k` 個の空でないグループに分ける方法の数である。

- `S(0, 0) = 1`
- `S(n, 0) = 0`
- `S(0, k) = 0`
- `S(n, k) = kS(n - 1, k) + S(n - 1, k - 1)`

### 問題の型

二重再帰、組合せ、場合分け。

### Racketコード

```racket
(define (stirling2 n k)
  (cond ((and (= n 0) (= k 0)) 1)
        ((or (= n 0) (= k 0)) 0)
        (else (+ (* k (stirling2 (- n 1) k))
                 (stirling2 (- n 1) (- k 1))))))
```

### 確認用の呼び出し

```racket
(stirling2 3 2)
(stirling2 4 2)
```

### 考え方

新しい要素を既存の `k` 個のグループのどれかに入れる場合と、新しく1個のグループを作る場合に分ける。

</details>

<details>
<summary><strong>80. 完全順列</strong>：誰も元の位置にいない並べ替え</summary>

### 数学での定義

完全順列 `D(n)` は、`n` 個の要素を並べ替えるとき、どの要素も元の位置に戻らない並べ方の数である。

- `D(0) = 1`
- `D(1) = 0`
- `D(n) = (n - 1)(D(n - 1) + D(n - 2))`

### 問題の型

漸化式、再帰。

### Racketコード

```racket
(define (derangement n)
  (cond ((= n 0) 1)
        ((= n 1) 0)
        (else (* (- n 1)
                 (+ (derangement (- n 1))
                    (derangement (- n 2)))))))
```

### 確認用の呼び出し

```racket
(derangement 3)
(derangement 4)
```

### 用途

くじ引き、席替え、ランダムシャッフルの数学的分析に使える。

</details>

<details>
<summary><strong>81. 整数分割</strong>：整数を和に分ける</summary>

### 数学での定義

整数分割 `p(n)` は、正の整数 `n` を正の整数の和として表す方法の数である。  
順序は区別しない。

例：`4 = 4 = 3+1 = 2+2 = 2+1+1 = 1+1+1+1` なので `p(4)=5`。

### 問題の型

再帰、場合分け、コイン両替型。

### Racketコード

```racket
(define (partition-count n max-part)
  (cond ((= n 0) 1)
        ((or (< n 0) (= max-part 0)) 0)
        (else (+ (partition-count n (- max-part 1))
                 (partition-count (- n max-part) max-part)))))

(define (partitions n)
  (partition-count n n))
```

### 確認用の呼び出し

```racket
(partitions 4)
(partitions 5)
```

### 用途

コインの組み合わせ、アイテム構成、資源配分の問題に近い。

</details>

<details>
<summary><strong>82. グレイコード</strong>：隣り合う値が1ビットだけ違う符号</summary>

### 数学での定義

グレイコードは、連続する整数の符号表現が1ビットだけ変化するようにしたもの。  
整数 `n` のグレイコードは、しばしば次で表される。

`g(n) = n xor (n >> 1)`

### 問題の型

ビット演算、符号化。

### Racketコード

```racket
(define (gray-code n)
  (bitwise-xor n (arithmetic-shift n -1)))
```

### 確認用の呼び出し

```racket
(map gray-code '(0 1 2 3 4 5 6 7))
```

### 用途

センサー、状態遷移、隣接状態を少しずつ変える探索などで使われる。

</details>

---

# 15. 追加拡張：数論・暗号・合同式

<details>
<summary><strong>83. 拡張ユークリッド互除法</strong>：ax + by = gcd(a, b) を求める</summary>

### 数学での定義

最大公約数 `gcd(a,b)` に対して、整数 `x, y` が存在し、

`ax + by = gcd(a, b)`

を満たす。この `x, y` を求める方法が拡張ユークリッド互除法である。

### 問題の型

再帰、戻り値が複数あるデータ抽象型。

### Racketコード

```racket
(define (extended-gcd a b)
  (if (= b 0)
      (list a 1 0)
      (let* ((result (extended-gcd b (remainder a b)))
             (g (car result))
             (x1 (cadr result))
             (y1 (caddr result)))
        (list g
              y1
              (- x1 (* (quotient a b) y1))))))

(define (egcd-g result) (car result))
(define (egcd-x result) (cadr result))
(define (egcd-y result) (caddr result))
```

### 確認用の呼び出し

```racket
(extended-gcd 30 12)
(extended-gcd 35 12)
```

### 用途

暗号、合同式、逆元の計算に使う。

</details>

<details>
<summary><strong>84. モジュラ逆元</strong>：割り算を合同式で扱う</summary>

### 数学での定義

`a` の `m` における逆元は、次を満たす整数 `x` である。

`ax ≡ 1 (mod m)`

ただし、逆元が存在するのは `gcd(a, m) = 1` のときである。

### 問題の型

拡張ユークリッド互除法、合同式。

### Racketコード

```racket
(define (mod-inverse a m)
  (let* ((result (extended-gcd a m))
         (g (car result))
         (x (cadr result)))
    (if (= g 1)
        (remainder (+ x m) m)
        #f)))
```

### 確認用の呼び出し

```racket
(mod-inverse 3 11)
(remainder (* 3 (mod-inverse 3 11)) 11)
```

### 用途

RSA暗号、合同式の割り算、競技プログラミングで使う。

</details>

<details>
<summary><strong>85. 中国剰余定理</strong>：複数の余り条件をまとめる</summary>

### 数学での定義

互いに素な `m1, m2` について、

- `x ≡ a1 (mod m1)`
- `x ≡ a2 (mod m2)`

を同時に満たす `x` は、`m1m2` を法として一意に決まる。

### 問題の型

合同式、データ抽象、数論。

### Racketコード：2条件版

```racket
(define (crt2 a1 m1 a2 m2)
  (let* ((n (* m1 m2))
         (n1 m2)
         (n2 m1)
         (b1 (mod-inverse n1 m1))
         (b2 (mod-inverse n2 m2)))
    (remainder (+ (* a1 n1 b1)
                  (* a2 n2 b2))
               n)))
```

### 確認用の呼び出し

```racket
(crt2 2 3 3 5)
```

### 説明

結果は `8` になる。実際に `8` は `3` で割ると余り `2`、`5` で割ると余り `3` である。

</details>

<details>
<summary><strong>86. オイラーのφ関数</strong>：n以下でnと互いに素な数の個数</summary>

### 数学での定義

`φ(n)` は、`1` 以上 `n` 以下の整数のうち、`n` と互いに素なものの個数である。

### 問題の型

filter / accumulate 型、数論。

### Racketコード

```racket
(define (coprime? a b)
  (= (gcd a b) 1))

(define (euler-phi n)
  (length (filter (lambda (k) (coprime? k n))
                  (enumerate-interval 1 n))))
```

### 確認用の呼び出し

```racket
(euler-phi 9)
(euler-phi 10)
```

### 用途

オイラーの定理、RSA暗号、周期性の分析に使う。

</details>

<details>
<summary><strong>87. フェルマー素数判定</strong>：合同式による素数らしさの検査</summary>

### 数学での定義

`n` が素数で、`a` が `n` と互いに素なら、

`a^n ≡ a (mod n)`

が成り立つ。これを使って素数らしさを調べる。

### 問題の型

高速累乗、合同式、確率的判定。

### Racketコード

```racket
(define (expmod base exp m)
  (cond ((= exp 0) 1)
        ((even? exp)
         (remainder (square (expmod base (/ exp 2) m)) m))
        (else
         (remainder (* base (expmod base (- exp 1) m)) m))))

(define (fermat-test n a)
  (= (expmod a n n) (remainder a n)))
```

### 確認用の呼び出し

```racket
(fermat-test 7 2)
(fermat-test 9 2)
```

### 注意

これは完全な素数判定ではない。合成数でも通る場合がある。

</details>

<details>
<summary><strong>88. RSA暗号の入口</strong>：公開鍵と秘密鍵の関係</summary>

### 数学での定義

RSAでは、2つの素数 `p, q` を用いて、

- `n = pq`
- `φ(n) = (p - 1)(q - 1)`
- `ed ≡ 1 (mod φ(n))`

となる `e, d` を使う。

### 問題の型

合同式、モジュラ累乗、逆元。

### Racketコード：小さい例

```racket
(define (rsa-make-d e p q)
  (mod-inverse e (* (- p 1) (- q 1))))

(define (rsa-encrypt message e n)
  (expmod message e n))

(define (rsa-decrypt cipher d n)
  (expmod cipher d n))
```

### 確認用の呼び出し

```racket
(define p 5)
(define q 11)
(define n (* p q))
(define e 3)
(define d (rsa-make-d e p q))

(define c (rsa-encrypt 7 e n))
(rsa-decrypt c d n)
```

### 注意

これは仕組みを理解するための極小例であり、実用的な暗号ではない。

</details>

---

# 16. 追加拡張：多項式・方程式・数値解析

<details>
<summary><strong>89. 二次方程式の解の公式</strong>：判別式で場合分けする</summary>

### 数学での定義

`ax^2 + bx + c = 0` の解は、

`x = (-b ± sqrt(b^2 - 4ac)) / 2a`

である。

### 問題の型

条件分岐、数式をそのまま前置記法に直す型。

### Racketコード

```racket
(define (quadratic-roots a b c)
  (let ((d (- (square b) (* 4 a c))))
    (cond ((< d 0) 'no-real-roots)
          ((= d 0) (list (/ (- b) (* 2 a))))
          (else (list (/ (+ (- b) (sqrt d)) (* 2 a))
                      (/ (- (- b) (sqrt d)) (* 2 a)))))))
```

### 確認用の呼び出し

```racket
(quadratic-roots 1 -3 2)
(quadratic-roots 1 2 1)
```

### よくあるミス

Racketでは `b^2 - 4ac` ではなく、`(- (square b) (* 4 a c))` のように前置記法で書く。

</details>

<details>
<summary><strong>90. ホーナー法</strong>：多項式を効率よく計算する</summary>

### 数学での定義

多項式

`a0 + a1x + a2x^2 + ... + anx^n`

は、次のように入れ子で計算できる。

`a0 + x(a1 + x(a2 + ...))`

### 問題の型

accumulate 型、リスト処理。

### Racketコード

```racket
(define (horner-eval x coefficients)
  (foldr (lambda (coef higher)
           (+ coef (* x higher)))
         0
         coefficients))
```

### 確認用の呼び出し

```racket
; 1 + 3x + 5x^2 を x=2 で評価
(horner-eval 2 '(1 3 5))
```

### 用途

多項式近似、マクローリン展開、数値計算で使う。

</details>

<details>
<summary><strong>91. 数値微分</strong>：差分で導関数を近似する</summary>

### 数学での定義

導関数は次の極限で定義される。

`f'(x) = lim_{h -> 0} (f(x+h) - f(x)) / h`

プログラムでは小さい `h` を使って近似する。

### 問題の型

高階手続き型。関数を引数として受け取る。

### Racketコード

```racket
(define (numerical-derivative f)
  (lambda (x)
    (/ (- (f (+ x dx)) (f x)) dx)))
```

### 確認用の呼び出し

```racket
((numerical-derivative square) 3)
((numerical-derivative cube) 2)
```

### 用途

Newton法、最適化、物理シミュレーションの近似に使う。

</details>

<details>
<summary><strong>92. 台形公式</strong>：積分を台形の面積で近似する</summary>

### 数学での定義

区間 `[a,b]` を `n` 分割し、各区間を台形として足し合わせる。

### 問題の型

sum 型、数値積分。

### Racketコード

```racket
(define (trapezoid f a b n)
  (let ((h (/ (- b a) n)))
    (define (term k)
      (let ((x (+ a (* k h))))
        (cond ((or (= k 0) (= k n)) (f x))
              (else (* 2 (f x))))))
    (* (/ h 2)
       (sum term 0 inc n))))
```

### 確認用の呼び出し

```racket
(trapezoid square 0 1 100)
```

### 用途

積分の近似、面積計算、物理量の累積に使う。

</details>

<details>
<summary><strong>93. オイラー法</strong>：微分方程式を近似的に解く</summary>

### 数学での定義

微分方程式

`dy/dt = f(t, y)`

に対して、時間幅 `dt` で次のように更新する。

`y_{next} = y + dt f(t, y)`

### 問題の型

反復プロセス、数値計算。

### Racketコード

```racket
(define (euler-step f t y dt)
  (+ y (* dt (f t y))))

(define (euler-solve f t y dt steps)
  (if (= steps 0)
      y
      (euler-solve f
                   (+ t dt)
                   (euler-step f t y dt)
                   dt
                   (- steps 1))))
```

### 確認用の呼び出し

```racket
; dy/dt = y, y(0)=1 を t=1 まで近似
(euler-solve (lambda (t y) y) 0 1 0.01 100)
```

### 用途

物理シミュレーション、ゲームの速度・位置更新に使う。

</details>

<details>
<summary><strong>94. ルンゲ＝クッタ法4次</strong>：オイラー法より精度の高い近似</summary>

### 数学での定義

`dy/dt = f(t, y)` に対して、4つの傾きを平均して次の値を求める。

### 問題の型

数値計算、反復プロセス。

### Racketコード

```racket
(define (rk4-step f t y dt)
  (let* ((k1 (f t y))
         (k2 (f (+ t (/ dt 2)) (+ y (* (/ dt 2) k1))))
         (k3 (f (+ t (/ dt 2)) (+ y (* (/ dt 2) k2))))
         (k4 (f (+ t dt) (+ y (* dt k3)))))
    (+ y (* (/ dt 6)
            (+ k1 (* 2 k2) (* 2 k3) k4)))))

(define (rk4-solve f t y dt steps)
  (if (= steps 0)
      y
      (rk4-solve f
                 (+ t dt)
                 (rk4-step f t y dt)
                 dt
                 (- steps 1))))
```

### 確認用の呼び出し

```racket
(rk4-solve (lambda (t y) y) 0 1 0.1 10)
```

### 用途

ゲーム物理、数値シミュレーション、微分方程式の近似解に使う。

</details>

<details>
<summary><strong>95. 割線法</strong>：微分を使わず方程式の解を近似する</summary>

### 数学での定義

方程式 `f(x)=0` の解を、2点を結ぶ直線の交点で近似する。

### 問題の型

反復改良、数値解法。

### Racketコード

```racket
(define (secant-method f x0 x1)
  (define (iter a b)
    (let ((next (- b
                   (/ (* (f b) (- b a))
                      (- (f b) (f a))))))
      (if (close-enough? next b)
          next
          (iter b next))))
  (iter x0 x1))
```

### 確認用の呼び出し

```racket
(secant-method (lambda (x) (- (square x) 2)) 1.0 2.0)
```

### 用途

ニュートン法と違い、導関数を直接用意しなくてよい。

</details>

<details>
<summary><strong>96. 偏微分の数値近似</strong>：多変数関数の一部だけを動かす</summary>

### 数学での定義

二変数関数 `f(x,y)` の `x` に関する偏微分は、

`∂f/∂x = lim_{h -> 0} (f(x+h,y)-f(x,y))/h`

である。

### 問題の型

高階手続き、多変数関数。

### Racketコード

```racket
(define (partial-x f)
  (lambda (x y)
    (/ (- (f (+ x dx) y)
          (f x y))
       dx)))

(define (partial-y f)
  (lambda (x y)
    (/ (- (f x (+ y dx))
          (f x y))
       dx)))
```

### 確認用の呼び出し

```racket
(define (f2 x y) (+ (square x) (square y)))
((partial-x f2) 3 4)
((partial-y f2) 3 4)
```

### 用途

勾配降下法、機械学習、最適化に使う。

</details>

---

# 17. 追加拡張：線形代数・ベクトル・行列

<details>
<summary><strong>97. ベクトルの加算</strong>：成分ごとに足す</summary>

### 数学での定義

`(a1, a2, ..., an) + (b1, b2, ..., bn) = (a1+b1, a2+b2, ..., an+bn)`

### 問題の型

map 型、リスト処理。

### Racketコード

```racket
(define (vector-add v w)
  (map + v w))
```

### 確認用の呼び出し

```racket
(vector-add '(1 2 3) '(4 5 6))
```

### 用途

位置、速度、力、座標変換などで使う。

</details>

<details>
<summary><strong>98. スカラー倍</strong>：ベクトル全体に同じ数を掛ける</summary>

### 数学での定義

`c(a1, a2, ..., an) = (ca1, ca2, ..., can)`

### 問題の型

map 型。

### Racketコード

```racket
(define (scale-vector c v)
  (map (lambda (x) (* c x)) v))
```

### 確認用の呼び出し

```racket
(scale-vector 3 '(1 2 3))
```

</details>

<details>
<summary><strong>99. ベクトルの長さ</strong>：各成分の二乗和の平方根</summary>

### 数学での定義

`||v|| = sqrt(v1^2 + v2^2 + ... + vn^2)`

### 問題の型

accumulate 型、map 型。

### Racketコード

```racket
(define (vector-length v)
  (sqrt (foldl + 0 (map square v))))
```

### 確認用の呼び出し

```racket
(vector-length '(3 4))
(vector-length '(1 2 2))
```

</details>

<details>
<summary><strong>100. 正規化</strong>：長さ1のベクトルにする</summary>

### 数学での定義

ベクトル `v` をその長さ `||v||` で割ると、長さ1のベクトルになる。

`v_normalized = v / ||v||`

### 問題の型

ベクトル計算、条件分岐。

### Racketコード

```racket
(define (normalize v)
  (let ((len (vector-length v)))
    (if (= len 0)
        v
        (scale-vector (/ 1 len) v))))
```

### 確認用の呼び出し

```racket
(normalize '(3 4))
(vector-length (normalize '(3 4)))
```

### 用途

ゲームの移動方向、弾の方向、カメラ方向に使う。

</details>

<details>
<summary><strong>101. コサイン類似度</strong>：2つのベクトルの向きの近さ</summary>

### 数学での定義

`cos θ = (v・w) / (||v||||w||)`

### 問題の型

内積、ベクトル長、データ処理。

### Racketコード

```racket
(define (cosine-similarity v w)
  (/ (dot v w)
     (* (vector-length v)
        (vector-length w))))
```

### 確認用の呼び出し

```racket
(cosine-similarity '(1 0) '(0 1))
(cosine-similarity '(1 0) '(2 0))
```

### 用途

向き判定、検索、文章ベクトル、AIの類似度計算に使う。

</details>

<details>
<summary><strong>102. 行列の転置</strong>：行と列を入れ替える</summary>

### 数学での定義

行列 `A` の転置 `A^T` は、行と列を入れ替えた行列である。

### 問題の型

リスト処理、map 型。

### Racketコード

```racket
(define (transpose matrix)
  (apply map list matrix))
```

### 確認用の呼び出し

```racket
(transpose '((1 2 3)
             (4 5 6)))
```

</details>

<details>
<summary><strong>103. 行列とベクトルの積</strong>：線形変換の基本</summary>

### 数学での定義

行列 `A` とベクトル `v` の積は、各行と `v` の内積で求める。

### 問題の型

map 型、内積。

### Racketコード

```racket
(define (matrix-vector-mul matrix v)
  (map (lambda (row) (dot row v)) matrix))
```

### 確認用の呼び出し

```racket
(matrix-vector-mul '((1 2)
                     (3 4))
                   '(10 20))
```

</details>

<details>
<summary><strong>104. 行列積</strong>：行と列の内積</summary>

### 数学での定義

`C = AB` の成分は、

`c_ij = Σ a_ik b_kj`

である。

### 問題の型

map、accumulate、リスト処理。

### Racketコード

```racket
(define (matrix-mul a b)
  (let ((bt (transpose b)))
    (map (lambda (row)
           (map (lambda (col)
                  (dot row col))
                bt))
         a)))
```

### 確認用の呼び出し

```racket
(matrix-mul '((1 2)
              (3 4))
            '((5 6)
              (7 8)))
```

### 用途

座標変換、3Dグラフィックス、ニューラルネットワークで使う。

</details>

<details>
<summary><strong>105. 2×2行列式</strong>：面積の倍率を表す</summary>

### 数学での定義

`[[a,b],[c,d]]` の行列式は、

`ad - bc`

である。

### 問題の型

データ抽象、リストから値を取り出す型。

### Racketコード

```racket
(define (det2 m)
  (let ((a (car (car m)))
        (b (cadr (car m)))
        (c (car (cadr m)))
        (d (cadr (cadr m))))
    (- (* a d) (* b c))))
```

### 確認用の呼び出し

```racket
(det2 '((1 2)
        (3 4)))
```

### 用途

面積、向き判定、逆行列の判定に使う。

</details>

<details>
<summary><strong>106. 2D回転行列</strong>：点を原点周りに回す</summary>

### 数学での定義

角度 `θ` だけ回転する行列は、

`[[cos θ, -sin θ], [sin θ, cos θ]]`

である。

### 問題の型

三角関数、行列とベクトルの積。

### Racketコード

```racket
(define (rotation-matrix theta)
  (list (list (cos theta) (- (sin theta)))
        (list (sin theta) (cos theta))))

(define (rotate-point p theta)
  (matrix-vector-mul (rotation-matrix theta) p))
```

### 確認用の呼び出し

```racket
(rotate-point '(1 0) (/ pi 2))
```

### 用途

ゲームの回転、弾の方向、カメラ演出に使う。

</details>

---

# 18. 追加拡張：確率・統計・情報量

<details>
<summary><strong>107. 条件付き確率</strong>：Bが起きた条件でAが起きる確率</summary>

### 数学での定義

`P(A|B) = P(A∩B) / P(B)`

ただし `P(B) ≠ 0` とする。

### 問題の型

確率の定義を式に直す型。

### Racketコード

```racket
(define (conditional-prob p-a-and-b p-b)
  (/ p-a-and-b p-b))
```

### 確認用の呼び出し

```racket
(conditional-prob 1/6 1/2)
```

### 用途

ベイズ推定、AI、診断問題、ゲーム内確率の調整に使う。

</details>

<details>
<summary><strong>108. ベイズの定理</strong>：観測後に確率を更新する</summary>

### 数学での定義

`P(A|B) = P(B|A)P(A) / P(B)`

### 問題の型

確率計算、式の変形。

### Racketコード

```racket
(define (bayes p-b-given-a p-a p-b)
  (/ (* p-b-given-a p-a) p-b))
```

### 確認用の呼び出し

```racket
(bayes 9/10 1/100 1/10)
```

### 用途

スパム判定、診断、推論、機械学習の入口として使われる。

</details>

<details>
<summary><strong>109. ポアソン分布</strong>：まれな事象の回数</summary>

### 数学での定義

平均発生回数を `λ` とすると、`k` 回起こる確率は、

`P(X=k) = e^{-λ} λ^k / k!`

である。

### 問題の型

確率分布、階乗、累乗。

### Racketコード

```racket
(define (poisson-pmf lambda k)
  (/ (* (exp (- lambda))
        (expt lambda k))
     (factorial k)))
```

### 確認用の呼び出し

```racket
(poisson-pmf 2 0)
(poisson-pmf 2 3)
```

### 用途

アクセス数、事故回数、敵出現回数などのモデルに使える。

</details>

<details>
<summary><strong>110. 幾何分布</strong>：初めて成功するまでの回数</summary>

### 数学での定義

成功確率 `p` の試行で、初めて成功するのが `k` 回目である確率は、

`P(X=k) = (1-p)^{k-1}p`

である。

### 問題の型

確率分布、累乗。

### Racketコード

```racket
(define (geometric-pmf p k)
  (* (expt (- 1 p) (- k 1)) p))
```

### 確認用の呼び出し

```racket
(geometric-pmf 1/2 1)
(geometric-pmf 1/2 3)
```

### 用途

ガチャで何回目に当たるか、成功までの待ち時間などに使う。

</details>

<details>
<summary><strong>111. zスコア</strong>：平均から何標準偏差離れているか</summary>

### 数学での定義

値 `x`、平均 `μ`、標準偏差 `σ` に対して、

`z = (x - μ) / σ`

である。

### 問題の型

統計、データ正規化。

### Racketコード

```racket
(define (z-score x mean sd)
  (/ (- x mean) sd))
```

### 確認用の呼び出し

```racket
(z-score 70 50 10)
```

### 用途

偏差値、データの標準化、機械学習の前処理に使う。

</details>

<details>
<summary><strong>112. 共分散</strong>：2つのデータの同時変化を見る</summary>

### 数学での定義

`cov(X,Y) = E[(X-μx)(Y-μy)]`

### 問題の型

map、平均、accumulate 型。

### Racketコード

```racket
(define (mean xs)
  (/ (foldl + 0 xs) (length xs)))

(define (covariance xs ys)
  (let ((mx (mean xs))
        (my (mean ys)))
    (mean (map (lambda (x y)
                 (* (- x mx) (- y my)))
               xs ys))))
```

### 確認用の呼び出し

```racket
(covariance '(1 2 3) '(2 4 6))
```

### 用途

相関、回帰分析、データ分析に使う。

</details>

<details>
<summary><strong>113. 相関係数</strong>：関係の強さを -1 から 1 で表す</summary>

### 数学での定義

`corr(X,Y) = cov(X,Y) / (σx σy)`

### 問題の型

統計、リスト処理。

### Racketコード

```racket
(define (standard-deviation xs)
  (sqrt (variance xs)))

(define (correlation xs ys)
  (/ (covariance xs ys)
     (* (standard-deviation xs)
        (standard-deviation ys))))
```

### 確認用の呼び出し

```racket
(correlation '(1 2 3) '(2 4 6))
(correlation '(1 2 3) '(6 4 2))
```

### 用途

データの関係を見る、特徴量選択、分析レポートに使う。

</details>

<details>
<summary><strong>114. 正規分布の密度関数</strong>：釣鐘型の分布</summary>

### 数学での定義

平均 `μ`、標準偏差 `σ` の正規分布の密度は、

`f(x) = 1/(σ√(2π)) exp(-(x-μ)^2/(2σ^2))`

である。

### 問題の型

関数定義、指数関数。

### Racketコード

```racket
(define (normal-pdf x mean sd)
  (* (/ 1 (* sd (sqrt (* 2 pi))))
     (exp (- (/ (square (- x mean))
                (* 2 (square sd)))))))
```

### 確認用の呼び出し

```racket
(normal-pdf 0 0 1)
(normal-pdf 1 0 1)
```

### 用途

誤差モデル、統計、機械学習、自然現象の近似に使う。

</details>

<details>
<summary><strong>115. シャノンエントロピー</strong>：情報の不確実性を測る</summary>

### 数学での定義

確率 `p_i` に対して、エントロピーは

`H = -Σ p_i log2(p_i)`

である。

### 問題の型

sum / map / filter 型。

### Racketコード

```racket
(define (log2 x)
  (/ (log x) (log 2)))

(define (entropy probabilities)
  (- (foldl + 0
            (map (lambda (p)
                   (if (= p 0)
                       0
                       (* p (log2 p))))
                 probabilities))))
```

### 確認用の呼び出し

```racket
(entropy '(1/2 1/2))
(entropy '(1 0))
```

### 用途

圧縮、情報理論、機械学習の損失関数に使われる。

</details>

<details>
<summary><strong>116. マルコフ連鎖</strong>：次の状態が現在の状態で決まる</summary>

### 数学での定義

状態ベクトル `v` と遷移行列 `P` に対して、次の状態は

`v_next = vP`

で表せる。

### 問題の型

行列・ベクトル計算、確率。

### Racketコード

```racket
(define (markov-step state transition)
  (matrix-vector-mul (transpose transition) state))
```

### 確認用の呼び出し

```racket
; 状態A,B。AからAへ0.8、AからBへ0.2、BからAへ0.3、BからBへ0.7
(markov-step '(1 0)
             '((0.8 0.2)
               (0.3 0.7)))
```

### 用途

天気モデル、ランダム生成、状態遷移、ゲームAIに使う。

</details>

---

# 19. 追加拡張：ソート・探索・動的計画法

<details>
<summary><strong>117. 挿入ソート</strong>：整列済み部分に1つずつ挿入する</summary>

### 数学での定義

リストを先頭から見て、すでに整列した部分に新しい要素を正しい位置へ入れる。

### 問題の型

リスト再帰、条件分岐。

### Racketコード

```racket
(define (insert x xs)
  (cond ((null? xs) (list x))
        ((<= x (car xs)) (cons x xs))
        (else (cons (car xs)
                    (insert x (cdr xs))))))

(define (insertion-sort xs)
  (if (null? xs)
      '()
      (insert (car xs)
              (insertion-sort (cdr xs)))))
```

### 確認用の呼び出し

```racket
(insertion-sort '(5 2 4 1 3))
```

### 用途

リスト再帰の練習に向いている。小さいデータでは分かりやすい。

</details>

<details>
<summary><strong>118. マージソート</strong>：分割統治法</summary>

### 数学での定義

リストを半分に分け、それぞれを整列し、最後に併合する。

### 問題の型

分割統治、再帰。

### Racketコード

```racket
(define (merge xs ys)
  (cond ((null? xs) ys)
        ((null? ys) xs)
        ((<= (car xs) (car ys))
         (cons (car xs) (merge (cdr xs) ys)))
        (else
         (cons (car ys) (merge xs (cdr ys))))))

(define (merge-sort xs)
  (if (or (null? xs) (null? (cdr xs)))
      xs
      (let* ((n (quotient (length xs) 2))
             (left (take xs n))
             (right (drop xs n)))
        (merge (merge-sort left)
               (merge-sort right)))))
```

### 確認用の呼び出し

```racket
(merge-sort '(5 2 4 1 3))
```

### 用途

計算量、分割統治法、再帰の発展問題として使いやすい。

</details>

<details>
<summary><strong>119. クイックソート</strong>：基準値で左右に分ける</summary>

### 数学での定義

基準値 `pivot` を選び、それより小さいものと大きいものに分けて再帰的に整列する。

### 問題の型

再帰、filter 型、分割統治。

### Racketコード

```racket
(define (quick-sort xs)
  (if (null? xs)
      '()
      (let ((pivot (car xs))
            (rest (cdr xs)))
        (append (quick-sort (filter (lambda (x) (< x pivot)) rest))
                (list pivot)
                (quick-sort (filter (lambda (x) (>= x pivot)) rest))))))
```

### 確認用の呼び出し

```racket
(quick-sort '(5 2 4 1 3))
```

### 用途

`filter` と再帰を組み合わせる例として分かりやすい。

</details>

<details>
<summary><strong>120. 線形探索</strong>：先頭から順に探す</summary>

### 数学での定義

リストの要素を先頭から確認し、目的の値と一致するか調べる。

### 問題の型

リスト再帰、条件分岐。

### Racketコード

```racket
(define (linear-search x xs)
  (cond ((null? xs) #f)
        ((equal? x (car xs)) #t)
        (else (linear-search x (cdr xs)))))
```

### 確認用の呼び出し

```racket
(linear-search 3 '(1 2 3 4))
(linear-search 9 '(1 2 3 4))
```

### 用途

最も基本的な探索。条件分岐と再帰の練習になる。

</details>

<details>
<summary><strong>121. 編集距離</strong>：文字列を変える最小操作回数</summary>

### 数学での定義

編集距離は、一方の文字列をもう一方に変えるための、挿入・削除・置換の最小回数である。

### 問題の型

動的計画法、再帰的定義。

### Racketコード：素朴な再帰版

```racket
(define (edit-distance xs ys)
  (cond ((null? xs) (length ys))
        ((null? ys) (length xs))
        ((equal? (car xs) (car ys))
         (edit-distance (cdr xs) (cdr ys)))
        (else (+ 1
                 (min (edit-distance (cdr xs) ys)
                      (edit-distance xs (cdr ys))
                      (edit-distance (cdr xs) (cdr ys)))))))
```

### 確認用の呼び出し

```racket
(edit-distance '(k i t t e n) '(s i t t i n g))
```

### 用途

文字列比較、スペル修正、DNA配列比較に使う。

</details>

<details>
<summary><strong>122. 最長共通部分列 LCS</strong>：順序を保って共通する最長列</summary>

### 数学での定義

2つの列から、順序を保ったまま共通に取り出せる最長の部分列の長さを求める。

### 問題の型

動的計画法、二重再帰。

### Racketコード：素朴な再帰版

```racket
(define (lcs-length xs ys)
  (cond ((or (null? xs) (null? ys)) 0)
        ((equal? (car xs) (car ys))
         (+ 1 (lcs-length (cdr xs) (cdr ys))))
        (else (max (lcs-length (cdr xs) ys)
                   (lcs-length xs (cdr ys)))))))
```

### 確認用の呼び出し

```racket
(lcs-length '(a b c d) '(a c b d))
```

### 用途

差分比較、テキスト比較、系列データの比較に使う。

</details>

<details>
<summary><strong>123. ナップサック問題</strong>：制限内で価値を最大化する</summary>

### 数学での定義

重さと価値を持つ品物から、重さの上限を超えないように選び、価値の合計を最大化する。

### 問題の型

動的計画法、再帰的場合分け。

### Racketコード：素朴な再帰版

```racket
(define (knapsack weights values capacity)
  (cond ((or (null? weights) (= capacity 0)) 0)
        ((> (car weights) capacity)
         (knapsack (cdr weights) (cdr values) capacity))
        (else
         (max (knapsack (cdr weights) (cdr values) capacity)
              (+ (car values)
                 (knapsack (cdr weights)
                           (cdr values)
                           (- capacity (car weights)))))))))
```

### 確認用の呼び出し

```racket
(knapsack '(2 1 3) '(4 2 7) 3)
```

### 用途

アイテム選択、リソース配分、最適化問題に使う。

</details>

<details>
<summary><strong>124. Bellman-Ford法の入口</strong>：辺を何度も緩和する最短経路</summary>

### 数学での定義

各辺 `(u, v, w)` について、もし `dist[u] + w < dist[v]` なら `dist[v]` を更新する。  
この操作を繰り返すことで最短距離を求める。

### 問題の型

反復更新、グラフ、リスト処理。

### Racketコード：1回の緩和

```racket
(define (lookup key alist default)
  (let ((p (assoc key alist)))
    (if p (cdr p) default)))

(define (set-dist key value alist)
  (cons (cons key value)
        (filter (lambda (p) (not (equal? (car p) key))) alist)))

(define (relax-edge edge dist)
  (let* ((u (car edge))
         (v (cadr edge))
         (w (caddr edge))
         (du (lookup u dist +inf.0))
         (dv (lookup v dist +inf.0)))
    (if (< (+ du w) dv)
        (set-dist v (+ du w) dist)
        dist)))
```

### 確認用の呼び出し

```racket
(relax-edge '(A B 3) '((A . 0) (B . +inf.0)))
```

### 用途

最短経路、ゲームAI、ネットワーク解析に使う。

</details>

---

# 20. 追加拡張：幾何・衝突判定・ゲーム数学

<details>
<summary><strong>125. 外積の符号</strong>：左右どちらに曲がるか判定する</summary>

### 数学での定義

2Dベクトル `(ax, ay)` と `(bx, by)` の外積に相当する値は、

`axby - aybx`

である。正なら左回り、負なら右回りを表す。

### 問題の型

ベクトル、幾何、条件分岐。

### Racketコード

```racket
(define (cross2 a b)
  (- (* (car a) (cadr b))
     (* (cadr a) (car b))))

(define (sub2 a b)
  (list (- (car a) (car b))
        (- (cadr a) (cadr b))))

(define (orientation p q r)
  (cross2 (sub2 q p) (sub2 r p)))
```

### 確認用の呼び出し

```racket
(orientation '(0 0) '(1 0) '(1 1))
(orientation '(0 0) '(1 0) '(1 -1))
```

### 用途

線分交差、ポリゴン、経路判定に使う。

</details>

<details>
<summary><strong>126. 線分交差判定</strong>：2本の線分が交わるか</summary>

### 数学での定義

線分 `p1-p2` と `q1-q2` が交差するかを、向き判定の符号で調べる。

### 問題の型

幾何、条件分岐。

### Racketコード：一般位置の簡易版

```racket
(define (opposite-sign? a b)
  (< (* a b) 0))

(define (segments-intersect? p1 p2 q1 q2)
  (and (opposite-sign? (orientation p1 p2 q1)
                       (orientation p1 p2 q2))
       (opposite-sign? (orientation q1 q2 p1)
                       (orientation q1 q2 p2))))
```

### 確認用の呼び出し

```racket
(segments-intersect? '(0 0) '(2 2) '(0 2) '(2 0))
(segments-intersect? '(0 0) '(1 0) '(0 1) '(1 1))
```

### 注意

端点で接する場合や一直線上に重なる場合は、この簡易版では扱っていない。

</details>

<details>
<summary><strong>127. 多角形の面積</strong>：靴紐公式</summary>

### 数学での定義

頂点 `(x_i, y_i)` が順に並んでいる多角形の面積は、

`1/2 |Σ(x_i y_{i+1} - y_i x_{i+1})|`

で求められる。

### 問題の型

リスト処理、幾何、accumulate 型。

### Racketコード

```racket
(define (shoelace-area points)
  (define closed (append points (list (car points))))
  (define (sum-cross ps)
    (if (null? (cdr ps))
        0
        (+ (cross2 (car ps) (cadr ps))
           (sum-cross (cdr ps)))))
  (/ (abs (sum-cross closed)) 2))
```

### 確認用の呼び出し

```racket
(shoelace-area '((0 0) (2 0) (2 2) (0 2)))
```

### 用途

マップ領域、当たり判定、ポリゴン処理に使う。

</details>

<details>
<summary><strong>128. AABB衝突判定</strong>：軸に平行な長方形同士の当たり判定</summary>

### 数学での定義

2つの長方形が重なるには、x方向とy方向の区間がどちらも重なっている必要がある。

### 問題の型

条件分岐、区間判定。

### Racketコード

```racket
(define (overlap-interval? a-min a-max b-min b-max)
  (and (<= a-min b-max)
       (<= b-min a-max)))

(define (aabb-intersect? ax1 ay1 ax2 ay2 bx1 by1 bx2 by2)
  (and (overlap-interval? ax1 ax2 bx1 bx2)
       (overlap-interval? ay1 ay2 by1 by2)))
```

### 確認用の呼び出し

```racket
(aabb-intersect? 0 0 2 2 1 1 3 3)
(aabb-intersect? 0 0 1 1 2 2 3 3)
```

### 用途

2Dゲームの当たり判定で基本になる。

</details>

<details>
<summary><strong>129. レイと円の交差</strong>：直線状の攻撃・視線判定</summary>

### 数学での定義

レイの始点 `o`、方向 `d`、円の中心 `c`、半径 `r` に対して、  
中心までのベクトルをレイ方向に射影し、最短距離が半径以下なら交差する。

### 問題の型

内積、距離、条件分岐。

### Racketコード：方向ベクトルは正規化済みとする

```racket
(define (ray-circle-hit? origin dir center radius)
  (let* ((oc (sub2 center origin))
         (t (dot oc dir))
         (closest (vector-add origin (scale-vector t dir)))
         (dist (distance closest center)))
    (and (>= t 0)
         (<= dist radius))))
```

### 確認用の呼び出し

```racket
(ray-circle-hit? '(0 0) '(1 0) '(5 1) 1)
(ray-circle-hit? '(0 0) '(1 0) '(5 2) 1)
```

### 用途

レーザー、視線、ロックオン判定、弾道判定に使う。

</details>

<details>
<summary><strong>130. 三次ベジェ曲線</strong>：4点でなめらかな曲線を作る</summary>

### 数学での定義

4つの制御点 `p0, p1, p2, p3` と `0 <= t <= 1` に対して、

`B(t) = (1-t)^3p0 + 3(1-t)^2tp1 + 3(1-t)t^2p2 + t^3p3`

である。

### 問題の型

補間、CG、数式のコード化。

### Racketコード：1次元版

```racket
(define (cubic-bezier p0 p1 p2 p3 t)
  (+ (* (expt (- 1 t) 3) p0)
     (* 3 (square (- 1 t)) t p1)
     (* 3 (- 1 t) (square t) p2)
     (* (expt t 3) p3)))
```

### 確認用の呼び出し

```racket
(cubic-bezier 0 10 20 30 0.5)
```

### 用途

UIアニメーション、カメラ移動、弾道、曲線パスに使う。

</details>

<details>
<summary><strong>131. smoothstep</strong>：なめらかな補間</summary>

### 数学での定義

`0 <= t <= 1` に対して、

`smoothstep(t) = 3t^2 - 2t^3`

である。

### 問題の型

補間、関数変換。

### Racketコード

```racket
(define (smoothstep t)
  (- (* 3 (square t))
     (* 2 (cube t))))

(define (smooth-lerp a b t)
  (lerp a b (smoothstep t)))
```

### 確認用の呼び出し

```racket
(smoothstep 0)
(smoothstep 0.5)
(smoothstep 1)
(smooth-lerp 0 10 0.5)
```

### 用途

ゲームのカメラ、UI、フェード、移動の自然な補間に使う。

</details>

<details>
<summary><strong>132. 値の範囲変換</strong>：ある範囲の値を別の範囲へ写す</summary>

### 数学での定義

`x` が `[a,b]` にあるとき、まず

`t = (x-a)/(b-a)`

として、次に `[c,d]` へ

`c + t(d-c)`

で写す。

### 問題の型

線形補間、正規化。

### Racketコード

```racket
(define (inverse-lerp a b x)
  (/ (- x a) (- b a)))

(define (map-range a b c d x)
  (lerp c d (inverse-lerp a b x)))
```

### 確認用の呼び出し

```racket
(map-range 0 100 0 1 25)
(map-range 0 100 -1 1 25)
```

### 用途

HPバー、音量、入力値、UIスライダー、ゲームパラメータ調整に使う。

</details>

---

# 21. 追加拡張：信号処理・波・画像処理

<details>
<summary><strong>133. 移動平均</strong>：データをなめらかにする</summary>

### 数学での定義

直近 `n` 個の平均を取ることで、細かい揺れを減らす。

### 問題の型

リスト処理、平均。

### Racketコード

```racket
(define (average-list xs)
  (/ (foldl + 0 xs) (length xs)))

(define (windows n xs)
  (if (< (length xs) n)
      '()
      (cons (take xs n)
            (windows n (cdr xs)))))

(define (moving-average n xs)
  (map average-list (windows n xs)))
```

### 確認用の呼び出し

```racket
(moving-average 3 '(1 2 3 10 11 12))
```

### 用途

センサーデータ、株価、ゲーム入力の揺れ軽減に使う。

</details>

<details>
<summary><strong>134. 畳み込み</strong>：周辺の値を重み付きで混ぜる</summary>

### 数学での定義

1次元の畳み込みは、データ列とカーネルをずらしながら内積を取る操作である。

### 問題の型

リスト処理、内積、信号処理。

### Racketコード：簡易版

```racket
(define (convolve-1d signal kernel)
  (let ((k (length kernel)))
    (map (lambda (window)
           (dot window kernel))
         (windows k signal))))
```

### 確認用の呼び出し

```racket
(convolve-1d '(1 2 3 4 5) '(1 0 -1))
```

### 用途

画像処理、エッジ検出、ぼかし、音声処理に使う。

</details>

<details>
<summary><strong>135. 指数移動平均</strong>：新しい値を強めに反映する平滑化</summary>

### 数学での定義

`0 <= α <= 1` として、

`S_next = αx + (1-α)S`

で更新する。

### 問題の型

反復、漸化式。

### Racketコード

```racket
(define (ema alpha xs)
  (define (iter rest current)
    (if (null? rest)
        (list current)
        (cons current
              (iter (cdr rest)
                    (+ (* alpha (car rest))
                       (* (- 1 alpha) current)))))))
  (if (null? xs)
      '()
      (iter (cdr xs) (car xs))))
```

### 確認用の呼び出し

```racket
(ema 0.5 '(10 12 14 30 16))
```

### 用途

カメラ追従、照準補正、センサー値の平滑化に使う。

</details>

<details>
<summary><strong>136. 離散フーリエ変換 DFT</strong>：波を周波数成分に分ける</summary>

### 数学での定義

長さ `N` の列 `x_n` に対して、

`X_k = Σ x_n e^{-2πikn/N}`

で周波数成分を求める。

### 問題の型

複素数、sum 型、信号処理。

### Racketコード：素朴な版

```racket
(define (dft xs)
  (let ((n (length xs)))
    (map (lambda (k)
           (foldl + 0
                  (map (lambda (x j)
                         (* x (exp (* 0-1i 2 pi k j (/ 1 n)))))
                       xs
                       (enumerate-interval 0 (- n 1)))))
         (enumerate-interval 0 (- n 1)))))
```

### 確認用の呼び出し

```racket
(dft '(1 0 0 0))
```

### 用途

音声、画像、周期解析、FFTの理解の入口になる。

</details>

<details>
<summary><strong>137. しきい値処理</strong>：値を2値に分ける</summary>

### 数学での定義

値 `x` がしきい値 `t` 以上なら `1`、そうでなければ `0` にする。

### 問題の型

条件分岐、画像処理。

### Racketコード

```racket
(define (threshold t x)
  (if (>= x t) 1 0))

(define (threshold-list t xs)
  (map (lambda (x) (threshold t x)) xs))
```

### 確認用の呼び出し

```racket
(threshold-list 5 '(1 3 5 7 9))
```

### 用途

画像の白黒化、判定処理、分類の入口に使う。

</details>

---

# 22. 追加拡張：機械学習・最適化の入口

<details>
<summary><strong>138. シグモイド関数</strong>：値を0から1に押し込む</summary>

### 数学での定義

`σ(x) = 1 / (1 + e^{-x})`

### 問題の型

関数定義、指数関数。

### Racketコード

```racket
(define (sigmoid x)
  (/ 1 (+ 1 (exp (- x)))))
```

### 確認用の呼び出し

```racket
(sigmoid 0)
(sigmoid 10)
(sigmoid -10)
```

### 用途

ロジスティック回帰、ニューラルネットワーク、確率的な出力に使う。

</details>

<details>
<summary><strong>139. パーセプトロン</strong>：重み付き和で分類する</summary>

### 数学での定義

入力 `x` と重み `w` に対して、内積 `w・x + b` が0以上なら1、そうでなければ0とする。

### 問題の型

内積、条件分岐、線形分類。

### Racketコード

```racket
(define (perceptron weights bias input)
  (if (>= (+ (dot weights input) bias) 0)
      1
      0))
```

### 確認用の呼び出し

```racket
(perceptron '(1 1) -1.5 '(1 1))
(perceptron '(1 1) -1.5 '(1 0))
```

### 用途

ニューラルネットワークの最小単位として理解しやすい。

</details>

<details>
<summary><strong>140. 平均二乗誤差 MSE</strong>：予測と正解のずれを測る</summary>

### 数学での定義

予測値 `y_hat` と正解 `y` に対して、

`MSE = (1/n)Σ(y_hat_i - y_i)^2`

である。

### 問題の型

map、sum、統計。

### Racketコード

```racket
(define (mse predictions targets)
  (mean (map (lambda (p t)
               (square (- p t)))
             predictions
             targets)))
```

### 確認用の呼び出し

```racket
(mse '(2 4 6) '(1 5 7))
```

### 用途

回帰問題、AIの損失関数、近似の誤差評価に使う。

</details>

<details>
<summary><strong>141. 単回帰直線</strong>：データに合う直線を求める</summary>

### 数学での定義

データ `(x_i, y_i)` に対して、

`y = ax + b`

の形で近似する。傾き `a` は、

`a = cov(x,y) / var(x)`

で求められる。

### 問題の型

統計、最小二乗法。

### Racketコード

```racket
(define (linear-regression xs ys)
  (let* ((a (/ (covariance xs ys)
               (variance xs)))
         (b (- (mean ys)
               (* a (mean xs)))))
    (list a b)))

(define (predict-line model x)
  (+ (* (car model) x) (cadr model)))
```

### 確認用の呼び出し

```racket
(define model (linear-regression '(1 2 3) '(2 4 6)))
model
(predict-line model 4)
```

### 用途

データ分析、予測、機械学習の入口として使いやすい。

</details>

<details>
<summary><strong>142. 勾配降下法による直線フィット</strong>：少しずつ誤差を減らす</summary>

### 数学での定義

予測 `y_hat = ax + b` に対して、誤差が小さくなる方向へ `a, b` を少しずつ更新する。

### 問題の型

反復改良、最適化。

### Racketコード：1ステップ更新

```racket
(define (gd-line-step xs ys a b rate)
  (let* ((n (length xs))
         (preds (map (lambda (x) (+ (* a x) b)) xs))
         (errors (map - preds ys))
         (da (* (/ 2 n) (foldl + 0 (map * errors xs))))
         (db (* (/ 2 n) (foldl + 0 errors))))
    (list (- a (* rate da))
          (- b (* rate db)))))
```

### 確認用の呼び出し

```racket
(gd-line-step '(1 2 3) '(2 4 6) 0 0 0.01)
```

### 用途

機械学習で「パラメータを更新する」とは何かを確認できる。

</details>

<details>
<summary><strong>143. k平均法の入口</strong>：近い中心に分類する</summary>

### 数学での定義

各データ点を、最も近い中心点に割り当てる。  
これを繰り返してクラスタを作る。

### 問題の型

距離、最小値探索、分類。

### Racketコード：1次元の割り当て

```racket
(define (nearest-center x centers)
  (define (closer a b)
    (if (< (abs (- x a)) (abs (- x b))) a b))
  (foldl closer (car centers) (cdr centers)))

(define (assign-centers xs centers)
  (map (lambda (x)
         (list x (nearest-center x centers)))
       xs))
```

### 確認用の呼び出し

```racket
(assign-centers '(1 2 8 9) '(0 10))
```

### 用途

クラスタリング、敵AIの分類、データのグループ分けに使う。

</details>

---

# 23. 追加拡張：論理・集合・関係

<details>
<summary><strong>144. 集合の和集合</strong>：どちらかに含まれる要素</summary>

### 数学での定義

`A ∪ B = {x | x∈A または x∈B}`

### 問題の型

集合、filter、リスト処理。

### Racketコード：重複なしリストを集合として扱う

```racket
(define (member-set? x s)
  (cond ((null? s) #f)
        ((equal? x (car s)) #t)
        (else (member-set? x (cdr s)))))

(define (union-set a b)
  (cond ((null? a) b)
        ((member-set? (car a) b)
         (union-set (cdr a) b))
        (else
         (cons (car a) (union-set (cdr a) b)))))
```

### 確認用の呼び出し

```racket
(union-set '(1 2 3) '(3 4 5))
```

</details>

<details>
<summary><strong>145. 集合の共通部分</strong>：両方に含まれる要素</summary>

### 数学での定義

`A ∩ B = {x | x∈A かつ x∈B}`

### 問題の型

filter、条件分岐。

### Racketコード

```racket
(define (intersection-set a b)
  (filter (lambda (x) (member-set? x b)) a))
```

### 確認用の呼び出し

```racket
(intersection-set '(1 2 3) '(3 4 5))
```

</details>

<details>
<summary><strong>146. ド・モルガンの法則</strong>：否定とand/orの関係</summary>

### 数学での定義

論理では次が成り立つ。

- `not (A and B) = (not A) or (not B)`
- `not (A or B) = (not A) and (not B)`

### 問題の型

論理式、条件分岐。

### Racketコード

```racket
(define (de-morgan-1 a b)
  (equal? (not (and a b))
          (or (not a) (not b))))

(define (de-morgan-2 a b)
  (equal? (not (or a b))
          (and (not a) (not b))))
```

### 確認用の呼び出し

```racket
(de-morgan-1 #t #f)
(de-morgan-2 #t #f)
```

### 用途

条件式の整理、バグの少ない分岐条件を作るときに使う。

</details>

<details>
<summary><strong>147. 真理値表</strong>：論理式の全パターンを調べる</summary>

### 数学での定義

命題変数が真または偽を取る全組み合わせに対して、論理式の値を調べる表である。

### 問題の型

高階手続き、リスト生成。

### Racketコード：2変数版

```racket
(define bools '(#t #f))

(define (truth-table-2 f)
  (map (lambda (a)
         (map (lambda (b)
                (list a b (f a b)))
              bools))
       bools))
```

### 確認用の呼び出し

```racket
(truth-table-2 (lambda (a b) (and a b)))
(truth-table-2 (lambda (a b) (or (not a) b)))
```

### 用途

論理式の確認、条件分岐のテストに使う。

</details>

---

# 24. 追加拡張：覚える優先度

## SICP / プログラミングB演習に直結しやすい

1. 再帰・反復：階乗、フィボナッチ、ユークリッドの互除法
2. 高階手続き：sum、product、accumulate、lambda
3. 近似計算：fixed-point、average-damp、Newton法、数値微分
4. データ抽象：有理数、区間、集合、木構造
5. リスト処理：map、filter、fold、木構造再帰

## 一般プログラミングで使いやすい

1. ベクトル、内積、距離、正規化
2. 線形補間、smoothstep、ベジェ曲線
3. ソート、探索、動的計画法
4. 確率分布、期待値、分散、相関
5. 行列、回転、座標変換

## ゲーム制作・CGで使いやすい

1. ベクトル加算、正規化、内積
2. 円・AABB・線分交差の当たり判定
3. lerp、smoothstep、ベジェ曲線
4. サイン波、移動平均、指数移動平均
5. DFT、畳み込み、ノイズ、フラクタル

## AI・データ分析で使いやすい

1. 平均、分散、標準偏差、zスコア
2. 共分散、相関係数
3. シグモイド、MSE、線形回帰
4. 勾配降下法
5. エントロピー、ベイズの定理

## よくあるRacket上の注意

- `x < 4` ではなく `(< x 4)` と書く。
- `a + b` ではなく `(+ a b)` と書く。
- `a * b` ではなく `(* a b)` と書く。
- `=` は代入ではなく数値比較である。
- 値を定義するなら `define`、既存の変数を書き換えるなら `set!` だが、SICP初期では基本的に `set!` は避ける。
- `lambda` は手続きを作るだけであり、実行するには `((lambda (x) ...) 3)` のように引数を渡す。
- `map`、`filter`、`foldl` には値ではなく手続きを渡す。
- fixed-point には `f(x)=0` ではなく、`x=g(x)` の形の `g` を渡す。
- 再帰版と反復版では、結果が同じでも計算過程と計算量が異なる。
- 大きな入力に対して素朴な再帰が遅い場合は、反復版、メモ化、動的計画法を考える。

