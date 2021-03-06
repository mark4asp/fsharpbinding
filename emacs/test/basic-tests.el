(require 'ert)

(defun init-melpa ()
  (setq package-archives
        '(("melpa"       . "http://melpa.milkbox.net/packages/")))
  (package-initialize)
  (unless package-archive-contents
    (package-refresh-contents)))

(defun ensure-packages (packages)
  (dolist (package packages)
    (unless (package-installed-p package)
      (package-install package))))

(defun load-fsharp-mode ()
  (unless (functionp 'fsharp-mode)
    (let ((testmode (getenv "TESTMODE")))
      (cond
       ((eq testmode nil) ; Load from current checkout
        (push (expand-file-name "..") load-path)

        (push '("\\.fs[iylx]?$" . fsharp-mode) auto-mode-alist)
        (autoload 'fsharp-mode "fsharp-mode" "Major mode for editing F# code." t)
        (autoload 'run-fsharp "inf-fsharp-mode" "Run an inferior F# process." t)
        (autoload 'ac-fsharp-launch-completion-process "fsharp-mode-completion" "Launch the completion process" t)
        (autoload 'ac-fsharp-quit-completion-process "fsharp-mode-completion" "Quit the completion process" t)
        (autoload 'ac-fsharp-load-project "fsharp-mode-completion" "Load the specified F# project" t))

       ((string= testmode "melpa") ; Install from MELPA
        (init-melpa)
        (ensure-packages '(fsharp-mode)))

       (t ; Assume `testmode` is a package file to install
          ; TODO: Break net dependency (pos-tip) for speed?
        (init-melpa)
        (ensure-packages '(pos-tip))
        (package-install-file (expand-file-name testmode)))))))

(ert-deftest change-to-mode-fs ()
  "Check that loading a .fs file causes us to change to fsharp-mode"
  (load-fsharp-mode)
  (find-file "Test1/FileTwo.fs")
  (should (eq major-mode 'fsharp-mode)))
