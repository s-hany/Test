#lang racket

#|
ex-review-07：ex16対策 記号微分・集合・ハフマン木・メッセージパッシング

目的：
次回範囲で出やすい問題を、実戦形式で1から書けるようにする。
このファイルは「自力で解く用」なので、解答コード記入箇所は TODO になっている。

出題予想の優先順位：
1. べき乗を含む記号微分（練習問題2.56 / ex16-2）
2. 3項以上の和・積を扱う記号微分（練習問題2.57 / ex16-3）
3. 中置記法の記号微分（練習問題2.58a / ex16-4）
4. 整列集合の adjoin-set / union-set（練習問題2.61, 2.62 / ex16-7, ex16-8）
5. ハフマン木の encode-symbol（練習問題2.68 / ex16-9）
6. ハフマン木の successive-merge（練習問題2.69 / ex16-10）
7. メッセージパッシングによる複素数（練習問題2.75 / ex16-11）

模範解答は、自分で解いたあとに確認すること。
|#

;; ============================================================
;; テスト補助
;; ============================================================

(define (check-equal name thunk expected)
  (with-handlers ([exn:fail?
                   (lambda (e)
                     (displayln (format "~a : ERROR / TODO -> ~a" name (exn-message e))))])
    (let ((got (thunk)))
      (if (equal? got expected)
          (displayln (format "~a : PASS" name))
          (displayln (format "~a : FAIL got=~s expected=~s" name got expected))))))

(define (check-true name thunk)
  (with-handlers ([exn:fail?
                   (lambda (e)
                     (displayln (format "~a : ERROR / TODO -> ~a" name (exn-message e))))])
    (if (thunk)
        (displayln (format "~a : PASS" name))
        (displayln (format "~a : FAIL" name)))))

(define (square x) (* x x))


;; ============================================================
;; 問 1. べき乗を含む記号微分
;; ============================================================
#|
問題の型：記号微分 + コンストラクタ・セレクタ型
対応：教科書 練習問題2.56 / ex16-2

前置記法で表されたべき乗 (** base exponent) を扱えるようにせよ。
例：'(** x 4) は x^4 を表す。

定義するもの：
- p1-exponentiation?
- p1-base
- p1-exponent
- p1-make-exponentiation
- p1-deriv のべき乗部分

