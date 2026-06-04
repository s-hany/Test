#lang racket

#|
ex-review-08：SICP 練習問題 2.73〜2.80 対策
データ主導プログラミング・メッセージパッシング・ジェネリック演算

このファイルの目的：
- 練習問題 2.75 の発展として、2.73, 2.74, 2.76, 2.77, 2.78, 2.79, 2.80 をまとめて復習する。
- 教科書の問題文をコメントとして入れ、解答コードをその下に置く。
- 2.76 は説明問題なので、コードではなくコメント答案にする。

問題の型：
2.73：データ主導プログラミング型
2.74：データ主導プログラミングの応用型
2.76：設計方針比較型
2.77：ジェネリック演算の二重タグ理解型
2.78：型タグ表現の改良型
2.79：ジェネリック述語追加型
2.80：ジェネリック述語追加型

重要：
この範囲では「データの中身を直接 car/cdr で触る」よりも、
タグ・表・ジェネリック演算・コンストラクタ・セレクタの関係を見る。
|#


;; ============================================================
;; 共通：put / get 用の演算テーブル
;; ============================================================

(define operation-table (make-hash))

(define (put op type-list proc)
  (hash-set! operation-table (list op type-list) proc)
  'ok)

(define (get op type-list)
  (hash-ref operation-table (list op type-list) #f))


;; ============================================================
;; 共通：タグつきデータ
;; 2.78 の解答も兼ねるため、scheme-number は裸の数値として扱う。
;; ============================================================

(define (attach-tag type-tag contents)
  (if (and (eq? type-tag 'scheme-number)
           (number? contents))
      contents
      (cons type-tag contents)))

(define (type-tag datum)
  (cond ((number? datum) 'scheme-number)
        ((pair? datum) (car datum))
        (else (error "Bad tagged datum: TYPE-TAG" datum))))

(define (contents datum)
  (cond ((number? datum) datum)
        ((pair? datum) (cdr datum))
        (else (error "Bad tagged datum: CONTENTS" datum))))


;; ============================================================
;; 簡易テスト表示
;; ============================================================

(define (roughly=? x y)
  (< (abs (- x y)) 0.00001))

(define (check-equal? label actual expected)
  (display label)
  (display " : ")
  (display (equal? actual expected))
  (display "  actual=")
  (write actual)
  (display " expected=")
  (write expected)
  (newline))

(define (check-roughly? label actual expected)
  (display label)
  (display " : ")
  (display (roughly=? actual expected))
  (display "  actual=")
  (write actual)
  (display " expected≈")
  (write expected)
  (newline))


;; ============================================================
;; 練習問題 2.73
;; ============================================================
#|
問題文抜粋：
2.3.2 節では、記号微分を行うプログラムについて説明した。

(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp)
         (if (same-variable? exp var) 1 0))
        ((sum? exp)
         (make-sum (deriv (addend exp) var)
                   (deriv (augend exp) var)))
        ((product? exp)
         (make-sum
          (make-product (multiplier exp)
                        (deriv (multiplicand exp) var))
          (make-product (deriv (multiplier exp) var)
                        (multiplicand exp))))
        <more rules can be added here>
        (else (error "unknown expression type: DERIV" exp))))

このプログラムは、微分する式の型によってディスパッチを実行していると捉えられる。
データ主導スタイルでは次のように書き直せる。

(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp) (if (same-variable? exp var) 1 0))
        (else ((get 'deriv (operator exp))
               (operands exp) var))))
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))

a. 上で何をしているか説明せよ。number? と variable? は、なぜデータ主導
   ディスパッチとして取り込むことができないのだろうか。
