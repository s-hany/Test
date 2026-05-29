#lang racket

#|
ex-review-06：ex14対策 リスト処理・木構造再帰ミックス

この問題では、コードを書く前に必ず次をメモすること。

問題の型：
作る手続き：last-pair,reverse,first-denomination,except-first-denomination,no-more?,same-parity,square-list,square-list2,my-for-each,pick-seven-1, pick-seven-2,
pick-seven-3,deep-reverse,fringe
引数：1.items,2.items,3.coin-values,4.first,rest, 5.items, 6.proc,items,7.3つのリスト, 8.items, 9.tree
返り値：時間の関係上割愛
使うべき既存手続き：時間の関係上割愛
変更してはいけない場所：問題文とソースコード
テストでどう呼ばれるか：
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



今回は ex14 の前半対策として、以下をまとめて練習する。
- last-pair 型
- reverse 型
- リストを使う両替問題のセレクタ型
- same-parity 型
- map 型
- for-each 型
- car / cdr の組み合わせ型
- deep-reverse 型
- fringe 型

模範解答は自分で解いたあとに確認すること。
|#


;; ============================================================
;; 問 1. last-pair
;; ============================================================
#|
空でないリスト items を受け取り、最後の要素だけを含むリストを返す
last-pair を定義せよ。

例：
(last-pair (list 23 72 149 34)) は (list 34) を返す。

ヒント：
最後のペアは、(cdr items) が空リストになる場所である。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (last-pair items)
  (if (null? (cdr items))
      items
      (last-pair (cdr items))))

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 問 2. reverse
;; ============================================================
#|
リスト items を受け取り、要素の順番を逆にしたリストを返す
reverse を定義せよ。

例：
(reverse (list 1 4 9 16 25)) は (list 25 16 9 4 1) を返す。

ヒント：
(cdr items) を先に reverse し、(car items) を最後に付ける。
append を使ってよい。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (reverse items)
  (if (null?)
      '()
      (append (reverse (cdr items))
              (list (car items)))))

;; ===================== 解答コード記入箇所 ここまで =====================


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

これは cons / car / cdr / null? のセレクタ型である。
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

;; ===================== 解答コード記入箇所 ここから =====================

(define (first-denomination coin-values)
  (car coin-values))

(define (except-first-denomination coin-values)
  (cdr coin-values))

(define (no-more? coin-values)
  (null? coin-values))

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 問 4. same-parity
;; ============================================================
#|
最初の引数 first と、残りの引数 rest を受け取り、
first と偶奇が同じ数だけをリストとして返す same-parity を定義せよ。

例：
(same-parity 1 2 3 4 5 6 7) は (list 1 3 5 7)
(same-parity 2 3 4 5 6 7) は (list 2 4 6)

ヒント：
可変長引数は次の形で受け取れる。

(define (same-parity first . rest)
...)

first は数値、rest は残りの数値のリストである。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (same-parity first . rest)
  (???))

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 問 5. square-list / square-list2
;; ============================================================
#|
リスト items を受け取り、各要素を二乗したリストを返す
square-list と square-list2 を定義せよ。

square-list は再帰で定義すること。
square-list2 は map を用いて定義すること。
|#

(define (square x)
  (* x x))

;; ===================== 解答コード記入箇所 ここから =====================

(define (square-list items)
  (???))

(define (square-list2 items)
  (???))

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 問 6. my-for-each
;; ============================================================
#|
手続き proc とリスト items を受け取り、items の各要素に proc を適用する
my-for-each を定義せよ。

返り値は重要ではない。
ただし、items が空になったら停止すること。

例：
(my-for-each display (list 1 2 3))
は、1, 2, 3 を順に表示する。

本番の ex14-6 では名前が for-each になっているが、
ここでは Racket の組み込み手続きとの混同を避けるため my-for-each とする。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (my-for-each proc items)
  (???))

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 問 7. car / cdr の組み合わせ
;; ============================================================
#|
次の3つのリストから 7 を取り出す手続き pick-seven-1, pick-seven-2,
pick-seven-3 を定義せよ。

使ってよいのは car, cdr, cadr, caddr, caar などの組み合わせである。
|#

(define nested1 (list (list 1 3 (list 5 7) 9)))
(define nested2 (list (list 7)))
(define nested3 (list 1 (list 2 (list 3 (list 4 (list 5 (list 6 7)))))))

;; ===================== 解答コード記入箇所 ここから =====================

(define (pick-seven-1 l)
  (???))

(define (pick-seven-2 l)
  (???))

(define (pick-seven-3 l)
  (???))

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 問 8. deep-reverse
;; ============================================================
#|
リスト items を受け取り、リスト全体の順番を逆にするだけでなく、
入れ子になったリストの中も再帰的に逆順にする deep-reverse を定義せよ。

例：
(deep-reverse (list (list 1 2) (list 3 4)))
は (list (list 4 3) (list 2 1)) を返す。

ヒント：
要素がペアなら deep-reverse を再帰的に適用する。
要素がペアでないなら、そのまま返す。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (deep-reverse items)
  (???))

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 問 9. fringe
;; ============================================================
#|
木 tree を受け取り、葉だけを左から右へ並べたリストを返す fringe を定義せよ。

例：
(fringe (list (list 1 2) (list 3 4)))
は (list 1 2 3 4) を返す。

ヒント：
空リストなら空リスト。
ペアでないなら、その値だけを含むリスト。
ペアなら car 側の fringe と cdr 側の fringe を append する。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (fringe tree)
  (???))

;; ===================== 解答コード記入箇所 ここまで =====================


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