ヒント：
(car '(** x 4))   => '**
(cadr '(** x 4))  => 'x
(caddr '(** x 4)) => 4

数学の形：
d(u^n)/dx = n * u^(n-1) * du/dx
|#

(define (p1-variable? x) (symbol? x))
(define (p1-same-variable? v1 v2)
  (and (p1-variable? v1) (p1-variable? v2) (eq? v1 v2)))
(define (p1-=number? exp num)
  (and (number? exp) (= exp num)))

(define (p1-make-sum a1 a2)
  (cond ((p1-=number? a1 0) a2)
        ((p1-=number? a2 0) a1)
        ((and (number? a1) (number? a2)) (+ a1 a2))
        (else (list '+ a1 a2))))

(define (p1-make-product m1 m2)
  (cond ((or (p1-=number? m1 0) (p1-=number? m2 0)) 0)
        ((p1-=number? m1 1) m2)
        ((p1-=number? m2 1) m1)
        ((and (number? m1) (number? m2)) (* m1 m2))
        (else (list '* m1 m2))))

(define (p1-sum? x) (and (pair? x) (eq? (car x) '+)))
(define (p1-addend s) (cadr s))
(define (p1-augend s) (caddr s))
(define (p1-product? x) (and (pair? x) (eq? (car x) '*)))
(define (p1-multiplier p) (cadr p))
(define (p1-multiplicand p) (caddr p))

;; ===================== 解答コード記入箇所 ここから =====================

(define (p1-exponentiation? x)
  (error "TODO: p1-exponentiation?"))

(define (p1-base e)
  (error "TODO: p1-base"))

(define (p1-exponent e)
  (error "TODO: p1-exponent"))

(define (p1-make-exponentiation b e)
  (error "TODO: p1-make-exponentiation"))

;; ===================== 解答コード記入箇所 ここまで =====================

(define (p1-deriv exp var)
  (cond ((number? exp) 0)
        ((p1-variable? exp)
         (if (p1-same-variable? exp var) 1 0))
        ((p1-sum? exp)
         (p1-make-sum (p1-deriv (p1-addend exp) var)
                      (p1-deriv (p1-augend exp) var)))
        ((p1-product? exp)
         (p1-make-sum
          (p1-make-product (p1-multiplier exp)
                           (p1-deriv (p1-multiplicand exp) var))
          (p1-make-product (p1-deriv (p1-multiplier exp) var)
                           (p1-multiplicand exp))))
        ((p1-exponentiation? exp)
         ;; ここも自力で書く練習にしてよい。
         ;; まずは下の TODO を消して、べき乗の微分規則を書け。
         (error "TODO: p1-deriv exponentiation branch"))
        (else (error "unknown expression type -- P1-DERIV" exp))))


;; ============================================================
;; 問 2. 3項以上の和・積を扱う記号微分
;; ============================================================
#|
問題の型：記号微分 + 表現の拡張型
対応：教科書 練習問題2.57 / ex16-3

(+ x (* x y) (* x 3)) のような3項以上の和、
(* x y (+ x 3)) のような3項以上の積を扱えるようにせよ。

書き換える場所：
- p2-augend
- p2-multiplicand

ヒント：
(cddr '(+ x (* x y) (* x 3)))
=> '((* x y) (* x 3))

残りが1個だけならその1個を返す。
残りが2個以上なら、先頭に '+ または '* を付け直して式に戻す。
|#

(define (p2-variable? x) (symbol? x))
(define (p2-same-variable? v1 v2)
  (and (p2-variable? v1) (p2-variable? v2) (eq? v1 v2)))
(define (p2-=number? exp num)
  (and (number? exp) (= exp num)))

(define (p2-make-sum a1 a2)
  (cond ((p2-=number? a1 0) a2)
        ((p2-=number? a2 0) a1)
        ((and (number? a1) (number? a2)) (+ a1 a2))
        (else (list '+ a1 a2))))

(define (p2-make-product m1 m2)
  (cond ((or (p2-=number? m1 0) (p2-=number? m2 0)) 0)
        ((p2-=number? m1 1) m2)
        ((p2-=number? m2 1) m1)
        ((and (number? m1) (number? m2)) (* m1 m2))
        (else (list '* m1 m2))))

(define (p2-sum? x) (and (pair? x) (eq? (car x) '+)))
(define (p2-addend s) (cadr s))

;; ===================== 解答コード記入箇所 ここから =====================

(define (p2-augend s)
  (error "TODO: p2-augend"))

;; ===================== 解答コード記入箇所 ここまで =====================

(define (p2-product? x) (and (pair? x) (eq? (car x) '*)))
(define (p2-multiplier p) (cadr p))

;; ===================== 解答コード記入箇所 ここから =====================

(define (p2-multiplicand p)
  (error "TODO: p2-multiplicand"))

;; ===================== 解答コード記入箇所 ここまで =====================

(define (p2-deriv exp var)
  (cond ((number? exp) 0)
        ((p2-variable? exp)
         (if (p2-same-variable? exp var) 1 0))
        ((p2-sum? exp)
         (p2-make-sum (p2-deriv (p2-addend exp) var)
                      (p2-deriv (p2-augend exp) var)))
        ((p2-product? exp)
         (p2-make-sum
          (p2-make-product (p2-multiplier exp)
                           (p2-deriv (p2-multiplicand exp) var))
          (p2-make-product (p2-deriv (p2-multiplier exp) var)
                           (p2-multiplicand exp))))
        (else (error "unknown expression type -- P2-DERIV" exp))))


;; ============================================================
;; 問 3. 完全括弧つき中置記法の記号微分
;; ============================================================
#|
問題の型：記号微分 + データ表現の変更型
対応：教科書 練習問題2.58a / ex16-4

前置記法ではなく、中置記法で表された式を微分できるようにせよ。
例：
前置記法：'(+ x 3)
中置記法：'(x + 3)

定義するもの：
- p3-sum?
- p3-addend
- p3-augend
- p3-make-sum
- p3-product?
- p3-multiplier
- p3-multiplicand
- p3-make-product

ヒント：
(car '(x + 3))   => 'x
(cadr '(x + 3))  => '+
(caddr '(x + 3)) => 3
|#

(define (p3-variable? x) (symbol? x))
(define (p3-same-variable? v1 v2)
  (and (p3-variable? v1) (p3-variable? v2) (eq? v1 v2)))
(define (p3-=number? exp num)
  (and (number? exp) (= exp num)))

;; ===================== 解答コード記入箇所 ここから =====================

(define (p3-sum? x)
  (error "TODO: p3-sum?"))

(define (p3-addend s)
  (error "TODO: p3-addend"))

(define (p3-augend s)
  (error "TODO: p3-augend"))

(define (p3-make-sum a1 a2)
  (error "TODO: p3-make-sum"))

(define (p3-product? x)
  (error "TODO: p3-product?"))

(define (p3-multiplier p)
  (error "TODO: p3-multiplier"))

(define (p3-multiplicand p)
  (error "TODO: p3-multiplicand"))

(define (p3-make-product m1 m2)
  (error "TODO: p3-make-product"))

;; ===================== 解答コード記入箇所 ここまで =====================

(define (p3-deriv exp var)
  (cond ((number? exp) 0)
        ((p3-variable? exp)
         (if (p3-same-variable? exp var) 1 0))
        ((p3-sum? exp)
         (p3-make-sum (p3-deriv (p3-addend exp) var)
                      (p3-deriv (p3-augend exp) var)))
        ((p3-product? exp)
         (p3-make-sum
          (p3-make-product (p3-multiplier exp)
                           (p3-deriv (p3-multiplicand exp) var))
          (p3-make-product (p3-deriv (p3-multiplier exp) var)
                           (p3-multiplicand exp))))
        (else (error "unknown expression type -- P3-DERIV" exp))))


;; ============================================================
;; 問 4. 整列集合の adjoin-set と union-set
;; ============================================================
#|
問題の型：整列リストで表した集合 + マージ型
対応：教科書 練習問題2.61, 2.62 / ex16-7, ex16-8

小さい順に整列された集合を扱う。
重複は入れない。

p4-adjoin-set：
x を set に加える。ただし整列順を保ち、重複は加えない。

p4-union-set：
2つの整列集合の和集合を、整列されたリストとして返す。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (p4-adjoin-set x set)
  (error "TODO: p4-adjoin-set"))

(define (p4-union-set set1 set2)
  (error "TODO: p4-union-set"))

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 問 5. ハフマン木の encode-symbol
;; ============================================================
#|
問題の型：ハフマン木 + 木構造再帰型
対応：教科書 練習問題2.68 / ex16-9

1つの記号 sym を、ハフマン木 tree に従ってビット列へ変換する
p5-encode-symbol を定義せよ。

ルール：
左の枝に進むなら 0
右の枝に進むなら 1

直接 car / cdr で木を見るより、次の補助手続きを使うこと：
- p5-leaf?
- p5-left-branch
- p5-right-branch
- p5-symbols
|#

(define (p5-make-leaf symbol weight)
  (list 'leaf symbol weight))
(define (p5-leaf? object)
  (eq? (car object) 'leaf))
(define (p5-symbol-leaf x) (cadr x))
(define (p5-weight-leaf x) (caddr x))

(define (p5-make-code-tree left right)
  (list left
        right
        (append (p5-symbols left) (p5-symbols right))
        (+ (p5-weight left) (p5-weight right))))
(define (p5-left-branch tree) (car tree))
(define (p5-right-branch tree) (cadr tree))
(define (p5-symbols tree)
  (if (p5-leaf? tree)
      (list (p5-symbol-leaf tree))
      (caddr tree)))
(define (p5-weight tree)
  (if (p5-leaf? tree)
      (p5-weight-leaf tree)
      (cadddr tree)))

;; ===================== 解答コード記入箇所 ここから =====================

(define (p5-encode-symbol sym tree)
  (error "TODO: p5-encode-symbol"))

;; ===================== 解答コード記入箇所 ここまで =====================

(define (p5-encode message tree)
  (if (null? message)
      '()
      (append (p5-encode-symbol (car message) tree)
              (p5-encode (cdr message) tree))))

(define p5-sample-tree
  (p5-make-code-tree
   (p5-make-leaf 'A 4)
   (p5-make-code-tree
    (p5-make-leaf 'B 2)
    (p5-make-code-tree
     (p5-make-leaf 'D 1)
     (p5-make-leaf 'C 1)))))


;; ============================================================
;; 問 6. ハフマン木の successive-merge
;; ============================================================
#|
問題の型：ハフマン木生成 + 整列集合の反復的再帰型
対応：教科書 練習問題2.69 / ex16-10

重みの小さい順に並んだ葉・木のリスト ordered-trees を受け取り、
先頭2つを make-code-tree で合体し、adjoin-set で戻す。
これを木が1つになるまで繰り返す。
|#

(define (p6-make-leaf symbol weight)
  (list 'leaf symbol weight))
(define (p6-leaf? object)
  (eq? (car object) 'leaf))
(define (p6-symbol-leaf x) (cadr x))
(define (p6-weight-leaf x) (caddr x))
(define (p6-make-code-tree left right)
  (list left
        right
        (append (p6-symbols left) (p6-symbols right))
        (+ (p6-weight left) (p6-weight right))))
(define (p6-left-branch tree) (car tree))
(define (p6-right-branch tree) (cadr tree))
(define (p6-symbols tree)
  (if (p6-leaf? tree)
      (list (p6-symbol-leaf tree))
      (caddr tree)))
(define (p6-weight tree)
  (if (p6-leaf? tree)
      (p6-weight-leaf tree)
      (cadddr tree)))

(define (p6-adjoin-set x set)
  (cond ((null? set) (list x))
        ((< (p6-weight x) (p6-weight (car set))) (cons x set))
        (else (cons (car set)
                    (p6-adjoin-set x (cdr set))))))

(define (p6-make-leaf-set pairs)
  (if (null? pairs)
      '()
      (let ((pair (car pairs)))
        (p6-adjoin-set (p6-make-leaf (car pair) (cadr pair))
                       (p6-make-leaf-set (cdr pairs))))))

;; ===================== 解答コード記入箇所 ここから =====================

(define (p6-successive-merge ordered-trees)
  (error "TODO: p6-successive-merge"))

;; ===================== 解答コード記入箇所 ここまで =====================

(define (p6-generate-huffman-tree pairs)
  (p6-successive-merge (p6-make-leaf-set pairs)))


;; ============================================================
;; 問 7. メッセージパッシングによる複素数
;; ============================================================
#|
問題の型：メッセージパッシング + 複素数のデータ抽象型
対応：教科書 練習問題2.75 / ex16-11

極形式 m, a から複素数を作る p7-make-from-mag-ang を定義せよ。
作られた値は手続きであり、op というメッセージを受け取って値を返す。

op が 'real-part なら m*cos(a)
op が 'imag-part なら m*sin(a)
op が 'magnitude なら m
op が 'angle なら a
|#

(define (p7-apply-generic op arg)
  (arg op))

;; ===================== 解答コード記入箇所 ここから =====================

(define (p7-make-from-mag-ang m a)
  (error "TODO: p7-make-from-mag-ang"))

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; テストコード
;; ここは変更しないこと
;; ============================================================

(displayln "===== 問1：べき乗を含む記号微分 =====")
(check-equal "p1-1" (lambda () (p1-deriv '(** x 4) 'x)) '(* 4 (** x 3)))
(check-equal "p1-2" (lambda () (p1-deriv '(** y 3) 'x)) 0)
(check-equal "p1-3" (lambda () (p1-make-exponentiation 'x 0)) 1)
(check-equal "p1-4" (lambda () (p1-make-exponentiation 'x 1)) 'x)
(check-equal "p1-5" (lambda () (p1-make-exponentiation 2 3)) 8)

(displayln "===== 問2：3項以上の和・積 =====")
(check-equal "p2-1" (lambda () (p2-augend '(+ x (* x y) (* x 3)))) '(+ (* x y) (* x 3)))
(check-equal "p2-2" (lambda () (p2-multiplicand '(* x y (+ x 3)))) '(* y (+ x 3)))
(check-equal "p2-3" (lambda () (p2-deriv '(+ x (* x y) (* x 3)) 'x)) '(+ 1 (+ y 3)))
(check-equal "p2-4" (lambda () (p2-deriv '(* x y (+ x 3)) 'x)) '(+ (* x y) (* y (+ x 3))))

(displayln "===== 問3：中置記法 =====")
(check-equal "p3-1" (lambda () (p3-deriv '(x + 3) 'x)) 1)
(check-equal "p3-2" (lambda () (p3-deriv '(x * y) 'x)) 'y)
(check-equal "p3-3" (lambda () (p3-deriv '((x + (x * y)) + (x * 3)) 'x)) '((1 + y) + 3))
(check-equal "p3-4" (lambda () (p3-deriv '((x * y) * (x + 3)) 'x)) '((x * y) + (y * (x + 3))))

(displayln "===== 問4：整列集合 =====")
(check-equal "p4-1" (lambda () (p4-adjoin-set 0 '(1 3 5 7))) '(0 1 3 5 7))
(check-equal "p4-2" (lambda () (p4-adjoin-set 4 '(1 3 5 7))) '(1 3 4 5 7))
(check-equal "p4-3" (lambda () (p4-adjoin-set 3 '(1 3 5 7))) '(1 3 5 7))
(check-equal "p4-4" (lambda () (p4-union-set '(1 3 5 7) '(2 4 6))) '(1 2 3 4 5 6 7))
(check-equal "p4-5" (lambda () (p4-union-set '(1 2 3) '(1 3 5 7))) '(1 2 3 5 7))

(displayln "===== 問5：encode-symbol =====")
(check-equal "p5-1" (lambda () (p5-encode-symbol 'A p5-sample-tree)) '(0))
(check-equal "p5-2" (lambda () (p5-encode-symbol 'B p5-sample-tree)) '(1 0))
(check-equal "p5-3" (lambda () (p5-encode-symbol 'D p5-sample-tree)) '(1 1 0))
(check-equal "p5-4" (lambda () (p5-encode '(A D A B B C A) p5-sample-tree)) '(0 1 1 0 0 1 0 1 0 1 1 1 0))

(displayln "===== 問6：successive-merge =====")
(define p6-tree1-thunk
  (lambda () (p6-generate-huffman-tree '((A 4) (B 2) (C 1) (D 1)))))
(check-equal "p6-1" (lambda () (p6-weight (p6-tree1-thunk))) 8)
(check-equal "p6-2" (lambda () (p6-symbols (p6-tree1-thunk))) '(A B D C))

(displayln "===== 問7：メッセージパッシング =====")
(define p7-c1-thunk
  (lambda () (p7-make-from-mag-ang 3 (/ 3 4))))
(check-equal "p7-1" (lambda () (p7-apply-generic 'magnitude (p7-c1-thunk))) 3)
(check-equal "p7-2" (lambda () (p7-apply-generic 'angle (p7-c1-thunk))) (/ 3 4))
(check-true "p7-3" (lambda () (< (abs (- (p7-apply-generic 'real-part (p7-c1-thunk))
                                      (* 3 (cos (/ 3 4)))))
                             0.0001)))
(check-true "p7-4" (lambda () (< (abs (- (p7-apply-generic 'imag-part (p7-c1-thunk))
                                      (* 3 (sin (/ 3 4)))))
                             0.0001)))

