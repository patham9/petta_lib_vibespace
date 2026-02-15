!(import! &self (library lib_import))
!(git-import! "https://github.com/patham9/petta_lib_vibespace.git")
!(import! &self (library lib_vibespace))

(elephant sam 100)
(elephant tom 300)

(= (myfun42 $L)
   (cons 42 $L))

!(vibe "write me a function named weight that gives me the weight of an elephant of the space")

!(vibe "create a function weight2 that uses the previous function and multiplies the returned value with 2")

!(vibe "also please add a function like myfun42 but with 43 instead")

!(test (myfun43 (5 6 7))
       (43 5 6 7))

!(test (weight sam)
       100)

!(test (weight2 tom)
       600)
