#lang racket

#|
ex-review-07：練習問題 2.75 対策 メッセージパッシング型

この問題では、コードを書く前に必ず次をメモすること。

問題の型：
- メッセージパッシング型
- データを cons ではなく「メッセージを受け取る手続き」として表す型
- 手続きを返す手続き型

作る手続き：
- make-from-mag-ang

引数：
- r : 複素数の大きさ magnitude
- a : 複素数の偏角 angle

返り値：
- op というメッセージを受け取り、対応する値を返す dispatch 手続き

使うべき既存手続き：
- cos
- sin
- eq?
- cond
- error

変更してはいけない場所：
- apply-generic
- real-part
- imag-part
- magnitude
- angle
- テストコード

テストでどう呼ばれるか：
(close-enough? (real-part z1) 2)
(close-enough? (imag-part z1) 0)
(close-enough? (magnitude z1) 2)
(close-enough? (angle z1) 0)

(close-enough? (real-part z2) 3)
(close-enough? (imag-part z2) 4)
(close-enough? (magnitude z2) 5)
(close-enough? (angle z2) (atan 4 3))

今回のポイント：
make-from-mag-ang は、ペアやリストを返すのではなく、
dispatch という手続きを返す。

つまり、作られた複素数 z は、次のようにメッセージを受け取って答える。
(z 'real-part)
(z 'imag-part)
(z 'magnitude)
(z 'angle)

模範解答は自分で解いたあとに確認すること。
|#


;; ============================================================
;; 補助手続き
;; ============================================================

(define tolerance 0.00001)

(define (close-enough? x y)
  (< (abs (- x y)) tolerance))


;; ============================================================
;; メッセージパッシング用の共通セレクタ
;; ここは変更しないこと
;; ============================================================
#|
apply-generic は、op というメッセージをデータに送る手続きである。

この問題では、複素数 z は普通のペアではなく、
メッセージを受け取る手続きとして表される。

したがって、
(real-part z)
は内部的には
(z 'real-part)
のように評価される。
|#

(define (apply-generic op arg)
  (arg op))

(define (real-part z)
  (apply-generic 'real-part z))

(define (imag-part z)
  (apply-generic 'imag-part z))

(define (magnitude z)
  (apply-generic 'magnitude z))

(define (angle z)
  (apply-generic 'angle z))


;; ============================================================
;; 問 1. 練習問題 2.75 make-from-mag-ang
;; ============================================================
#|
練習問題 2.75

メッセージパッシング形式で、make-from-mag-ang を定義せよ。

make-from-mag-ang は、複素数を極形式で作るコンストラクタである。
極形式では、複素数を次の二つで表す。

r : 大きさ magnitude
a : 偏角 angle

このとき、直交形式の実部と虚部は次の式で求められる。

real-part = r cos a
imag-part = r sin a

一方で、magnitude と angle は最初から r と a として与えられているため、
そのまま返せばよい。

メッセージごとの返り値：
'real-part  -> (* r (cos a))
'imag-part  -> (* r (sin a))
'magnitude  -> r
'angle      -> a

問題の型：
- メッセージパッシング型
- cond によるメッセージ分岐型
- 手続きを返す手続き型

注意：
最後に dispatch を返すこと。
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


;; ============================================================
;; テストコード
;; ここは変更しないこと
;; ============================================================

#|
z1 は、大きさ 2、角度 0 の複素数である。

real-part = 2 * cos 0 = 2
imag-part = 2 * sin 0 = 0
magnitude = 2
angle     = 0
|#

(define z1 (make-from-mag-ang 2 0))

(close-enough? (real-part z1) 2)
(close-enough? (imag-part z1) 0)
(close-enough? (magnitude z1) 2)
(close-enough? (angle z1) 0)


#|
z2 は、3 + 4i に対応する複素数である。

3-4-5 の直角三角形を考えると、大きさは 5 である。
角度は (atan 4 3) として作れる。

real-part = 5 * cos(atan 4 3) = 3
imag-part = 5 * sin(atan 4 3) = 4
magnitude = 5
angle     = atan(4, 3)
|#

(define z2 (make-from-mag-ang 5 (atan 4 3)))

(close-enough? (real-part z2) 3)
(close-enough? (imag-part z2) 4)
(close-enough? (magnitude z2) 5)
(close-enough? (angle z2) (atan 4 3))


#|
セレクタを使わず、直接メッセージを送っても同じ値になる。
これは、z2 自体が dispatch 手続きだからである。
|#

(close-enough? (z2 'real-part) 3)
(close-enough? (z2 'imag-part) 4)
(close-enough? (z2 'magnitude) 5)
(close-enough? (z2 'angle) (atan 4 3))


;; ============================================================
;; よくあるミス確認
;; ============================================================
#|
1. dispatch を返し忘れる

悪い例：
(define (make-from-mag-ang r a)
  (define (dispatch op)
    ...))

この形だと、make-from-mag-ang が複素数オブジェクトとして使える手続きを返さない。
正しくは最後に dispatch と書く。


2. クォートを忘れる

悪い例：
(eq? op real-part)

正しい例：
(eq? op 'real-part)

'real-part は変数ではなく、メッセージとして使う記号である。


3. magnitude を計算しようとしてしまう

make-from-mag-ang では r が最初から magnitude なので、そのまま r を返す。

悪い例：
((eq? op 'magnitude)
 (sqrt (+ (square r) (square a))))

これは r と a の意味を取り違えている。
|#
