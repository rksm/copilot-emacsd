;; -*-no-byte-compile: t; -*-
;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

(require 'package)

(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))
(setq package-user-dir (expand-file-name "elpa/" user-emacs-directory))

(setq ;; debug-on-error t
      no-byte-compile t
      byte-compile-warnings nil
      warning-suppress-types '((comp))
      inhibit-startup-screen t
      package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/"))
      custom-file (expand-file-name "custom.el" user-emacs-directory))


;; install dependencies
(let ((pkg-list '(use-package
		  s
		  dash
		  editorconfig
                  company)))
  (package-initialize)
  (when-let ((to-install (map-filter (lambda (pkg _) (not (package-installed-p pkg))) pkg-list)))
    (package-refresh-contents)
    (mapc (lambda (pkg) (package-install pkg)) pkg-list)))

(require 'cl)
(require 'use-package)

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

(defun rk/copilot-tab ()
  "Tab command that will complet with copilot if a completion is
available. Otherwise will try company, yasnippet or normal
tab-indent."
  (interactive)
  (or (copilot-accept-completion)
      (company-yasnippet-or-completion)
      (indent-for-tab-command)))

(defun rk/copilot-complete-or-accept ()
  "Command that either triggers a completion or accepts one if one
is available. Useful if you tend to hammer your keys like I do."
  (interactive)
  (if (copilot--overlay-visible)
      (progn
        (copilot-accept-completion)
        (open-line 1)
        (next-line))
    (copilot-complete)))

(defun rk/copilot-quit ()
  "Run `copilot-clear-overlay' or `keyboard-quit'. If copilot is
cleared, make sure the overlay doesn't come back too soon."
  (interactive)
  (condition-case err
      (when copilot--overlay
        (lexical-let ((pre-copilot-disable-predicates copilot-disable-predicates))
          (setq copilot-disable-predicates (list (lambda () t)))
          (copilot-clear-overlay)
          (run-with-idle-timer
           1.0
           nil
           (lambda ()
             (setq copilot-disable-predicates pre-copilot-disable-predicates)))))
    (error handler)))

(defun rk/copilot-complete-if-active (next-func n)
  (let ((completed (when copilot-mode (copilot-accept-completion))))
    (unless completed (funcall next-func n))))

(defun rk/no-copilot-mode ()
  "Helper for `rk/no-copilot-modes'."
  (copilot-mode -1))

(defvar rk/no-copilot-modes '(shell-mode
                              inferior-python-mode
                              eshell-mode
                              term-mode
                              vterm-mode
                              comint-mode
                              compilation-mode
                              debugger-mode
                              dired-mode-hook
                              compilation-mode-hook
                              flutter-mode-hook
                              minibuffer-mode-hook)
  "Modes in which copilot is inconvenient.")

(defvar rk/copilot-manual-mode nil
  "When `t' will only show completions when manually triggered, e.g. via M-C-<return>.")

(defvar rk/copilot-enable-for-org nil
  "Should copilot be enabled for org-mode buffers?")



(defun rk/copilot-enable-predicate ()
  ""
  (and
   (eq (get-buffer-window) (selected-window))))

(defun rk/copilot-disable-predicate ()
  "When copilot should not automatically show completions."
  (or rk/copilot-manual-mode
      (member major-mode rk/no-copilot-modes)
      (and (not rk/copilot-enable-for-org) (eq major-mode 'org-mode))
      (company--active-p)))

(defun rk/copilot-change-activation ()
  "Switch between three activation modes:
- automatic: copilot will automatically overlay completions
- manual: you need to press a key (M-C-<return>) to trigger completions
- off: copilot is completely disabled."
  (interactive)
  (if (and copilot-mode rk/copilot-manual-mode)
      (progn
        (message "deactivating copilot")
        (global-copilot-mode -1)
        (setq rk/copilot-manual-mode nil))
    (if copilot-mode
        (progn
          (message "activating copilot manual mode")
          (setq rk/copilot-manual-mode t))
      (message "activating copilot mode")
      (global-copilot-mode))))

(defun rk/copilot-toggle-for-org ()
  "Toggle copilot activation in org mode. It can sometimes be
annoying, sometimes be useful, that's why this can be handly."
  (interactive)
  (setq rk/copilot-enable-for-org (not rk/copilot-enable-for-org))
  (message "copilot for org is %s" (if rk/copilot-enable-for-org "enabled" "disabled")))

;; load the copilot package
(use-package copilot
  :load-path (lambda () (expand-file-name "copilot.el" user-emacs-directory))

  :diminish ;; don't show in mode line (we don't wanna get caught cheating, right? ;)

  :config
  ;; keybindings that are active when copilot shows completions
  (define-key copilot-mode-map (kbd "M-C-<next>") #'copilot-next-completion)
  (define-key copilot-mode-map (kbd "M-C-<prior>") #'copilot-previous-completion)
  (define-key copilot-mode-map (kbd "M-C-<right>") #'copilot-accept-completion-by-word)
  (define-key copilot-mode-map (kbd "M-C-<down>") #'copilot-accept-completion-by-line)

  ;; global keybindings
  (define-key global-map (kbd "M-C-<return>") #'rk/copilot-complete-or-accept)
  (define-key global-map (kbd "M-C-<escape>") #'rk/copilot-change-activation)

  ;; Do copilot-quit when pressing C-g
  (advice-add 'keyboard-quit :before #'rk/copilot-quit)

  ;; complete by pressing right or tab but only when copilot completions are
  ;; shown. This means we leave the normal functionality intact.
  (advice-add 'right-char :around #'rk/copilot-complete-if-active)
  (advice-add 'indent-for-tab-command :around #'rk/copilot-complete-if-active)

  ;; deactivate copilot for certain modes
  (add-to-list 'copilot-enable-predicates #'rk/copilot-enable-predicate)
  (add-to-list 'copilot-disable-predicates #'rk/copilot-disable-predicate))

(eval-after-load 'copilot
  '(progn
     ;; Note company is optional but given we use some company commands above
     ;; we'll require it here. If you don't use it, you can remove all company
     ;; related code from this file, copilot does not need it.
     (require 'company)
     (global-copilot-mode)))

(copilot-login)
