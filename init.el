;; -*-no-byte-compile: t; -*-
;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;; start with:
;;  emacs -nw -Q -l $HOME/.emacs.d/only-rust.el $@
;; /usr/local/opt/emacs-plus@28/Emacs.app/Contents/MacOS/Emacs -nw -Q -l /Users/robert/projects/emacs/copilot/copilot-emacsd/init.el

(require 'package)

(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))
(setq package-user-dir (expand-file-name "elpa/" user-emacs-directory))

(setq ;; debug-on-error t
      no-byte-compile t
      byte-compile-warnings nil
      inhibit-startup-screen t
      package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/"))
      custom-file (expand-file-name "custom.el" package-user-dir))

;; ;; (delete-file package-user-dir)

;; (let* ((pkg-list '(lsp-mode
;;                    lsp-ui
;;                    yasnippet
;;                    lsp-java
;;                    lsp-python-ms
;;                    lsp-haskell
;;                    helm-lsp
;;                    lsp-treemacs
;;                    dap-mode
;;                    lsp-origami
;;                    lsp-dart
;;                    company
;;                    flycheck
;;                    lsp-pyright
;;                    ;; modes
;;                    rust-mode
;;                    php-mode
;;                    scala-mode
;;                    dart-mode
;;                    clojure-mode
;;                    typescript-mode
;;                    csharp-mode
;;                    lua-mode)))

;;   (package-initialize)
;;   (package-refresh-contents)

;;   (mapc (lambda (pkg)
;;           (unless (package-installed-p pkg)
;;             (package-install pkg))
;;           (require pkg))
;;         pkg-list)

;;   (yas-global-mode)
;;   (add-hook 'prog-mode-hook 'lsp)
;;   ;; (add-hook 'kill-emacs-hook `(lambda ()
;;   ;;                               (delete-directory ,package-user-dir t)))
;;   )

;; (provide 'lsp-start-plain)
;; ;;; lsp-start-plain.el ends here
