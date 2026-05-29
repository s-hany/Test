#lang racket

#|
ex-review-06：ex14対策 リスト処理・木構造再帰ミックス【解答反映版】

このファイルは、前回の ex-review-06-ex14-list.rkt に
模範解答を反映した版である。

対象：
- last-pair 型
- reverse 型
- リストを使う両替問題のセレクタ型
- same-parity 型
- map 型
- for-each 型
- car / cdr の組み合わせ型
- deep-reverse 型
- fringe 型

ポイント：
list は横に進む。
tree は中にもぐる。
|#


;; ============================================================
;; 問 1. last-pair
;; ============================================================
#|
空でないリスト items を受け取り、最後の要素だけを含むリストを返す
last-pair を定義せよ。

問題の型：
リスト再帰型

考え方：
(cdr items) が空なら、今見ている items が最後のペアである。
最後で返すのは (cdr items) ではなく items である。
|#

(define (last-pair items)
  (if (null? (cdr items))
      items
      (last-pair (cdr items))))


;; ============================================================
;; 問 2. reverse
;; ============================================================
#|
リスト items を受け取り、要素の順番を逆にしたリストを返す
reverse を定義せよ。

問題の型：
リスト再帰 + append 型

考え方：
(cdr items) を先に reverse し、(car items) を最後に付ける。
append はリスト同士をつなげるので、(car items) は (list ...) で包む。
|#

(define (reverse items)
  (if (null? items)
      '()
      (append (reverse (cdr items))
              (list (car items)))))


;; ============================================================
;; 問 3. 両替問題のリストセレクタ
;; ============================================================
#|
硬貨の種類 coin-values をリストとして表す。

例：
(list 50 25 10 5 1)

次の3つを定義せよ。

first-denomination：
coin-values の先頭の硬貨を返す。

except-first-denomination：
coin-values から先頭以外の硬貨リストを返す。

no-more?：
coin-values が空なら #t、そうでなければ #f を返す。

問題の型：
cons / car / cdr / null? のセレクタ型
|#

(define us-coins (list 50 25 10 5 1))
(define jp-coins (list 500 100 50 10 5 1))

(define (cc amount coin-values)
  (cond ((= amount 0) 1)
        ((or (< amount 0) (no-more? coin-values)) 0)
        (else
         (+ (cc amount
                (except-first-denomination coin-values))
            (cc (- amount
                   (first-denomination coin-values))
                coin-values)))))

(define (first-denomination coin-values)
  (car coin-values))

(define (except-first-denomination coin-values)
  (cdr coin-values))

(define (no-more? coin-values)
  (null? coin-values))


;; ============================================================
;; 問 4. same-parity
;; ============================================================
#|
最初の引数 first と、残りの引数 rest を受け取り、
first と偶奇が同じ数だけをリストとして返す same-parity を定義せよ。

例：
(same-parity 1 2 3 4 5 6 7) は (list 1 3 5 7)
(same-parity 2 3 4 5 6 7) は (list 2 4 6)

問題の型：
可変長引数 + リスト再帰型

考え方：
(define (same-parity first . rest) ...)
と書くと、first は最初の数値、rest は残りの数値のリストになる。
first は必ず答えに含める。
rest の中から first と偶奇が同じものだけを選ぶ。
|#

