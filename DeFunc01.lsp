#| Just doing a "baseline" save instead of the standard autosave, is a great time saver, since you don't have to wait for the package file to zip (why don't they do that in the background?). 
This sequence saves a baseline save using .sd? format to the user's temp directory. Current suggested usage is to turn on Modeling's Autosave function with the 'ask before save' option. When it asks
if you want to save now, say no, then use these tools. The first time per Modeling session you'll need to do AutoSaveBaseline; each baseline creates a copy upon completion to fallback to. 
Subsequent saves using AutoSaveIncremental will be substantially quicker; current code cycles through 3 copies of autosaves to fallback to. 

For best safety in testing phase, consider doing a new baseline save when heading out to lunch, a meeting, or other opportunity where the delay of the save won't be an irritation. This frequent number of 
copies of design space have the potential to quickly fill up your hard drive - OpenAutoSaveDir will take you to the Autosave base directory where you can delete old unneeded directories. 

To recover in the case of crash you can go to the most recent autosave directory, sort by file type and load .sd? files, i.e. .sdw, .sdp, .sda, etc. Don't load .sd?c files unless you are only after a 
particular instance of part/assy/WP.
|#

(in-package :valve)
(use-package :oli)
(sd-display-alert "Loading Autosave" :icon :info :auto-close-time 5)
(defvar *AutoSaveIncrement* 1)																							;Loop counter
(defvar *AutoSaveNumberOfIncrements* 3)																					;How many backups do you want? 
(defvar *AutoSaveBaseLocation* nil)																						;Establish autosave location variable

(unless (sd-directory-p (format nil "~AAutosave" (sd-inq-temp-dir)))													;Check if an autosave directory exists in the user's temp directoy
  (sd-make-directory (format nil "~AAutosave" (sd-inq-temp-dir)))														;Make Autosave directory
)

(defun AutoSaveBaseline ()
  (setf *AutoSaveBaseLocation* (format nil "~AAutosave/~A" (sd-inq-temp-dir) (get-universal-time)))						;Establish autosave location
  (sd-make-directory *AutoSaveBaseLocation*)																			;Create autosave location
  (sd-display-alert "Beginning Baseline Autosave" :icon :info :auto-close-time 5)										;Popup toast warning user what's up
  (sd-with-current-working-directory *AutoSaveBaseLocation*																;Remember CWD, change dir, run these things, revert to CWD
    (save_sd :OVERWRITE :CWD_CHANGED :SELECT :all_at_top) 																;Save all items using .sd format 
    (sd-sys-background-job (format nil "xcopy ..\\~A ..\\~ABaseCopy /I" (subseq *AutoSaveBaseLocation* (- (length *AutoSaveBaseLocation*) 10)) (subseq *AutoSaveBaseLocation* (- (length *AutoSaveBaseLocation*) 10)))) ;Assumes 10 character timestamp
    (sd-display-alert (format nil "Autosaved to ~A" *AutoSaveBaseLocation*) :icon :info :auto-close-time 5)				;Popup toast showing location saved to
  )
)
 
(defun AutoSaveIncremental ()
  (oli:sd-display-alert "Beginning Incremental Autosave" :icon :info :auto-close-time 1)								;Popup toast warning user what's up
  (sd-with-current-working-directory *AutoSaveBaseLocation*																;Remember CWD, change dir, run these things, revert to CWD
    (save_sd_modified :OVERWRITE :all_at_top :TOP_LEVEL_INSTANCE_FILES :YES :DIRECTORY *AutoSaveBaseLocation* complete) ;Save all modified items - super fast 
    (sd-display-alert (format nil "Autosaved to ~A" *AutoSaveBaseLocation*) :icon :info :auto-close-time 5)				;Popup toast showing location saved to
    (sd-sys-background-job (format nil "xcopy ..\\~A ..\\~A_~A /I" (subseq *AutoSaveBaseLocation* (- (length *AutoSaveBaseLocation*) 10)) (subseq *AutoSaveBaseLocation* (- (length *AutoSaveBaseLocation*) 10)) *AutoSaveIncrement*)) ;Assumes 10 character timestamp
    (sd-display-alert (format nil "Copied incremental to ~A_~A" *AutoSaveBaseLocation* *AutoSaveIncrement*) :icon :info :auto-close-time 5)				;Popup toast showing location saved to
  )	
  (if (= *AutoSaveIncrement* *AutoSaveNumberOfIncrements*)																;Loop to capture fallback increments
    (setf *AutoSaveIncrement* 1)																						;Reset to 1
	(setf *AutoSaveIncrement* (+ *AutoSaveIncrement* 1))																;Increment by 1
  )	
)

(defun OpenAutoSaveDir ()
;  (sd-with-current-working-directory *AutoSaveBaseLocation*																;Remember CWD, change dir, run these things, revert to CWD
;    (sd-sys-background-job "start ..")
;  )
  (sd-sys-background-job (format nil "start ~AAutosave" (sd-inq-temp-dir)))
)

(defun QuickClickAutoSave ()																							;If there hasn't been a baseline AutoSave this session, performs AutoSaveBaseline. If AutoSaveBaseLocation != nil do an AutoSaveIncremental
  (sd-display-alert "Checking for AutoSaveLocation" :icon :info :auto-close-time 5)										;Popup toast warning user what's up
  (if (eq *AutoSaveBaseLocation* nil) 
    (AutoSaveBaseline)
	(AutoSaveIncremental)
  )
)

(ADD_TOOLBOX_BUTTON :TOOLBOX "TOOLBOX" :LABEL "AutoSave Baseline" :ACTION "(valve::AutoSaveBaseline)")
(ADD_TOOLBOX_BUTTON :TOOLBOX "TOOLBOX" :LABEL "AutoSave Incremental" :ACTION "(valve::AutoSaveIncremental)")
(ADD_TOOLBOX_BUTTON :TOOLBOX "TOOLBOX" :LABEL "Open AutoSave Dir" :ACTION "(valve::OpenAutoSaveDir)")
(ADD_TOOLBOX_BUTTON :TOOLBOX "TOOLBOX" :LABEL "Quick Click AutoSave" :ACTION "(valve::QuickClickAutoSave)")

(sd-display-alert "Done loading Autosave" :icon :info :auto-close-time 5)