b. 和と積に対する微分手続きと、テーブルにそれらを組み込む補助コードを書け。
c. 任意の微分規則を選び、それをこのデータ主導システムに組み込め。
d. get の引数順を ((get (operator exp) 'deriv) ...) にした場合、
   どのような変更が必要か。
|#

#|
問題の型：
データ主導プログラミング型。

考え方：
式 (+ x 3) や (* x y) の car は演算子である。
したがって、式の型を '+ や '* と見て、
(get 'deriv '+) や (get 'deriv '*) で微分規則を表から取り出す。

number? と variable? を表に入れにくい理由：
数値 3 や変数 x は、(+ x 3) のような「演算子を car に持つリスト」ではない。
つまり、operator を取り出せない。だから deriv の最初で直接判定する。
|#

;; ===================== 解答コード記入箇所 ここから =====================

(define (=number? exp num)
  (and (number? exp) (= exp num)))

(define (variable? x)
  (symbol? x))

(define (same-variable? v1 v2)
  (and (variable? v1)
       (variable? v2)
       (eq? v1 v2)))

(define (make-sum a1 a2)
  (cond ((=number? a1 0) a2)
        ((=number? a2 0) a1)
        ((and (number? a1) (number? a2)) (+ a1 a2))
        (else (list '+ a1 a2))))

(define (make-product m1 m2)
  (cond ((or (=number? m1 0) (=number? m2 0)) 0)
        ((=number? m1 1) m2)
        ((=number? m2 1) m1)
        ((and (number? m1) (number? m2)) (* m1 m2))
        (else (list '* m1 m2))))

(define (make-exponentiation base exponent)
  (cond ((=number? exponent 0) 1)
        ((=number? exponent 1) base)
        ((and (number? base) (number? exponent)) (expt base exponent))
        (else (list '** base exponent))))

(define (operator exp)
  (car exp))

(define (operands exp)
  (cdr exp))

(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp)
         (if (same-variable? exp var) 1 0))
        (else
         (let ((proc (get 'deriv (operator exp))))
           (if proc
               (proc (operands exp) var)
               (error "unknown expression type: DERIV" exp))))))

(define (install-deriv-sum-product-package)
  ;; operands は、(+ x 3) 全体ではなく、(x 3) の部分である。
  (define (addend operands)
    (car operands))
  (define (augend operands)
    (cadr operands))
  (define (multiplier operands)
    (car operands))
  (define (multiplicand operands)
    (cadr operands))

  (define (deriv-sum operands var)
    (make-sum (deriv (addend operands) var)
              (deriv (augend operands) var)))

  (define (deriv-product operands var)
    (make-sum
     (make-product (multiplier operands)
                   (deriv (multiplicand operands) var))
     (make-product (deriv (multiplier operands) var)
                   (multiplicand operands))))

  (put 'deriv '+ deriv-sum)
  (put 'deriv '* deriv-product)
  'done)

(define (install-deriv-exponentiation-package)
  ;; 練習問題 2.56 の指数規則を追加する。
  ;; ここでは指数が数値である場合を想定する。
  ;; d(u^n)/dx = n * u^(n-1) * du/dx
  (define (base operands)
    (car operands))
  (define (exponent operands)
    (cadr operands))

  (define (deriv-exponentiation operands var)
    (let ((b (base operands))
          (e (exponent operands)))
      (make-product
       (make-product e
                     (make-exponentiation b (- e 1)))
       (deriv b var))))

  (put 'deriv '** deriv-exponentiation)
  'done)

(install-deriv-sum-product-package)
(install-deriv-exponentiation-package)

#|
2.73 d の答え：
もし get の順を
((get (operator exp) 'deriv) (operands exp) var)
に変えるなら、put も同じ順に変える必要がある。
つまり、
(put 'deriv '+ deriv-sum)
ではなく、
(put '+ 'deriv deriv-sum)
のように登録する。
|#

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 練習問題 2.74
;; ============================================================
#|
問題文抜粋：
Insatiable Enterprises, Inc. は、多数の独立事業所からなる分散型複合企業である。
事業所ファイルは Scheme のデータ構造として実装されているが、構造は事業所ごとに違う。
この戦略をデータ主導プログラミングによって実装する方法を示せ。

a. 指定した人事ファイルから指定した従業員のレコードを取得する get-record を実装せよ。
   任意の事業所のファイルに適用できる必要がある。
b. 任意の事業所の人事ファイル内のレコードから給与情報を返す get-salary を実装せよ。
c. 全事業所のファイルから従業員を検索する find-employee-record を実装せよ。
d. 新しい会社を吸収した場合、新しい人事情報を中央システムに組み入れるためには
   どのような変更が必要になるか。
|#

#|
問題の型：
データ主導プログラミングの応用型。

考え方：
本部側は get-record, get-salary, find-employee-record だけを使う。
各事業所ごとのデータ構造の違いは、型タグと表によって隠す。
|#

;; ===================== 解答コード記入箇所 ここから =====================

;; 本部向けジェネリック手続き
(define (get-record employee-name personnel-file)
  (let ((proc (get 'get-record (type-tag personnel-file))))
    (if proc
        (proc employee-name (contents personnel-file))
        (error "No get-record method for this file type" personnel-file))))

(define (get-salary record)
  (let ((proc (get 'get-salary (type-tag record))))
    (if proc
        (proc (contents record))
        (error "No get-salary method for this record type" record))))

(define (find-employee-record employee-name files)
  (cond ((null? files) #f)
        (else
         (let ((record (get-record employee-name (car files))))
           (if record
               record
               (find-employee-record employee-name (cdr files)))))))

;; 事業所 A：レコードを (name address salary) のリストで持つ例
(define (install-office-a-package)
  (define (record-name record) (car record))
  (define (record-salary record) (caddr record))
  (define (tag-record record) (attach-tag 'office-a-record record))

  (define (get-record-a employee-name records)
    (cond ((null? records) #f)
          ((eq? employee-name (record-name (car records)))
           (tag-record (car records)))
          (else (get-record-a employee-name (cdr records)))))

  (put 'get-record 'office-a get-record-a)
  (put 'get-salary 'office-a-record record-salary)
  'done)

;; 事業所 B：レコードを (name . ((salary . n) (address . s))) の形で持つ例
(define (install-office-b-package)
  (define (record-name record) (car record))
  (define (record-fields record) (cdr record))
  (define (lookup-field key fields)
    (cond ((null? fields) #f)
          ((eq? key (caar fields)) (cdar fields))
          (else (lookup-field key (cdr fields)))))
  (define (record-salary record)
    (lookup-field 'salary (record-fields record)))
  (define (tag-record record) (attach-tag 'office-b-record record))

  (define (get-record-b employee-name records)
    (cond ((null? records) #f)
          ((eq? employee-name (record-name (car records)))
           (tag-record (car records)))
          (else (get-record-b employee-name (cdr records)))))

  (put 'get-record 'office-b get-record-b)
  (put 'get-salary 'office-b-record record-salary)
  'done)

(install-office-a-package)
(install-office-b-package)

(define office-a-file
  (attach-tag 'office-a
              (list (list 'alice "Tokyo" 500)
                    (list 'bob "Osaka" 600))))

(define office-b-file
  (attach-tag 'office-b
              (list (cons 'carol
                          (list (cons 'salary 700)
                                (cons 'address "Nagoya")))
                    (cons 'dave
                          (list (cons 'salary 800)
                                (cons 'address "Kyoto"))))))

(define all-office-files
  (list office-a-file office-b-file))

#|
2.74 d の答え：
新しい会社を吸収した場合、本部側の get-record, get-salary,
find-employee-record は変更しない。
新しい事業所パッケージを作り、
- 新しいファイル型タグ
- 新しいレコード型タグ
- その型に対する get-record
- その型に対する get-salary
を put で表に登録すればよい。
|#

;; ===================== 解答コード記入箇所 ここまで =====================


;; ============================================================
;; 練習問題 2.76
;; ============================================================
#|
問題文抜粋：
ジェネリック演算を使った大きなシステムが発展するにつれ、
新しいデータオブジェクトの型や新しい演算が必要になることがある。
三つの戦略、
- 明示的ディスパッチによるジェネリック演算
- データ主導スタイル
- メッセージパッシングスタイル
それぞれについて、新しい型や新しい演算を追加するために必要な変更を記述せよ。
新しい型がよく追加されるシステムでは、どの組み立て方が最も適しているか。
新しい演算を追加するシステムでは、どれが最も適しているか。
|#

#|
問題の型：
設計方針比較型。

解答案：

1. 明示的ディスパッチによるジェネリック演算
   新しい型を追加すると、real-part, imag-part, magnitude, angle など、
   既存のすべてのジェネリック演算の cond を書き換える必要がある。
   そのため、新しい型の追加には弱い。
   一方、新しい演算を追加する場合は、その演算用の cond を新しく作ればよい。

2. データ主導スタイル
   新しい型を追加するときは、その型のパッケージを作り、put で表に登録すればよい。
   既存コードを大きく変更しなくてよいので、新しい型の追加に強い。
   新しい演算を追加するときも、各型ごとの処理を表に追加すればよい。
   ただし、各型のパッケージに新しい演算を登録する作業は必要である。

3. メッセージパッシングスタイル
   新しい型を追加するときは、新しいコンストラクタを作るだけでよい。
   そのコンストラクタ内部の dispatch が、各メッセージに応答すればよい。
   そのため、新しい型の追加に強い。
   しかし、新しい演算を追加するときは、既存のすべてのデータオブジェクトの
   dispatch に新しいメッセージ処理を追加しなければならない。
   そのため、新しい演算の追加には弱い。

結論：
- 新しい型がよく追加されるなら、データ主導スタイルまたはメッセージパッシングがよい。
- 新しい演算がよく追加されるなら、明示的ディスパッチまたはデータ主導スタイルがよい。
- 両方の追加を考えるなら、既存コードを直接書き換えずに表へ登録できるデータ主導スタイルが最もバランスがよい。
|#


;; ============================================================
;; 練習問題 2.77〜2.80 用：ジェネリック算術演算システム
;; ============================================================
#|
ここからは 2.5.1 のジェネリック算術演算システムを作る。
2.77〜2.80 の解答が動くように、必要なパッケージをまとめて入れる。
|#

;; ジェネリック演算
(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (error "No method for these types: APPLY-GENERIC"
                 (list op type-tags))))))

(define (add x y) (apply-generic 'add x y))
(define (sub x y) (apply-generic 'sub x y))
(define (mul x y) (apply-generic 'mul x y))
(define (div x y) (apply-generic 'div x y))

(define (real-part z) (apply-generic 'real-part z))
(define (imag-part z) (apply-generic 'imag-part z))
(define (magnitude z) (apply-generic 'magnitude z))
(define (angle z) (apply-generic 'angle z))

(define (equ? x y) (apply-generic 'equ? x y))
(define (=zero? x) (apply-generic '=zero? x))


;; ============================================================
;; scheme-number パッケージ
;; 2.78 により、scheme-number は裸の数値として表す。
;; ============================================================

(define (install-scheme-number-package)
  (define (tag x) (attach-tag 'scheme-number x))

  (put 'add '(scheme-number scheme-number)
       (lambda (x y) (tag (+ x y))))
  (put 'sub '(scheme-number scheme-number)
       (lambda (x y) (tag (- x y))))
  (put 'mul '(scheme-number scheme-number)
       (lambda (x y) (tag (* x y))))
  (put 'div '(scheme-number scheme-number)
       (lambda (x y) (tag (/ x y))))

  ;; 2.79
  (put 'equ? '(scheme-number scheme-number)
       (lambda (x y) (= x y)))

  ;; 2.80
  (put '=zero? '(scheme-number)
       (lambda (x) (= x 0)))

  (put 'make 'scheme-number
       (lambda (x) (tag x)))
  'done)

(define (make-scheme-number n)
  ((get 'make 'scheme-number) n))


;; ============================================================
;; rational パッケージ
;; ============================================================

(define (install-rational-package)
  ;; 内部手続き
  (define (numer x) (car x))
  (define (denom x) (cdr x))
  (define (make-rat n d)
    (let ((g (gcd n d)))
      (let ((n1 (/ n g))
            (d1 (/ d g)))
        (if (< d1 0)
            (cons (- n1) (- d1))
            (cons n1 d1)))))
  (define (add-rat x y)
    (make-rat (+ (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (sub-rat x y)
    (make-rat (- (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (mul-rat x y)
    (make-rat (* (numer x) (numer y))
              (* (denom x) (denom y))))
  (define (div-rat x y)
    (make-rat (* (numer x) (denom y))
              (* (denom x) (numer y))))
  (define (equ-rat? x y)
    (= (* (numer x) (denom y))
       (* (numer y) (denom x))))
  (define (zero-rat? x)
    (= (numer x) 0))

  ;; 外部への登録
  (define (tag x) (attach-tag 'rational x))
  (put 'add '(rational rational)
       (lambda (x y) (tag (add-rat x y))))
  (put 'sub '(rational rational)
       (lambda (x y) (tag (sub-rat x y))))
  (put 'mul '(rational rational)
       (lambda (x y) (tag (mul-rat x y))))
  (put 'div '(rational rational)
       (lambda (x y) (tag (div-rat x y))))

  ;; 2.79
  (put 'equ? '(rational rational)
       equ-rat?)

  ;; 2.80
  (put '=zero? '(rational)
       zero-rat?)

  (put 'make 'rational
       (lambda (n d) (tag (make-rat n d))))
  'done)

(define (make-rational n d)
  ((get 'make 'rational) n d))


;; ============================================================
;; rectangular パッケージ
;; ============================================================

(define (square x) (* x x))

(define (install-rectangular-package)
  ;; 内部手続き
  (define (real-part z) (car z))
  (define (imag-part z) (cdr z))
  (define (make-from-real-imag x y) (cons x y))
  (define (magnitude z)
    (sqrt (+ (square (real-part z))
             (square (imag-part z)))))
  (define (angle z)
    (atan (imag-part z) (real-part z)))
  (define (make-from-mag-ang r a)
    (cons (* r (cos a))
          (* r (sin a))))

  ;; 外部への登録
  (define (tag x) (attach-tag 'rectangular x))
  (put 'real-part '(rectangular) real-part)
  (put 'imag-part '(rectangular) imag-part)
  (put 'magnitude '(rectangular) magnitude)
  (put 'angle '(rectangular) angle)
  (put 'make-from-real-imag 'rectangular
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'rectangular
       (lambda (r a) (tag (make-from-mag-ang r a))))
  'done)


;; ============================================================
;; polar パッケージ
;; ============================================================

(define (install-polar-package)
  ;; 内部手続き
  (define (magnitude z) (car z))
  (define (angle z) (cdr z))
  (define (make-from-mag-ang r a) (cons r a))
  (define (real-part z)
    (* (magnitude z) (cos (angle z))))
  (define (imag-part z)
    (* (magnitude z) (sin (angle z))))
  (define (make-from-real-imag x y)
    (cons (sqrt (+ (square x) (square y)))
          (atan y x)))

  ;; 外部への登録
  (define (tag x) (attach-tag 'polar x))
  (put 'real-part '(polar) real-part)
  (put 'imag-part '(polar) imag-part)
  (put 'magnitude '(polar) magnitude)
  (put 'angle '(polar) angle)
  (put 'make-from-real-imag 'polar
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'polar
       (lambda (r a) (tag (make-from-mag-ang r a))))
  'done)


;; ============================================================
;; complex パッケージ
;; ============================================================

(define (install-complex-package)
  ;; rectangular と polar のコンストラクタを利用する。
  (define (make-from-real-imag x y)
    ((get 'make-from-real-imag 'rectangular) x y))
  (define (make-from-mag-ang r a)
    ((get 'make-from-mag-ang 'polar) r a))

  (define (add-complex z1 z2)
    (make-from-real-imag (+ (real-part z1) (real-part z2))
                         (+ (imag-part z1) (imag-part z2))))
  (define (sub-complex z1 z2)
    (make-from-real-imag (- (real-part z1) (real-part z2))
                         (- (imag-part z1) (imag-part z2))))
  (define (mul-complex z1 z2)
    (make-from-mag-ang (* (magnitude z1) (magnitude z2))
                       (+ (angle z1) (angle z2))))
  (define (div-complex z1 z2)
    (make-from-mag-ang (/ (magnitude z1) (magnitude z2))
                       (- (angle z1) (angle z2))))

  (define (num-close? x y)
    (< (abs (- x y)) 0.00001))

  (define (equ-complex? z1 z2)
    (and (num-close? (real-part z1) (real-part z2))
         (num-close? (imag-part z1) (imag-part z2))))

  (define (zero-complex? z)
    (and (num-close? (real-part z) 0)
         (num-close? (imag-part z) 0)))

  ;; 外部への登録
  (define (tag z) (attach-tag 'complex z))
  (put 'add '(complex complex)
       (lambda (z1 z2) (tag (add-complex z1 z2))))
  (put 'sub '(complex complex)
       (lambda (z1 z2) (tag (sub-complex z1 z2))))
  (put 'mul '(complex complex)
       (lambda (z1 z2) (tag (mul-complex z1 z2))))
  (put 'div '(complex complex)
       (lambda (z1 z2) (tag (div-complex z1 z2))))

  ;; ============================================================
  ;; 2.77 の解答部分
  ;; complex タグを持つデータに対してもセレクタを使えるように登録する。
  ;; ============================================================
  (put 'real-part '(complex) real-part)
  (put 'imag-part '(complex) imag-part)
  (put 'magnitude '(complex) magnitude)
  (put 'angle '(complex) angle)

  ;; 2.79
  (put 'equ? '(complex complex)
       equ-complex?)

  ;; 2.80
  (put '=zero? '(complex)
       zero-complex?)

  (put 'make-from-real-imag 'complex
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'complex
       (lambda (r a) (tag (make-from-mag-ang r a))))
  'done)

(define (make-complex-from-real-imag x y)
  ((get 'make-from-real-imag 'complex) x y))

(define (make-complex-from-mag-ang r a)
  ((get 'make-from-mag-ang 'complex) r a))


;; ============================================================
;; 練習問題 2.77
;; ============================================================
#|
問題文抜粋：
Louis は (magnitude z) を評価しようとした。
z は外側に complex、内側に rectangular という二重タグを持つ 3+4i である。
しかし complex 型には magnitude がないというエラーになった。
Alyssa は complex パッケージに次を追加すればよいと言う。

(put 'real-part '(complex) real-part)
(put 'imag-part '(complex) imag-part)
(put 'magnitude '(complex) magnitude)
(put 'angle '(complex) angle)

なぜこれが動くのか説明せよ。
(magnitude z) の評価で apply-generic は何回起動されるか。
それぞれのディスパッチ先の手続きは何か。
|#

#|
問題の型：
ジェネリック演算の二重タグ理解型。

解答案：
3+4i は外側に complex タグ、内側に rectangular タグを持つ。
(magnitude z) を評価すると、まず z の型は complex なので、
apply-generic は表から (magnitude '(complex)) に対応する手続きを探す。
2.77 の追加により、そこには magnitude 自身が登録されている。

その手続きに contents z、つまり内側の rectangular データが渡される。
すると再び (magnitude <rectangular-data>) が評価される。
今度は型が rectangular なので、rectangular パッケージの magnitude にディスパッチされる。

したがって apply-generic は 2 回起動される。
1 回目：型 complex に対して、登録されたジェネリック手続き magnitude へ行く。
2 回目：型 rectangular に対して、rectangular パッケージ内部の magnitude へ行く。
|#


;; ============================================================
;; 練習問題 2.78
;; ============================================================
#|
問題文抜粋：
scheme-number パッケージの内部手続きは、基本手続き +, -, *, / への呼び出しでしかない。
Lisp の実装は内部で型システムを持っている。
type-tag, contents, attach-tag の定義を変更し、普通の数値を
(scheme-number . n) のようなペアではなく、単に Scheme の数値として表せるようにせよ。
|#

#|
問題の型：
型タグ表現の改良型。

解答：
このファイル冒頭の attach-tag, type-tag, contents が 2.78 の答えである。
- 数値なら type-tag は 'scheme-number を返す。
- 数値なら contents はそのまま数値を返す。
- scheme-number を attach-tag するときは、ペアを作らず数値をそのまま返す。
|#


;; ============================================================
;; 練習問題 2.79
;; ============================================================
#|
問題文抜粋：
二つの数値の等価性をテストするジェネリックな等価性述語 equ? を定義し、
ジェネリック算術演算パッケージに組み込め。
この演算は、通常の数値、有理数、複素数に対して動作しなければならない。
|#

#|
問題の型：
ジェネリック述語追加型。

解答：
このファイルでは、
(define (equ? x y) (apply-generic 'equ? x y))
を定義し、各パッケージ内で put によって equ? を登録している。
|#


;; ============================================================
;; 練習問題 2.80
;; ============================================================
#|
問題文抜粋：
引数が 0 であるかテストするジェネリックな述語 =zero? を定義し、
ジェネリック算術演算パッケージに組み込め。
この演算は、通常の数値、有理数、複素数に対して動作しなければならない。
|#

#|
問題の型：
ジェネリック述語追加型。

解答：
このファイルでは、
(define (=zero? x) (apply-generic '=zero? x))
を定義し、各パッケージ内で put によって =zero? を登録している。
|#


;; ============================================================
;; パッケージのインストール
;; ============================================================

(install-scheme-number-package)
(install-rational-package)
(install-rectangular-package)
(install-polar-package)
(install-complex-package)


;; ============================================================
;; テストコード
;; ============================================================

(display "----- 2.73 tests -----") (newline)
(check-equal? "d/dx (+ x 3)"
              (deriv '(+ x 3) 'x)
              1)
(check-equal? "d/dx (* x y)"
              (deriv '(* x y) 'x)
              'y)
(check-equal? "d/dx (** x 3)"
              (deriv '(** x 3) 'x)
              '(* 3 (** x 2)))

(display "----- 2.74 tests -----") (newline)
(check-equal? "salary of alice"
              (get-salary (get-record 'alice office-a-file))
              500)
(check-equal? "salary of carol"
              (get-salary (find-employee-record 'carol all-office-files))
              700)
(check-equal? "missing employee"
              (find-employee-record 'eve all-office-files)
              #f)

(display "----- 2.77 to 2.80 tests -----") (newline)

(define z1 (make-complex-from-real-imag 3 4))
(define z2 (make-complex-from-mag-ang 5 0))
(define r1 (make-rational 1 2))
(define r2 (make-rational 2 4))
(define r0 (make-rational 0 5))

(check-roughly? "2.77 magnitude of 3+4i"
                (magnitude z1)
                5)
(check-equal? "2.78 scheme-number is bare number"
              (make-scheme-number 10)
              10)
(check-equal? "2.79 equ? scheme-number"
              (equ? (make-scheme-number 10)
                    (make-scheme-number 10))
              #t)
(check-equal? "2.79 equ? rational 1/2 and 2/4"
              (equ? r1 r2)
              #t)
(check-equal? "2.79 equ? complex"
              (equ? z1 (make-complex-from-real-imag 3 4))
              #t)
(check-equal? "2.80 =zero? scheme-number"
              (=zero? (make-scheme-number 0))
              #t)
(check-equal? "2.80 =zero? rational"
              (=zero? r0)
              #t)
(check-equal? "2.80 =zero? complex"
              (=zero? (make-complex-from-real-imag 0 0))
              #t)

#|
よくあるミス：

1. put と get のキー順を間違える。
   (put 'deriv '+ proc) で登録したら、(get 'deriv '+) で取り出す。

2. 2.73 で operands の意味を間違える。
   (+ x 3) の operands は (x 3) であり、(+ x 3) 全体ではない。

3. 2.74 で本部側の手続きを事業所ごとに書き換えてしまう。
   データ主導なので、変更するのは各事業所パッケージと put の登録である。

4. 2.77 で complex タグを外した後、もう一度 apply-generic が呼ばれることを見落とす。
   (magnitude z) では apply-generic が 2 回起動する。

5. 2.78 で number? の場合を type-tag / contents に追加し忘れる。
   これを忘れると、裸の数値に対して type-tag が使えない。

6. 2.79, 2.80 で述語の返り値にタグをつけてしまう。
   equ? や =zero? は #t / #f を返す述語なので、タグつきデータを返さない。

7. Racket では (x < 4) ではなく (< x 4) と書く。

8. = は代入ではなく比較である。
|#
