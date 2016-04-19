;; Copyright (C) 2013 Dave Griffiths
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Affero General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Affero General Public License for more details.
;;
;; You should have received a copy of the GNU Affero General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

#lang racket
(require (planet jaymccarthy/sqlite:5:1/sqlite))
(provide (all-defined-out))
(require "logger.ss")

(define (setup db)
  (exec/ignore db "CREATE TABLE player ( id INTEGER PRIMARY KEY AUTOINCREMENT, species TEXT, played_before INTEGER, age_range INTEGER, easy_score INTEGER, hard_score INTEGER)")
  (exec/ignore db "CREATE TABLE click ( id INTEGER PRIMARY KEY AUTOINCREMENT, player_id INTEGER, photo_name TEXT, photo_offset_x INTEGER, photo_offset_y INTEGER, time_stamp INTEGER, x_position INTEGER, y_position INTEGER, success INTEGER, level TEXT )")
  (exec/ignore db "CREATE TABLE player_name ( id INTEGER PRIMARY KEY AUTOINCREMENT, player_id INTEGER, player_name TEXT )")
  )

(define (insert-player db species played_before age_range)
  (log "player " species " " played_before " " age_range)
  (insert
   db "INSERT INTO player VALUES (NULL, ?, ?, ?, 999999, 999999)"
   species (if (equal? played_before "false") "0" "1") age_range ))

(define (insert-click db player_id photo_name photo_offset_x photo_offset_y time_stamp x_position y_position success level)
  (log "click " player_id " " photo_name " " photo_offset_x " " photo_offset_y " " time_stamp " " x_position " " y_position " " success " " level)
  (insert
   db
   "INSERT INTO click VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
   player_id photo_name photo_offset_x photo_offset_y time_stamp x_position
   y_position success level))

(define (insert-player-name db player_id player_name)
  (log "player name " player_id " " player_name)
  (insert db "insert into player_name VALUES (NULL, ?, ?)"
          player_id player_name ))

(define (get-player-averages db level)
  (let ((s (select db (string-append "select " level "_score from player as p join player_name as n on p.id = n.player_id;"))))
    (if (null? s)
        '()
        (map
         (lambda (i) (vector-ref i 0))
         (cdr s)))))

(define (get-hiscores db)
  (list
   (map
    (lambda (i)
      (list (vector-ref i 0) (vector-ref i 1)))
    (cdr (select db "select n.player_name, p.easy_score from player as p join player_name as n on p.id=n.player_id order by p.easy_score limit 100;")))
   (map
    (lambda (i)
      (list (vector-ref i 0) (vector-ref i 1)))
    (cdr (select db "select n.player_name, p.hard_score from player as p join player_name as n on p.id=n.player_id order by p.hard_score limit 100;")))))

(define (get-player-average db player-id level)
  (let ((v (cadr
            (select db "select avg(time_stamp), count(time_stamp) from click where success = 1 and player_id = ? and level = ?"
                    (number->string player-id) level))))
    (when (> (vector-ref v 1) 5)
          (exec/ignore
           db (string-append
               "update player set " level "_score = ? where id = ?")
           (number->string (vector-ref v 0))
           (number->string player-id)))
    (vector-ref v 0)))

(define (get-player-count db player-id)
  (let ((v (cadr (select db (string-append
                             "SELECT count(time_stamp) from click where success = 1 and player_id = "
                             (number->string player-id))))))
    (vector-ref v 0)))

(define (get-position v ol)
  (define (_ n l)
    (cond
      ((null? l) n)
      ((> (car l) v) n)
      (else (_ (+ n 1) (cdr l)))))
  (_ 1 ol))

(define (get-player-rank db av level)
  (if av
      (let ((rank (sort (get-player-averages db level) <)))
        (get-position av rank))
      999))
