!(import! &self (library lib_llm))
!(import_prolog_function read_line_to_string)
!(import_prolog_function process_metta_string)
!(import_prolog_function split_string)
!(import_prolog_function atomic_list_concat)
!(import_prolog_function string_concat)

;Helper to escape newlines for valid request:
(= (newlinify $str)
   (atomic_list_concat (split_string $str "\n" "") "\\n"))

;Functions to save and restore session context:
!(add-atom &context (context ""))
(= (update-context $NEW)
   (match &context (context $X)
                   (progn (remove-atom &context (context $X))
                          (add-atom &context (context $NEW)))))
(= (get-context)
   (once (match &context (context $X) $X)))

;Provides compute feedback for GPT from its output expectation:
(= assert (-> Atom Expression Atom))
(= (assert $a $b) ;not interested in the test result we just want to execute
   (if (== $a $b)
       ((assertionSuccess: True) (result: $a))
       ((assertionSuccess: False) (result: $a))))

;GPT LLM use case:
(= (vibe)
   (vibe (library curriculum.metta) (read_line_to_string user_input)))
(= (vibe $instruction)
   (vibe (library curriculum.metta) $instruction))
(= (vibe $curriculum $instruction)
   (let* (;2. Context variables to be included in the prompt:
          ($_ (translatePredicate (read_file_to_string $curriculum $howto ())))
          ($instruction (read_line_to_string user_input))
          ($currentSpace (repr (collapse (get-atoms &space))))
          ($howtostr (newlinify $howto))
          ($history (get-context))
          ;3. Ask GPT to generate MeTTa code:
          ($str (useGPT (py-str ($howtostr " These were all MeTTa test cases. Now write a MeTTa program compliant with: " $instruction 
                                 " considering current space is " $currentSpace " and recent interaction history was: " $history 
                                 " Return only the MeTTa source code as it will be directly executed, nothing else, "
                                 " and stay close to constructs you see in the examples, and don't forget to add ! if you want to execute something"
                                 " and don't add functions you already added."))))
          ;4. Print AI output and add to context together with the user instruction for future reference by LLM:
          ($_ (println! $str))
          ($_ (update-context (string_concat (string_concat $history (string_concat " USER: " $instruction)) (string_concat " AI: " (newlinify $str))))))
         ;5. Run the AI code, print the results for the user and add to history for future reference by LLM:
         (let $result (catch (process_metta_string $str))
              (progn (println! $result)
                     (update-context (string_concat (get-context) (string_concat " RESULT: " (repr $result))))))))
