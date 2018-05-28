(in-package :valve)
(use-package :oli)
(sd-display-alert "Loading anno-autosave" :icon :info :auto-close-time 5)

(defun anno-autosave ()
  (am_store_drawing :filename (format nil "~A\\autosave-drawing.mi" valve::*AutoSaveBaseLocation*) :overwrite :check_up_to_date 1 :yes)    )
