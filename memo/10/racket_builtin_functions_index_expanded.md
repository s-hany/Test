# Racket 組み込み関数インデックス拡張版

元の `racket_組み込み関数一覧.txt` をもとに、Markdownで見やすく整理し直した版である。  
プログラミングB / SICP系の課題で使いやすいように、**前置記法・用途・よくあるミス**も併記した。

> 想定：基本的には `#lang racket`。  
> `#lang sicp` や授業用テンプレートでは、一部の手続きがそのまま使えない場合がある。  
> 課題では、課題ファイルで用意された補助手続き・禁止事項を優先する。

---

## 目次

1. [Racketの基本ルール](#1-racketの基本ルール)
2. [数値・四則演算](#2-数値四則演算)
3. [指数・平方根・数学関数](#3-指数平方根数学関数)
4. [商・余り・整数処理](#4-商余り整数処理)
5. [数値比較・数値述語](#5-数値比較数値述語)
6. [条件分岐・真偽値](#6-条件分岐真偽値)
7. [define・lambda・局所変数](#7-definelambda局所変数)
8. [ペア・リストの基本](#8-ペアリストの基本)
9. [リスト処理・高階手続き](#9-リスト処理高階手続き)
10. [文字列](#10-文字列)
11. [文字・記号](#11-文字記号)
12. [ベクタ](#12-ベクタ)
13. [ハッシュ表](#13-ハッシュ表)
14. [等しさの比較](#14-等しさの比較)
15. [入出力・表示](#15-入出力表示)
16. [代入・副作用](#16-代入副作用)
17. [プログラミングBで特に重要なもの](#17-プログラミングbで特に重要なもの)
18. [すぐ使える例まとめ](#18-すぐ使える例まとめ)

---

# 1. Racketの基本ルール

<details open>
<summary><strong>1.1 前置記法</strong></summary>

Racketでは、演算子や手続きを先頭に書く。

```racket
(+ 1 2)
(* 3 4)
(< x 10)
(expt 2 3)
```

数学やC言語風に次のようには書かない。

```racket
1 + 2
3 * 4
x < 10
2^3
```

</details>

<details open>
<summary><strong>1.2 手続き呼び出しの形</strong></summary>

基本形は次である。

```racket
(手続き 引数1 引数2 ...)
```

例：

```racket
(max 3 8 2)
(string-append "ab" "cd")
(map add1 '(1 2 3))
```

`?` で終わる名前は、多くの場合「真偽値を返す手続き」である。

```racket
(number? 10)
(list? '(1 2 3))
(null? '())
(even? 4)
```

</details>

---

# 2. 数値・四則演算

<details open>
<summary><strong>2.1 数値計算の基本</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `+` | `(+ 1 2 3)` | 足し算。複数個まとめて足せる | `6` |
| `-` | `(- 10 3)` | 引き算 | `7` |
| `-` | `(- 5)` | 1引数だと符号反転 | `-5` |
| `*` | `(* 2 3 4)` | 掛け算。複数個まとめて掛けられる | `24` |
| `/` | `(/ 8 2)` | 割り算 | `4` |
| `/` | `(/ 10 4)` | 整数同士だと分数になる場合がある | `5/2` |
| `add1` | `(add1 5)` | 1増やす | `6` |
| `sub1` | `(sub1 5)` | 1減らす | `4` |
| `abs` | `(abs -7)` | 絶対値 | `7` |
| `max` | `(max 3 10 7)` | 最大値 | `10` |
| `min` | `(min 3 10 7)` | 最小値 | `3` |

### すぐ使える例

```racket
(+ 1 2 3 4)       ; 10
(- 10 3 2)        ; 5
(* 2 3 4)         ; 24
(/ 10 4)          ; 5/2
(/ 10.0 4)        ; 2.5
(add1 9)          ; 10
(sub1 9)          ; 8
(abs -12)         ; 12
(max 8 2 15 4)    ; 15
(min 8 2 15 4)    ; 2
```

### メモ

`/` は整数同士でも小数ではなく分数を返すことがある。小数が欲しいときは `10.0` のように小数を混ぜる。

</details>

---

# 3. 指数・平方根・数学関数

<details open>
<summary><strong>3.1 指数・平方根・対数</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `expt` | `(expt 2 3)` | べき乗。数学でいう `2^3` | `8` |
| `sqrt` | `(sqrt 9)` | 平方根 | `3` |
| `sqr` | `(sqr 5)` | 二乗 | `25` |
| `exp` | `(exp 1)` | 自然対数の底 `e` のべき乗 | `e` に近い値 |
| `log` | `(log 10)` | 自然対数 | 底は `e` |
| `log` | `(log 8 2)` | 底を指定した対数 | `3` |

### すぐ使える例

```racket
(expt 2 10)   ; 1024
(expt 9 1/2)  ; 3
(sqrt 16)     ; 4
(sqr 7)       ; 49
(log 8 2)     ; 3
```

### メモ

SICPの指数計算では、`expt` を使わずに自分で再帰版・反復版・高速版を書くことがある。`expt` は「結果を確認するための組み込み手続き」として見るとよい。

</details>
<details open>
<summary><strong>3.2 三角関数</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `sin` | `(sin x)` | 正弦 | 角度はラジアン |
| `cos` | `(cos x)` | 余弦 | 角度はラジアン |
| `tan` | `(tan x)` | 正接 | 角度はラジアン |
| `asin` | `(asin x)` | 逆正弦 | 返り値はラジアン |
| `acos` | `(acos x)` | 逆余弦 | 返り値はラジアン |
| `atan` | `(atan x)` | 逆正接 | 返り値はラジアン |
| `pi` | `pi` | 円周率 | 定数 |

### すぐ使える例

```racket
(sin 0)        ; 0
(cos 0)        ; 1
(sin (/ pi 2)) ; 1
(cos pi)       ; -1
(atan 1)       ; pi/4 に近い値
```

### メモ

`sin` や `cos` に渡す角度は度数法ではなくラジアンである。90度は `(/ pi 2)` と書く。

</details>
<details open>
<summary><strong>3.3 丸め・整数化</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `round` | `(round 2.6)` | 丸め | `3.0` |
| `floor` | `(floor 2.9)` | 小さい側の整数へ | `2.0` |
| `ceiling` | `(ceiling 2.1)` | 大きい側の整数へ | `3.0` |
| `truncate` | `(truncate -2.9)` | 0方向へ切り捨て | `-2.0` |

### すぐ使える例

```racket
(round 2.6)     ; 3.0
(floor 2.9)     ; 2.0
(ceiling 2.1)   ; 3.0
(truncate -2.9) ; -2.0
```

</details>

---

# 4. 商・余り・整数処理

<details open>
<summary><strong>4.1 商・余り・最大公約数</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `quotient` | `(quotient 17 5)` | 整数の商 | `3` |
| `remainder` | `(remainder 17 5)` | 余り | `2` |
| `modulo` | `(modulo 17 5)` | 法に基づく余り | `2` |
| `gcd` | `(gcd 12 18)` | 最大公約数 | `6` |
| `lcm` | `(lcm 12 18)` | 最小公倍数 | `36` |

### すぐ使える例

```racket
(quotient 17 5)   ; 3
(remainder 17 5)  ; 2
(modulo 17 5)     ; 2
(gcd 24 36)       ; 12
(lcm 6 8)         ; 24
```

### メモ

最大公約数の自作では `remainder` がよく出る。

```racket
(define (my-gcd a b)
  (if (= b 0)
      a
      (my-gcd b (remainder a b))))
```

</details>
<details open>
<summary><strong>4.2 整数・偶数・奇数の判定</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `integer?` | `(integer? 3)` | 整数か | `#t` |
| `exact-integer?` | `(exact-integer? 3)` | 正確な整数か | `#t` |
| `even?` | `(even? 10)` | 偶数か | `#t` |
| `odd?` | `(odd? 11)` | 奇数か | `#t` |
| `zero?` | `(zero? 0)` | 0か | `#t` |

### すぐ使える例

```racket
(integer? 3)       ; #t
(integer? 3.5)     ; #f
(even? 10)         ; #t
(odd? 10)          ; #f
(zero? 0)          ; #t
```

</details>

---

# 5. 数値比較・数値述語

<details open>
<summary><strong>5.1 比較</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `=` | `(= 3 3)` | 数値として等しいか | 数値用 |
| `<` | `(< 1 2 3)` | 左から順に小さいか | `#t` |
| `<=` | `(<= 1 1 3)` | 左から順に小さいまたは等しいか | `#t` |
| `>` | `(> 5 3 1)` | 左から順に大きいか | `#t` |
| `>=` | `(>= 5 5 1)` | 左から順に大きいまたは等しいか | `#t` |

### すぐ使える例

```racket
(= 3 3)       ; #t
(< 1 2 3)     ; #t
(< 1 3 2)     ; #f
(<= 1 1 3)    ; #t
(> 5 3 1)     ; #t
```

### メモ

Racketでは `(x < 4)` ではなく `(< x 4)` と書く。

</details>
<details open>
<summary><strong>5.2 数値の性質を調べる</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `number?` | `(number? 42)` | 数値か | `#t` |
| `real?` | `(real? 3.14)` | 実数か | `#t` |
| `rational?` | `(rational? 1/3)` | 有理数か | `#t` |
| `positive?` | `(positive? 5)` | 正の数か | `#t` |
| `negative?` | `(negative? -2)` | 負の数か | `#t` |
| `inexact?` | `(inexact? 1.0)` | 不正確数か | `#t` |
| `exact?` | `(exact? 1/3)` | 正確数か | `#t` |

### すぐ使える例

```racket
(number? 42)     ; #t
(real? 3.14)     ; #t
(rational? 1/3)  ; #t
(positive? 5)    ; #t
(negative? -2)   ; #t
(exact? 1/3)     ; #t
(inexact? 1.0)   ; #t
```

</details>

---

# 6. 条件分岐・真偽値

<details open>
<summary><strong>6.1 if / cond</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `if` | `(if 条件 真のとき 偽のとき)` | 2分岐 | 条件式 |
| `cond` | `(cond [条件1 式1] [else 式2])` | 複数分岐 | 条件式 |
| `else` | `else` | `cond` の最後の条件 | 最後に置く |

### すぐ使える例

```racket
(if (> 5 3)
    "yes"
    "no")

(define (sign x)
  (cond ((> x 0) 'positive)
        ((= x 0) 'zero)
        (else 'negative)))
```

### メモ

`if` と `cond` は、条件によって評価する式を選ぶ特殊形式である。

</details>
<details open>
<summary><strong>6.2 and / or / not</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `and` | `(and 条件1 条件2 ...)` | 全部真なら真 | 途中で偽なら止まる |
| `or` | `(or 条件1 条件2 ...)` | どれか真なら真 | 途中で真なら止まる |
| `not` | `(not 値)` | 真偽を反転 | `#f` 以外は真扱い |
| `boolean?` | `(boolean? #t)` | 真偽値か | `#t` または `#f` |

### すぐ使える例

```racket
(and (> 5 3) (< 5 10)) ; #t
(or (= 1 2) (= 2 2))   ; #t
(not #t)               ; #f
(boolean? #f)          ; #t
```

</details>

---

# 7. define・lambda・局所変数

<details open>
<summary><strong>7.1 define</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `define` | `(define x 10)` | 名前に値をつける | 変数定義 |
| `define` | `(define (f x) 本体)` | 手続きを定義する | 関数定義 |

### すぐ使える例

```racket
(define pi 3.14159)

(define (square x)
  (* x x))
```

### メモ

`define` は「新しく名前を定義する」ものとして考える。既存の値を書き換える `set!` とは区別する。

</details>
<details open>
<summary><strong>7.2 lambda</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `lambda` | `(lambda (x) (+ x 1))` | 名前なし手続きを作る | 高階手続きで重要 |
| `procedure?` | `(procedure? add1)` | 手続きかどうか調べる | `#t` |
| `apply` | `(apply + '(1 2 3))` | リストの中身を引数として渡す | `6` |

### すぐ使える例

```racket
((lambda (x) (+ x 1)) 5) ; 6

(map (lambda (x) (* x x))
     '(1 2 3 4))
; '(1 4 9 16)

(apply + '(1 2 3 4))
; 10
```

### メモ

`lambda` は手続きを作るだけであり、実行するには引数を渡す必要がある。

</details>
<details open>
<summary><strong>7.3 let / let* / letrec</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `let` | `(let ((x 1) (y 2)) (+ x y))` | 局所変数を作る | 同時に束縛 |
| `let*` | `(let* ((x 1) (y (+ x 1))) y)` | 前の束縛を次で使える | 順番に束縛 |
| `letrec` | `(letrec ((f ...)) ...)` | 再帰的な局所定義に使う | 発展 |

### すぐ使える例

```racket
(let ((x 3)
      (y 4))
  (+ (* x x) (* y y)))
; 25

(let* ((x 3)
       (y (+ x 1)))
  (* x y))
; 12
```

### メモ

`let` は `lambda` の構文糖衣として説明できる。

```racket
(let ((x 3))
  (+ x 1))

((lambda (x) (+ x 1)) 3)
```

</details>

---

# 8. ペア・リストの基本

<details open>
<summary><strong>8.1 リスト作成</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `list` | `(list 1 2 3)` | リストを作る | `'(1 2 3)` |
| `quote` | `'(1 2 3)` | 評価せずデータとして扱う | 引用 |
| `cons` | `(cons 1 '(2 3))` | 先頭に要素をつける | `'(1 2 3)` |
| `append` | `(append '(1 2) '(3 4))` | リストを連結する | `'(1 2 3 4)` |

### すぐ使える例

```racket
(list 1 2 3)          ; '(1 2 3)
'(1 2 3)              ; '(1 2 3)
(cons 1 '(2 3))       ; '(1 2 3)
(append '(1 2) '(3))  ; '(1 2 3)
(cons 1 2)            ; '(1 . 2)
```

### メモ

SICPでは `cons` / `car` / `cdr` がデータ抽象の基本になる。

</details>
<details open>
<summary><strong>8.2 car / cdr / first / rest</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `car` | `(car '(10 20 30))` | 先頭要素 | `10` |
| `cdr` | `(cdr '(10 20 30))` | 先頭以外 | `'(20 30)` |
| `first` | `(first '(10 20 30))` | 先頭要素 | `10` |
| `rest` | `(rest '(10 20 30))` | 先頭以外 | `'(20 30)` |
| `second` | `(second '(10 20 30))` | 2番目 | `20` |
| `third` | `(third '(10 20 30))` | 3番目 | `30` |

### すぐ使える例

```racket
(car '(10 20 30))    ; 10
(cdr '(10 20 30))    ; '(20 30)
(first '(10 20 30))  ; 10
(rest '(10 20 30))   ; '(20 30)
(second '(10 20 30)) ; 20
```

</details>
<details open>
<summary><strong>8.3 リスト判定・参照</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `null?` | `(null? '())` | 空リストか | `#t` |
| `empty?` | `(empty? '())` | 空リストか | `#t` |
| `pair?` | `(pair? '(1 2))` | ペアか | `#t` |
| `list?` | `(list? '(1 2 3))` | リストか | `#t` |
| `length` | `(length '(a b c))` | 要素数 | `3` |
| `list-ref` | `(list-ref '(a b c) 1)` | 指定位置の要素 | `b` |
| `take` | `(take '(1 2 3 4) 2)` | 先頭からn個 | `'(1 2)` |
| `drop` | `(drop '(1 2 3 4) 2)` | 先頭からn個を捨てる | `'(3 4)` |

### すぐ使える例

```racket
(null? '())       ; #t
(pair? '(1 2))    ; #t
(list? '(1 2 3))  ; #t
(length '(a b c)) ; 3
(list-ref '(a b c) 0) ; 'a
(take '(1 2 3 4) 2)   ; '(1 2)
(drop '(1 2 3 4) 2)   ; '(3 4)
```

### メモ

`list-ref` の添字は 0 から始まる。

</details>

---

# 9. リスト処理・高階手続き

<details open>
<summary><strong>9.1 map / filter / remove</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `map` | `(map add1 '(1 2 3))` | 各要素に手続きを適用 | `'(2 3 4)` |
| `filter` | `(filter even? '(1 2 3 4))` | 条件を満たす要素だけ残す | `'(2 4)` |
| `remove` | `(remove 2 '(1 2 3 2))` | 最初に見つかった要素を除く | `'(1 3 2)` |
| `remove*` | `(remove* '(2 3) '(1 2 3 4))` | 指定した複数要素を除く | `'(1 4)` |

### すぐ使える例

```racket
(map add1 '(1 2 3))                 ; '(2 3 4)
(map (lambda (x) (* x x)) '(1 2 3)) ; '(1 4 9)
(filter even? '(1 2 3 4))           ; '(2 4)
(remove 2 '(1 2 3 2))               ; '(1 3 2)
```

### メモ

`map` や `filter` には、値ではなく手続きを渡す。

</details>
<details open>
<summary><strong>9.2 foldr / foldl</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `foldr` | `(foldr + 0 '(1 2 3))` | 右からたたみ込む | `6` |
| `foldl` | `(foldl + 0 '(1 2 3))` | 左からたたみ込む | `6` |
| `andmap` | `(andmap positive? '(1 2 3))` | 全要素が条件を満たすか | `#t` |
| `ormap` | `(ormap negative? '(1 -2 3))` | どれかが条件を満たすか | `#t` |

### すぐ使える例

```racket
(foldr + 0 '(1 2 3 4)) ; 10
(foldl + 0 '(1 2 3 4)) ; 10
(foldr cons '() '(1 2 3)) ; '(1 2 3)
(andmap positive? '(1 2 3)) ; #t
(ormap negative? '(1 -2 3)) ; #t
```

### メモ

`foldr` / `foldl` は SICP の `accumulate` に近い考え方である。

</details>
<details open>
<summary><strong>9.3 探索・並べ替え・生成</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `member` | `(member 2 '(1 2 3))` | 見つかった位置以降のリストを返す | なければ `#f` |
| `reverse` | `(reverse '(1 2 3))` | 逆順にする | `'(3 2 1)` |
| `sort` | `(sort '(3 1 2) <)` | 並び替える | `'(1 2 3)` |
| `range` | `(range 5)` | 0から4のリスト | `'(0 1 2 3 4)` |
| `build-list` | `(build-list 5 add1)` | 添字からリストを作る | `'(1 2 3 4 5)` |

### すぐ使える例

```racket
(member 2 '(1 2 3 4)) ; '(2 3 4)
(member 9 '(1 2 3 4)) ; #f
(reverse '(1 2 3))    ; '(3 2 1)
(sort '(3 1 2) <)     ; '(1 2 3)
(range 5)             ; '(0 1 2 3 4)
(build-list 5 add1)   ; '(1 2 3 4 5)
```

### メモ

`member` は `#t` ではなく、見つかった位置以降のリストを返す。ただし `#f` 以外は真として扱われるため、条件式で使える。

</details>

---

# 10. 文字列

<details open>
<summary><strong>10.1 文字列の基本</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `string?` | `(string? "abc")` | 文字列か | `#t` |
| `string-length` | `(string-length "Apple")` | 文字数 | `5` |
| `string-append` | `(string-append "ab" "cd")` | 文字列連結 | `"abcd"` |
| `substring` | `(substring "Apple" 1 3)` | 部分文字列 | `"pp"` |
| `string-ref` | `(string-ref "abc" 0)` | 指定位置の文字 | `#\a` |
| `string->list` | `(string->list "abc")` | 文字リストへ | `'(#\a #\b #\c)` |
| `list->string` | `(list->string '(#\a #\b))` | 文字列へ | `"ab"` |

### すぐ使える例

```racket
(string? "abc")                 ; #t
(string-length "Apple")         ; 5
(string-append "ab" "cd")       ; "abcd"
(substring "Apple" 1 3)         ; "pp"
(string-ref "abc" 0)            ; #\a
(string->list "abc")            ; '(#\a #\b #\c)
```

### メモ

`substring` の終わり位置は含まれない。

</details>
<details open>
<summary><strong>10.2 文字列比較・変換</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `string=?` | `(string=? "abc" "abc")` | 文字列が等しいか | `#t` |
| `string<?` | `(string<? "abc" "bcd")` | 辞書順で小さいか | `#t` |
| `string-upcase` | `(string-upcase "abc")` | 大文字化 | `"ABC"` |
| `string-downcase` | `(string-downcase "ABC")` | 小文字化 | `"abc"` |
| `number->string` | `(number->string 123)` | 数値から文字列 | `"123"` |
| `string->number` | `(string->number "123")` | 文字列から数値 | `123` |

### すぐ使える例

```racket
(string=? "abc" "abc")  ; #t
(string<? "abc" "bcd")  ; #t
(string-upcase "abc")   ; "ABC"
(string-downcase "ABC") ; "abc"
(number->string 123)    ; "123"
(string->number "123")  ; 123
```

</details>

---

# 11. 文字・記号

<details open>
<summary><strong>11.1 文字</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `char?` | `(char? #\a)` | 文字か | `#t` |
| `char=?` | `(char=? #\a #\a)` | 文字が等しいか | `#t` |
| `char<?` | `(char<? #\a #\b)` | 文字の順序比較 | `#t` |
| `char->integer` | `(char->integer #\A)` | 文字コードへ | `65` |
| `integer->char` | `(integer->char 65)` | 文字コードから文字へ | `#\A` |

### すぐ使える例

```racket
(char? #\a)             ; #t
(char=? #\a #\a)        ; #t
(char<? #\a #\b)        ; #t
(char->integer #\A)     ; 65
(integer->char 65)      ; #\A
```

</details>
<details open>
<summary><strong>11.2 記号</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `symbol?` | `(symbol? 'apple)` | 記号か | `#t` |
| `symbol->string` | `(symbol->string 'apple)` | 記号から文字列へ | `"apple"` |
| `string->symbol` | `(string->symbol "apple")` | 文字列から記号へ | `'apple` |
| `quote` | `'apple` | 評価せず記号として扱う | データ化 |

### すぐ使える例

```racket
(symbol? 'apple)             ; #t
(symbol->string 'apple)      ; "apple"
(string->symbol "apple")     ; 'apple
```

### メモ

`apple` は変数名として評価されるが、`'apple` は記号そのものとして扱われる。

</details>

---

# 12. ベクタ

<details open>
<summary><strong>12.1 ベクタの基本</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `vector` | `(vector 1 2 3)` | ベクタを作る | `#(1 2 3)` |
| `vector?` | `(vector? #(1 2 3))` | ベクタか | `#t` |
| `vector-length` | `(vector-length #(1 2 3))` | 長さ | `3` |
| `vector-ref` | `(vector-ref #(10 20 30) 1)` | 指定位置の要素 | `20` |
| `vector-set!` | `(vector-set! v 0 99)` | 指定位置を書き換える | 副作用あり |
| `list->vector` | `(list->vector '(1 2 3))` | リストからベクタ | `#(1 2 3)` |
| `vector->list` | `(vector->list #(1 2 3))` | ベクタからリスト | `'(1 2 3)` |

### すぐ使える例

```racket
(define v (vector 10 20 30))
(vector-ref v 1)   ; 20
(vector-set! v 1 99)
v                  ; '#(10 99 30)
```

### メモ

リストは再帰処理と相性がよく、ベクタは番号で要素にアクセスしやすい。`vector-set!` は破壊的変更である。

</details>

---

# 13. ハッシュ表

<details open>
<summary><strong>13.1 ハッシュ表の基本</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `hash` | `(hash 'a 1 'b 2)` | 不変ハッシュを作る | 辞書 |
| `make-hash` | `(make-hash)` | 可変ハッシュを作る | 副作用あり |
| `hash-ref` | `(hash-ref h 'a)` | キーの値を取り出す | 見つからないとエラー |
| `hash-set` | `(hash-set h 'c 3)` | 不変ハッシュに追加した新しい表を返す | 元は変えない |
| `hash-set!` | `(hash-set! h 'c 3)` | 可変ハッシュを書き換える | 副作用あり |
| `hash-has-key?` | `(hash-has-key? h 'a)` | キーがあるか | `#t` / `#f` |

### すぐ使える例

```racket
(define h (hash 'apple 100 'banana 200))
(hash-ref h 'apple)       ; 100
(hash-has-key? h 'banana) ; #t

(define mh (make-hash))
(hash-set! mh 'apple 100)
(hash-ref mh 'apple)      ; 100
```

### メモ

対応表、辞書、メモ化、頻度カウントに使う。

</details>

---

# 14. 等しさの比較

<details open>
<summary><strong>14.1 比較の種類</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `=` | `(= 1 1)` | 数値の比較 | 数値専用 |
| `eq?` | `(eq? 'a 'a)` | 記号などの同一性 | 低レベル寄り |
| `eqv?` | `(eqv? 1 1)` | 数値や文字もある程度比較 | 中間 |
| `equal?` | `(equal? '(1 2) '(1 2))` | リストや文字列など構造の比較 | 迷ったらこれ |
| `string=?` | `(string=? "a" "a")` | 文字列比較 | 文字列専用 |
| `char=?` | `(char=? #\a #\a)` | 文字比較 | 文字専用 |

### すぐ使える例

```racket
(= 3 3)                       ; #t
(eq? 'apple 'apple)           ; #t
(equal? '(1 2) '(1 2))        ; #t
(string=? "abc" "abc")       ; #t
(char=? #\a #\a)              ; #t
```

### メモ

迷ったときは、数値なら `=`、文字列なら `string=?`、リストなど中身を比べたいなら `equal?` を使う。

</details>

---

# 15. 入出力・表示

<details open>
<summary><strong>15.1 表示</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `display` | `(display "hello")` | 見やすく表示 | 引用符なし |
| `newline` | `(newline)` | 改行 | 表示補助 |
| `write` | `(write "hello")` | Racketのデータ表現として表示 | 引用符あり |
| `printf` | `(printf "x=~a\n" x)` | 書式付き表示 | `~a` に値を入れる |

### すぐ使える例

```racket
(display "hello")
(newline)

(define x 10)
(printf "x = ~a
" x)
```

### メモ

`display` は人間向け、`write` はRacketのデータ表現寄りである。

</details>
<details open>
<summary><strong>15.2 入力</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `read` | `(read)` | Racketのデータとして読む | 数値や記号など |
| `read-line` | `(read-line)` | 1行文字列として読む | 文字列入力 |

### すぐ使える例

```racket
(display "名前を入力してください: ")
(define name (read-line))
(printf "こんにちは、~aさん
" name)
```

### メモ

演習課題ではテストコードで手続きを呼び出す形式が多いため、`read-line` を使わない場合も多い。

</details>

---

# 16. 代入・副作用

<details open>
<summary><strong>16.1 set! と破壊的操作</strong></summary>

| 名前 | 書き方 | 処理内容 | 例・注意 |
|---|---|---|---|
| `set!` | `(set! x 10)` | 既存の変数の値を書き換える | 副作用 |
| `set-car!` | `(set-car! p 10)` | ペアのcarを書き換える | ミュータブルペアで使用 |
| `set-cdr!` | `(set-cdr! p '(2 3))` | ペアのcdrを書き換える | ミュータブルペアで使用 |
| `vector-set!` | `(vector-set! v 0 99)` | ベクタ要素を書き換える | 副作用 |
| `hash-set!` | `(hash-set! h 'a 1)` | 可変ハッシュを書き換える | 副作用 |

### すぐ使える例

```racket
(define x 3)
(set! x 5)
x ; 5
```

### メモ

SICP前半やプログラミングBの初期では、できるだけ `set!` を使わず、再帰や引数で状態を表すことが多い。

</details>

---

# 17. プログラミングBで特に重要なもの

<details open>
<summary><strong>17.1 最優先で覚えるもの</strong></summary>

| 分類 | 覚えるもの |
|---|---|
| 数値 | `+`, `-`, `*`, `/`, `abs`, `max`, `min`, `expt`, `sqrt` |
| 比較 | `=`, `<`, `<=`, `>`, `>=` |
| 条件 | `if`, `cond`, `and`, `or`, `not` |
| 定義 | `define`, `lambda`, `let` |
| 再帰 | `if`, `cond`, `zero?`, `sub1`, `remainder` |
| リスト | `cons`, `car`, `cdr`, `null?`, `pair?`, `list` |
| 高階手続き | `map`, `filter`, `foldr`, `foldl`, `apply` |
| データ判定 | `number?`, `list?`, `pair?`, `procedure?`, `symbol?` |

</details>

<details>
<summary><strong>17.2 課題の型との対応</strong></summary>

| 問題の型 | よく使う手続き |
|---|---|
| 条件分岐で数学的定義を実装 | `if`, `cond`, `<`, `=`, `>` |
| 再帰プロセス | `if`, `cond`, `sub1`, `zero?` |
| 反復プロセス | 内部定義、補助手続き、カウンタ |
| 木構造再帰 | `pair?`, `null?`, `car`, `cdr` |
| sum / product 型 | `+`, `*`, `lambda`, `inc` |
| accumulate 型 | `foldr`, `foldl`, または自作 `accumulate` |
| 高階手続き型 | `lambda`, `map`, `filter`, `apply` |
| fixed-point 型 | `lambda`, `close-enough?`, 平均緩和 |
| データ抽象型 | `cons`, `car`, `cdr`, 構成子・選択子 |

</details>

<details>
<summary><strong>17.3 毎回注意するミス</strong></summary>

- Racketでは `(x < 4)` ではなく `(< x 4)` と書く。
- `a + b` ではなく `(+ a b)` と書く。
- `2^3` ではなく `(expt 2 3)` と書く。
- `=` は代入ではなく数値比較である。
- `define` と `set!` を混同しない。
- `if` は条件、真の場合、偽の場合を分けて書く。
- `cond` の各節は `(条件 返す値)` の形にする。
- `map` や `filter` には、値ではなく手続きを渡す。
- `lambda` は手続きを作るだけで、実行するには引数が必要である。
- `fixed-point` には `f(x)=0` ではなく `x=g(x)` の形の `g` を渡す。
- 課題ファイルのテストコードや補助手続きは勝手に変更しない。

</details>

---

# 18. すぐ使える例まとめ

```racket
#lang racket

(+ 1 2 3 4)                ; 10
(max 8 2 15 4)             ; 15
(if (> 5 3) "yes" "no")    ; "yes"
(list 1 2 3)               ; '(1 2 3)
(car '(10 20 30))          ; 10
(cdr '(10 20 30))          ; '(20 30)
(map add1 '(1 2 3))        ; '(2 3 4)
(filter even? '(1 2 3 4))  ; '(2 4)
(apply + '(1 2 3 4))       ; 10
(expt 2 10)                ; 1024
(sqrt 16)                  ; 4
(remainder 17 5)           ; 2
(member 2 '(1 2 3 4))      ; '(2 3 4)
(string-append "ab" "cd") ; "abcd"
(equal? '(1 2) '(1 2))     ; #t
```

---

# 19. 元ファイルからの主な変更点

- `.txt` から `.md` に変換した。
- Markdownの見出しと目次を追加した。
- `<details>` トグル形式にして、NotionやMarkdownビューアで読みやすくした。
- 数値、条件分岐、リスト、文字列に加えて、指数、余り、lambda、let、fold、文字、記号、ベクタ、ハッシュ表、比較、入出力、副作用を追加した。
- プログラミングBでの「問題の型」と対応させた。
- すぐ使える例を増やした。
