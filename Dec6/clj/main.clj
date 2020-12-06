(require '[clojure.set :as cset])

(defn split-all [a]
  (clojure.string/split a #""))

(defn split-persons [a]
  (clojure.string/split a #"\n"))

(defn is-not-newline [a]
  (not (== 0 (compare "\n" a))))

(defn just-chars [a]
  (filter is-not-newline (split-all a)))

(defn what-chars-are-there [a]
  (reduce conj #{} (just-chars a)))

(defn chars-all-have [a]
  (reduce cset/intersection (what-chars-are-there a) (map what-chars-are-there (split-persons a))))

(println
  (reduce + 0 
    (map count 
      (map what-chars-are-there
        ;(clojure.string/split (input) #"\n\n"))))
        (clojure.string/split (slurp "../input.dat") #"\n\n")))))

(println
  (reduce + 0
    (map count
      (map chars-all-have
        ;(clojure.string/split (input) #"\n\n"))))
        (clojure.string/split (slurp "../input.dat") #"\n\n")))))