(define (same-parity first . rest)
  (define (same-parity? x)
    (= (remainder x 2)
       (remainder first 2)))
  (define (select items)
    (cond ((null? items) '())
          ((same-parity? (car items))
           (cons (car items)
                 (select (cdr items))))
          (else
           (select (cdr items)))))
  (cons first
        (select rest)))


;; ============================================================
;; 問 5. square-list / square-list2
;; ============================================================
#|
リスト items を受け取り、各要素を二乗したリストを返す
square-list と square-list2 を定義せよ。

square-list は再帰で定義すること。
square-list2 は map を用いて定義すること。

問題の型：
リスト再帰型 / map 型
|#

(define (square x)
  (* x x))

(define (square-list items)
  (if (null? items)
      '()
      (cons (square (car items))
            (square-list (cdr items)))))

(define (square-list2 items)
  (map square items))


;; ============================================================
;; 問 6. my-for-each
;; ============================================================
#|
手続き proc とリスト items を受け取り、items の各要素に proc を適用する
my-for-each を定義せよ。

返り値は重要ではない。
ただし、items が空になったら停止すること。

本番の ex14-6 では名前が for-each になっているが、
ここでは Racket の組み込み手続きとの混同を避けるため my-for-each とする。

問題の型：
リストを順に処理する副作用型

考え方：
map は結果のリストを作る。
for-each は表示などの副作用を順に実行する。
begin を使うと、proc の実行後に再帰呼び出しを続けられる。
|#

(define (my-for-each proc items)
  (if (null? items)
      'done
      (begin
        (proc (car items))
        (my-for-each proc (cdr items)))))


;; ============================================================
;; 問 7. car / cdr の組み合わせ
;; ============================================================
#|
次の3つのリストから 7 を取り出す手続き pick-seven-1, pick-seven-2,
pick-seven-3 を定義せよ。

使ってよいのは car, cdr, cadr, caddr, caar などの組み合わせである。

問題の型：
入れ子リストの car / cdr たどり型
|#

(define nested1 (list (list 1 3 (list 5 7) 9)))
(define nested2 (list (list 7)))
(define nested3 (list 1 (list 2 (list 3 (list 4 (list 5 (list 6 7)))))))

(define (pick-seven-1 l)
  (car (cdr (car (cdr (cdr (car l)))))))

(define (pick-seven-2 l)
  (car (car l)))

(define (pick-seven-3 l)
  (cadr (cadr (cadr (cadr (cadr (cadr l)))))))


;; ============================================================
;; 問 8. deep-reverse
;; ============================================================
#|
リスト items を受け取り、リスト全体の順番を逆にするだけでなく、
入れ子になったリストの中も再帰的に逆順にする deep-reverse を定義せよ。

例：
(deep-reverse (list (list 1 2) (list 3 4)))
は (list (list 4 3) (list 2 1)) を返す。

問題の型：
木構造再帰型

考え方：
空なら空リスト。
ペアでないなら葉なので、そのまま返す。
ペアなら、cdr 側を deep-reverse したものの後ろに、
car 側を deep-reverse したものをリストとして付ける。
|#

(define (deep-reverse items)
  (cond ((null? items) '())
        ((not (pair? items)) items)
        (else
         (append (deep-reverse (cdr items))
                 (list (deep-reverse (car items)))))))


;; ============================================================
;; 問 9. fringe
;; ============================================================
#|
木 tree を受け取り、葉だけを左から右へ並べたリストを返す fringe を定義せよ。

例：
(fringe (list (list 1 2) (list 3 4)))
は (list 1 2 3 4) を返す。

問題の型：
木構造再帰 + append 型

考え方：
空リストなら空リスト。
ペアでないなら葉なので、その葉だけを含むリストにする。
ペアなら car 側の fringe と cdr 側の fringe を append する。
|#

(define (fringe tree)
  (cond ((null? tree) '())
        ((not (pair? tree)) (list tree))
        (else
         (append (fringe (car tree))
                 (fringe (cdr tree))))))


;; ============================================================
;; テストコード
;; ここは変更しないこと
;; ============================================================

(equal? (last-pair (list 23 72 149 34)) (list 34))
(equal? (last-pair (list -8)) (list -8))

(define squares (list 1 4 9 16 25))
(define odds (list 1 3 5 7))
(equal? (reverse squares) (list 25 16 9 4 1))
(equal? (reverse odds) (list 7 5 3 1))
(equal? (reverse (reverse squares)) squares)

(equal? (first-denomination us-coins) 50)
(equal? (except-first-denomination us-coins) (list 25 10 5 1))
(no-more? '())
(not (no-more? us-coins))
(= (cc 100 us-coins) 292)
(= (cc 100 jp-coins) 159)

(equal? (same-parity 1 2 3 4 5 6 7) (list 1 3 5 7))
(equal? (same-parity 2 3 4 5 6 7) (list 2 4 6))
(equal? (same-parity 7) (list 7))

(equal? (square-list (list 1 2 3 4)) (list 1 4 9 16))
(equal? (square-list2 (list 1 2 3 4)) (list 1 4 9 16))
(equal? (square-list (list -5 -3 0 2 4)) (list 25 9 0 4 16))
(equal? (square-list2 (list -5 -3 0 2 4)) (list 25 9 0 4 16))

(equal? (with-output-to-string
          (lambda ()
            (my-for-each (lambda (x)
                           (display x)
                           (newline))
                         (list 57 321 88))))
        "57\n321\n88\n")

(equal? (with-output-to-string
          (lambda ()
            (my-for-each (lambda (x)
                           (display (+ x x)))
                         (list 1 2 3 4 5))))
        "246810")

(= (pick-seven-1 nested1) 7)
(= (pick-seven-2 nested2) 7)
(= (pick-seven-3 nested3) 7)

(define x (list (list 1 2) (list 3 4)))
(define y (list 1 (list 2 3 4) (list 5)))

(equal? (deep-reverse x) (list (list 4 3) (list 2 1)))
(equal? (deep-reverse y) (list (list 5) (list 4 3 2) 1))

(equal? (fringe x) (list 1 2 3 4))
(equal? (fringe (list x x)) (list 1 2 3 4 1 2 3 4))
(equal? (fringe y) (list 1 2 3 4 5))
