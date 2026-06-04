#lang racket

#|
ex-review-09：練習問題 2.75 周辺・次回演習予想まとめ

このファイルの目的：
前回の ex14_2 / ex14_3 のような形式で、今回の範囲から出そうな問題を
「問題文メモ → 問題の型 → 解答コード → テストコード」の形でまとめる。

今回の中心：
- 練習問題 2.75：メッセージパッシング形式の make-from-mag-ang
- その周辺：make-from-real-imag / apply-generic / セレクタ / 複素数演算
- 発展：練習問題 2.76 の説明、タグ付きデータ、equ?、=zero?

注意：
- このファイルは「対策用」である。
- 本番の classroom ファイルでは、すでに用意されている手続き名や補助手続きを優先すること。
- 本番では「解答コード記入箇所」の内側だけを貼ること。
- real-part, imag-part, magnitude, angle などの名前は教科書風にしている。

今回の問題の型まとめ：
1. メッセージパッシング型
2. dispatch による cond 分岐型
3. 手続きを返す手続き型
4. 抽象化の壁を作るセレクタ型
5. 複素数演算をセレクタとコンストラクタだけで書く型
6. 2.76 の比較説明型
7. タグ付きデータとジェネリック演算型

最重要暗記ではなく「型」として覚えること：
(define (make-from-mag-ang r a)
  (define (dispatch op)
    (cond ((eq? op 'real-part) (* r (cos a)))
          ((eq? op 'imag-part) (* r (sin a)))
          ((eq? op 'magnitude) r)
          ((eq? op 'angle) a)
          (else (error "Unknown op" op))))
  dispatch)
|#


;; ============================================================
;; 補助手続き
;; ============================================================

(define tolerance 0.00001)

(define (close-enough? x y)
  (< (abs (- x y)) tolerance))

(define (square x)
  (* x x))

(define nil '())


;; ============================================================
;; 問 1. apply-generic を定義する問題
;; ============================================================
#|
出題予想：
メッセージパッシング形式のデータに対して、op というメッセージを送る
apply-generic を定義せよ。

問題文メモ：
複素数 z は cons で作られたペアではなく、メッセージを受け取る手続きである。
したがって、(apply-generic 'real-part z) は、内部では (z 'real-part) を行う。

問題の型：
- メッセージパッシング型
- データが手続きである型

考え方：
op は 'real-part などの記号であり、手続きではない。
arg がメッセージを受け取る手続きなので、(arg op) と書く。

よくあるミス：
(op arg) と書かない。
op は記号なので、手続きとして呼び出せない。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (apply-generic op arg)
  (arg op))

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 問 2. 外側のセレクタを定義する問題
;; ============================================================
#|
出題予想：
real-part, imag-part, magnitude, angle を定義せよ。

問題文メモ：
複素数の利用者は、内部表現を知らずに
(real-part z)
(imag-part z)
(magnitude z)
(angle z)
のように使えるようにする。

問題の型：
- 抽象化の壁を作る問題
- セレクタ型

考え方：
各セレクタは apply-generic に対応するメッセージを渡すだけでよい。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (real-part z)
  (apply-generic 'real-part z))

(define (imag-part z)
  (apply-generic 'imag-part z))

(define (magnitude z)
  (apply-generic 'magnitude z))

(define (angle z)
  (apply-generic 'angle z))

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 問 3. 練習問題 2.75 make-from-mag-ang
;; ============================================================
#|
教科書 練習問題 2.75 ベース

問題文メモ：
メッセージパッシング形式で make-from-mag-ang を定義する。
make-from-real-imag のメッセージパッシング版を参考に、極形式から作る
make-from-mag-ang を完成させる。

問題の型：
- メッセージパッシング型
- dispatch による cond 分岐型
- 手続きを返す手続き型

考え方：
make-from-mag-ang は、大きさ r と偏角 a を受け取る。
極形式では magnitude と angle はそのまま返せる。
real-part と imag-part は三角関数で計算する。

'real-part  -> (* r (cos a))
'imag-part  -> (* r (sin a))
'magnitude  -> r
'angle      -> a

重要：
最後に dispatch を返す。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (make-from-mag-ang r a)
  (define (dispatch op)
    (cond ((eq? op 'real-part)
           (* r (cos a)))
          ((eq? op 'imag-part)
           (* r (sin a)))
          ((eq? op 'magnitude)
           r)
          ((eq? op 'angle)
           a)
          (else
           (error "Unknown op: MAKE-FROM-MAG-ANG" op))))
  dispatch)

;; ===================== 解答コード記入箇所 ここまで =====================


;; テストコード 問 1〜問 3
(define z-mag-1 (make-from-mag-ang 2 0))

(close-enough? (real-part z-mag-1) 2)
(close-enough? (imag-part z-mag-1) 0)
(close-enough? (magnitude z-mag-1) 2)
(close-enough? (angle z-mag-1) 0)

(define z-mag-2 (make-from-mag-ang 5 (atan 4 3)))

(close-enough? (real-part z-mag-2) 3)
(close-enough? (imag-part z-mag-2) 4)
(close-enough? (magnitude z-mag-2) 5)
(close-enough? (angle z-mag-2) (atan 4 3))


;; ============================================================
;; 問 4. make-from-real-imag もメッセージパッシングで定義する問題
;; ============================================================
#|
出題予想：
練習問題 2.75 の逆として、直交形式から複素数を作る make-from-real-imag を
メッセージパッシング形式で定義せよ。

問題文メモ：
直交形式では、実部 x と虚部 y を最初から持っている。
そのため real-part と imag-part はそのまま返せる。
magnitude と angle は計算して返す。

問題の型：
- メッセージパッシング型
- 直交形式のコンストラクタ型

対応：
'real-part  -> x
'imag-part  -> y
'magnitude  -> (sqrt (+ (square x) (square y)))
'angle      -> (atan y x)

よくあるミス：
make-from-mag-ang と返すものが逆になる。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (make-from-real-imag x y)
  (define (dispatch op)
    (cond ((eq? op 'real-part)
           x)
          ((eq? op 'imag-part)
           y)
          ((eq? op 'magnitude)
           (sqrt (+ (square x) (square y))))
          ((eq? op 'angle)
           (atan y x))
          (else
           (error "Unknown op: MAKE-FROM-REAL-IMAG" op))))
  dispatch)

;; ===================== 解答コード記入箇所 ここまで =====================


;; テストコード 問 4
(define z-ri-1 (make-from-real-imag 3 4))

(close-enough? (real-part z-ri-1) 3)
(close-enough? (imag-part z-ri-1) 4)
(close-enough? (magnitude z-ri-1) 5)
(close-enough? (angle z-ri-1) (atan 4 3))

(define z-ri-2 (make-from-real-imag 0 2))

(close-enough? (real-part z-ri-2) 0)
(close-enough? (imag-part z-ri-2) 2)
(close-enough? (magnitude z-ri-2) 2)
(close-enough? (angle z-ri-2) (/ pi 2))


;; ============================================================
;; 問 5. 複素数の足し算・引き算を定義する問題
;; ============================================================
#|
出題予想：
セレクタとコンストラクタを使って、add-complex と sub-complex を定義せよ。

問題文メモ：
複素数の足し算と引き算は、直交形式で考えると簡単である。
実部同士、虚部同士を足す・引く。

問題の型：
- 抽象データを使う演算定義型
- セレクタとコンストラクタだけで書く型

考え方：
z1 = a + bi, z2 = c + di のとき
z1 + z2 = (a+c) + (b+d)i
z1 - z2 = (a-c) + (b-d)i

よくあるミス：
内部表現が手続きなので car / cdr は使わない。
必ず real-part / imag-part を使う。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (add-complex z1 z2)
  (make-from-real-imag
   (+ (real-part z1) (real-part z2))
   (+ (imag-part z1) (imag-part z2))))

(define (sub-complex z1 z2)
  (make-from-real-imag
   (- (real-part z1) (real-part z2))
   (- (imag-part z1) (imag-part z2))))

;; ===================== 解答コード記入箇所 ここまで =====================


;; テストコード 問 5
(define z-add-1 (make-from-real-imag 3 4))
(define z-add-2 (make-from-real-imag 1 2))
(define z-add-result (add-complex z-add-1 z-add-2))
(define z-sub-result (sub-complex z-add-1 z-add-2))

(close-enough? (real-part z-add-result) 4)
(close-enough? (imag-part z-add-result) 6)
(close-enough? (real-part z-sub-result) 2)
(close-enough? (imag-part z-sub-result) 2)


;; ============================================================
;; 問 6. 複素数の掛け算・割り算を定義する問題
;; ============================================================
#|
出題予想：
セレクタとコンストラクタを使って、mul-complex と div-complex を定義せよ。

問題文メモ：
複素数の掛け算と割り算は、極形式で考えると簡単である。
掛け算では大きさを掛け、角度を足す。
割り算では大きさを割り、角度を引く。

問題の型：
- 極形式を使う複素数演算型
- セレクタとコンストラクタだけで書く型

考え方：
掛け算：
magnitude -> (* (magnitude z1) (magnitude z2))
angle     -> (+ (angle z1) (angle z2))

割り算：
magnitude -> (/ (magnitude z1) (magnitude z2))
angle     -> (- (angle z1) (angle z2))
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (mul-complex z1 z2)
  (make-from-mag-ang
   (* (magnitude z1) (magnitude z2))
   (+ (angle z1) (angle z2))))

(define (div-complex z1 z2)
  (make-from-mag-ang
   (/ (magnitude z1) (magnitude z2))
   (- (angle z1) (angle z2))))

;; ===================== 解答コード記入箇所 ここまで =====================


;; テストコード 問 6
(define z-mul-1 (make-from-mag-ang 2 0))
(define z-mul-2 (make-from-mag-ang 3 0))
(define z-mul-result (mul-complex z-mul-1 z-mul-2))
(define z-div-result (div-complex z-mul-result z-mul-2))

(close-enough? (magnitude z-mul-result) 6)
(close-enough? (angle z-mul-result) 0)
(close-enough? (real-part z-mul-result) 6)
(close-enough? (imag-part z-mul-result) 0)

(close-enough? (magnitude z-div-result) 2)
(close-enough? (angle z-div-result) 0)


;; ============================================================
;; 問 7. dispatch に新しいメッセージを追加する問題
;; ============================================================
#|
出題予想：
make-from-mag-ang を少し改造し、新しいメッセージに対応させよ。

例：
'square-magnitude なら大きさの二乗を返す。
'conjugate なら共役複素数を返す。

問題の型：
- dispatch へのメッセージ追加型
- cond の分岐追加型

注意：
本番で元の make-from-mag-ang を書き換える形で出たら、cond に1行追加する。
このファイルでは名前の重複を避けるため make-from-mag-ang/extra としている。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (make-from-mag-ang/extra r a)
  (define (dispatch op)
    (cond ((eq? op 'real-part)
           (* r (cos a)))
          ((eq? op 'imag-part)
           (* r (sin a)))
          ((eq? op 'magnitude)
           r)
          ((eq? op 'angle)
           a)
          ((eq? op 'square-magnitude)
           (* r r))
          ((eq? op 'conjugate)
           (make-from-mag-ang/extra r (- a)))
          (else
           (error "Unknown op: MAKE-FROM-MAG-ANG/EXTRA" op))))
  dispatch)

(define (square-magnitude z)
  (apply-generic 'square-magnitude z))

(define (conjugate z)
  (apply-generic 'conjugate z))

;; ===================== 解答コード記入箇所 ここまで =====================


;; テストコード 問 7
(define z-extra (make-from-mag-ang/extra 5 (atan 4 3)))
(define z-extra-conj (conjugate z-extra))

(close-enough? (square-magnitude z-extra) 25)
(close-enough? (real-part z-extra) 3)
(close-enough? (imag-part z-extra) 4)
(close-enough? (real-part z-extra-conj) 3)
(close-enough? (imag-part z-extra-conj) -4)


;; ============================================================
;; 問 8. 練習問題 2.76 の説明問題
;; ============================================================
#|
教科書 練習問題 2.76 ベース

出題予想：
明示的ディスパッチ、データ主導プログラミング、メッセージパッシングを比較せよ。
新しい型を追加する場合、新しい演算を追加する場合、それぞれどの方式が適しているか。

問題の型：
- 比較説明型
- コードではなくコメントで答える型

答案例：

明示的ディスパッチでは、演算を行う手続きの中でデータの型を調べ、
型ごとに条件分岐する。新しい型を追加すると、既存の演算手続きを
修正する必要がある。一方で、新しい演算を追加する場合は、その演算を
行う手続きを新しく定義すればよいので比較的書きやすい。

データ主導プログラミングでは、演算名と型をキーにして表から対応する
手続きを取り出す。put によって表に手続きを登録できるので、新しい型や
新しい演算を既存のコードを大きく書き換えずに追加しやすい。

メッセージパッシングでは、データ自身がメッセージを受け取り、対応する
処理を返す。新しい型を追加する場合は、その型のコンストラクタの中に
新しい dispatch を書けばよいので追加しやすい。一方で、新しい演算を
追加する場合は、すでにある各データの dispatch に新しいメッセージを
追加する必要があるため、やや面倒である。

まとめ：
- 新しい型を追加しやすい：メッセージパッシング、データ主導
- 新しい演算を追加しやすい：データ主導
- 明示的ディスパッチは、型が増えると既存コードの修正が多くなりやすい
|#


;; ============================================================
;; 問 9. メッセージパッシング版 make-point
;; ============================================================
#|
出題予想：
複素数ではなく、点をメッセージパッシングで表す小問。

問題文メモ：
点 p を cons ではなく、メッセージを受け取る手続きとして作る。
(p 'x) で x 座標、(p 'y) で y 座標を返すようにする。

問題の型：
- 2.75 の考え方を別データに応用する型
- メッセージパッシング型

考え方：
2.75 の make-from-mag-ang と同じ形。
メッセージが 'x か 'y かで cond 分岐する。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (make-point-msg x y)
  (define (dispatch op)
    (cond ((eq? op 'x) x)
          ((eq? op 'y) y)
          (else
           (error "Unknown op: MAKE-POINT-MSG" op))))
  dispatch)

(define (x-point-msg p)
  (p 'x))

(define (y-point-msg p)
  (p 'y))

(define (distance-from-origin-msg p)
  (sqrt (+ (square (x-point-msg p))
           (square (y-point-msg p)))))

;; ===================== 解答コード記入箇所 ここまで =====================


;; テストコード 問 9
(define p-msg (make-point-msg 3 4))

(= (x-point-msg p-msg) 3)
(= (y-point-msg p-msg) 4)
(close-enough? (distance-from-origin-msg p-msg) 5)


;; ============================================================
;; 問 10. 練習問題 2.78 type-tag / contents の修正問題
;; ============================================================
#|
教科書 練習問題 2.78 ベース

出題予想：
通常の Scheme の数値は、わざわざ '(scheme-number . 3) のようにタグ付きにせず、
そのまま 3 として扱えるように type-tag, contents, attach-tag を修正せよ。

問題の型：
- タグ付きデータの例外処理型
- number? による場合分け型

注意：
このファイルでは、前半のメッセージパッシング用の apply-generic と区別するため、
名前に 2 をつけている。
本番で apply-generic, type-tag, contents と指定されたら、2 を外して考える。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (attach-tag2 type-tag contents)
  (if (eq? type-tag 'scheme-number)
      contents
      (cons type-tag contents)))

(define (type-tag2 datum)
  (cond ((number? datum) 'scheme-number)
        ((pair? datum) (car datum))
        (else
         (error "Bad tagged datum: TYPE-TAG2" datum))))

(define (contents2 datum)
  (cond ((number? datum) datum)
        ((pair? datum) (cdr datum))
        (else
         (error "Bad tagged datum: CONTENTS2" datum))))

;; ===================== 解答コード記入箇所 ここまで =====================


;; テストコード 問 10
(eq? (type-tag2 3) 'scheme-number)
(= (contents2 3) 3)
(equal? (attach-tag2 'scheme-number 3) 3)
(equal? (attach-tag2 'complex '(3 . 4)) '(complex 3 . 4))
(eq? (type-tag2 (attach-tag2 'complex '(3 . 4))) 'complex)
(equal? (contents2 (attach-tag2 'complex '(3 . 4))) '(3 . 4))


;; ============================================================
;; 問 11. 練習問題 2.79 equ? を追加する問題
;; ============================================================
#|
教科書 練習問題 2.79 ベース

出題予想：
ジェネリックな等価判定 equ? を定義せよ。

問題の型：
- ジェネリック演算追加型
- 型ごとに等価判定を登録する型

このファイルでは、簡易的な表を hash で作って練習する。
本番では get / put がすでに与えられている可能性が高い。
|#

;; 簡易テーブル
(define operation-table2 (make-hash))

(define (put2 op type-list proc)
  (hash-set! operation-table2 (list op type-list) proc))

(define (get2 op type-list)
  (hash-ref operation-table2 (list op type-list) #f))

(define (apply-generic2 op . args)
  (let ((type-tags (map type-tag2 args))
        (contents-list (map contents2 args)))
    (let ((proc (get2 op type-tags)))
      (if proc
          (apply proc contents-list)
          (error "No method for these types: APPLY-GENERIC2"
                 (list op type-tags))))))

;; ===================== 解答コード記入箇所 ここから =====================

(define (equ? x y)
  (apply-generic2 'equ? x y))

(put2 'equ? '(scheme-number scheme-number)
      (lambda (x y) (= x y)))

;; 複素数をタグ付きの直交形式ペアとして扱う簡易版
(define (make-complex-pair x y)
  (attach-tag2 'complex (cons x y)))

(define (real-part-pair z)
  (car z))

(define (imag-part-pair z)
  (cdr z))

(put2 'equ? '(complex complex)
      (lambda (z1 z2)
        (and (= (real-part-pair z1) (real-part-pair z2))
             (= (imag-part-pair z1) (imag-part-pair z2)))))

;; ===================== 解答コード記入箇所 ここまで =====================


;; テストコード 問 11
(equ? 3 3)
(not (equ? 3 4))

(define c-pair-1 (make-complex-pair 3 4))
(define c-pair-2 (make-complex-pair 3 4))
(define c-pair-3 (make-complex-pair 4 3))

(equ? c-pair-1 c-pair-2)
(not (equ? c-pair-1 c-pair-3))


;; ============================================================
;; 問 12. 練習問題 2.80 =zero? を追加する問題
;; ============================================================
#|
教科書 練習問題 2.80 ベース

出題予想：
ジェネリックなゼロ判定 =zero? を定義せよ。

問題の型：
- ジェネリック述語追加型
- 型ごとにゼロの判定方法を登録する型

考え方：
普通の数値なら (= x 0)。
複素数なら実部も虚部も 0 ならゼロ。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (=zero? x)
  (apply-generic2 '=zero? x))

(put2 '=zero? '(scheme-number)
      (lambda (x) (= x 0)))

(put2 '=zero? '(complex)
      (lambda (z)
        (and (= (real-part-pair z) 0)
             (= (imag-part-pair z) 0))))

;; ===================== 解答コード記入箇所 ここまで =====================


;; テストコード 問 12
(=zero? 0)
(not (=zero? 3))

(define c-zero (make-complex-pair 0 0))
(define c-not-zero-1 (make-complex-pair 1 0))
(define c-not-zero-2 (make-complex-pair 0 1))

(=zero? c-zero)
(not (=zero? c-not-zero-1))
(not (=zero? c-not-zero-2))


;; ============================================================
;; 最終確認用：まとめテスト
;; ============================================================
#|
DrRacket でこのファイルを実行したあと、下の式を評価して全部 #t に近い結果が
並ぶか確認する。

注意：
このファイルではテスト式をそのまま並べているので、DrRacket の実行結果欄に
#t がたくさん出ればよい。
|#

(define (all-basic-tests)
  (list
   (close-enough? (real-part z-mag-1) 2)
   (close-enough? (imag-part z-mag-1) 0)
   (close-enough? (magnitude z-mag-1) 2)
   (close-enough? (angle z-mag-1) 0)

   (close-enough? (real-part z-ri-1) 3)
   (close-enough? (imag-part z-ri-1) 4)
   (close-enough? (magnitude z-ri-1) 5)

   (close-enough? (real-part z-add-result) 4)
   (close-enough? (imag-part z-add-result) 6)
   (close-enough? (magnitude z-mul-result) 6)

   (close-enough? (square-magnitude z-extra) 25)
   (= (x-point-msg p-msg) 3)
   (= (y-point-msg p-msg) 4)

   (eq? (type-tag2 3) 'scheme-number)
   (= (contents2 3) 3)
   (equ? 3 3)
   (not (equ? 3 4))
   (=zero? 0)
   (not (=zero? 3))))

(all-basic-tests)


;; ============================================================
;; よくあるミス総まとめ
;; ============================================================
#|
1. dispatch を返し忘れる

ダメ：
(define (make-from-mag-ang r a)
  (define (dispatch op)
    ...))

正しい：
(define (make-from-mag-ang r a)
  (define (dispatch op)
    ...)
  dispatch)

2. メッセージのクォートを忘れる

ダメ：
(eq? op real-part)

正しい：
(eq? op 'real-part)

3. apply-generic の向きを逆にする

ダメ：
(define (apply-generic op arg)
  (op arg))

正しい：
(define (apply-generic op arg)
  (arg op))

4. 直交形式と極形式で返す値を逆にする

make-from-real-imag：
real-part と imag-part はそのまま。
magnitude と angle は計算する。

make-from-mag-ang：
magnitude と angle はそのまま。
real-part と imag-part は計算する。

5. car / cdr を直接使ってしまう

複素数がメッセージパッシングで表されているとき、データはペアではなく手続きである。
そのため、上位の演算 add-complex などでは car / cdr ではなく、
real-part / imag-part / magnitude / angle を使う。

6. Racket の前置記法を忘れる

ダメ：
(r * cos a)

正しい：
(* r (cos a))

7. = は代入ではない

Racket の = は数値比較である。
値に名前をつけるのは define。
|#
