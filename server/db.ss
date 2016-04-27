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
  (exec/ignore db "create table player ( id integer primary key autoincrement, played_before integer, age_range integer)")
  (exec/ignore db "create table game ( id integer primary key autoincrement, player_id integer, species text, bg_location text, score integer)")
  (exec/ignore db "create table click ( id integer primary key autoincrement, game_id integer, photo_name text, crab_name text, crab_x integer, crab_y integer, crab_rot real, time_stamp integer, x_position integer, y_position integer, success integer )")
  (exec/ignore db "create table player_name ( id integer primary key autoincrement, player_id integer, player_name text )")
  (exec/ignore db "create table crab_time ( id integer primary key autoincrement, game_id integer, photo_name text, crab_name text, time_stamp integer, success_code integer )")
  )

(define (insert-player db played_before age_range)
  (insert
   db "INSERT INTO player VALUES (NULL, ?, ?)"
   (if (equal? played_before "false") "0" "1") age_range ))

(define (insert-game db player_id species bg_location)
  (insert
   db "INSERT INTO game VALUES (NULL, ?, ?, ?, 999999)"
   player_id species bg_location))

(define (insert-click db game_id photo_name crab_name crab_x crab_y crab_rot time_stamp x_position y_position success)
  (insert
   db
   "INSERT INTO click VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
   game_id
   photo_name
   crab_name
   crab_x
   crab_y
   crab_rot
   time_stamp
   x_position
   y_position
   success
   ))

;; redundant info for quick graphs
(define (insert-crab-time db game_id photo_name crab_name time_stamp success_code)
  (insert
   db
   "INSERT INTO crab_time VALUES (NULL, ?, ?, ?, ?, ?)"
   game_id
   photo_name
   crab_name
   time_stamp
   success_code
   ))

(define (insert-player-name db player_id player_name)
  (insert db "insert into player_name VALUES (NULL, ?, ?)"
          player_id player_name ))

;; get scores from games from the same type as this game id
(define (get-game-averages db game_id)
  (let* ((bg_location (vector-ref (cadr (select db "select bg_location from game where id=?" game_id)) 0))
         (s (select db "select score from game where bg_location=? order by score desc"
                    bg_location)))
    (if (null? s)
        '()
        (map
         (lambda (i) (vector-ref i 0))
         (cdr s)))))

(define (hiscores-select db location)
  (let ((r (select db "select n.player_name, g.score from game as g
                     join player_name as n on g.player_id=n.player_id
                     where g.bg_location = ? and g.score != 999999
                     order by g.score limit 100;"
                   location)))
    (if (null? r) '() (cdr r))))

(define (get-hiscores db)
  (list
   (map
    (lambda (i)
      (list (vector-ref i 0) (vector-ref i 1)))
    (hiscores-select db "rockpool"))
   (map
    (lambda (i)
      (list (vector-ref i 0) (vector-ref i 1)))
    (hiscores-select db "mudflat"))
   (map
    (lambda (i)
      (list (vector-ref i 0) (vector-ref i 1)))
    (hiscores-select db "musselbed"))))

(define (get-stats db)
  (list
   (map
    (lambda (i)
      (list (vector-ref i 0) (vector-ref i 1)))
    (cdr (select db "select n.player_name, p.easy_score from player as p join player_name as n on p.id=n.player_id order by p.easy_score limit 100;")))
   (map
    (lambda (i)
      (list (vector-ref i 0) (vector-ref i 1)))
    (cdr (select db "select n.player_name, p.hard_score from player as p join player_name as n on p.id=n.player_id order by p.hard_score limit 100;")))))


(define (get-game-average db game-id)
  (let ((v (cadr
            (select db
                    "select avg(time_stamp), count(time_stamp) from click where success = 1 and game_id = ?"
                    game-id))))

    (when (> (vector-ref v 1) 5)
          (exec/ignore
           db (string-append
               "update game set score = ? where id = ?")
           (number->string (vector-ref v 0))
           game-id))
    (vector-ref v 0)))

(define (get-game-count db game-id)
  (let ((v (cadr (select
                  db
                  "select count(time_stamp) from click where success = 1 and game_id = ?"
                  game-id))))
    (vector-ref v 0)))

(define (get-position v ol)
  (define (_ n l)
    (cond
      ((null? l) n)
      ((> (car l) v) n)
      (else (_ (+ n 1) (cdr l)))))
  (_ 1 ol))

(define (get-game-rank db game-id av)
  (if av
      (let ((rank (get-game-averages db game-id)))
        (get-position av rank))
      999))
