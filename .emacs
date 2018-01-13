(require 'package)
(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))


;; bsemantic
(add-hook 'c-mode-common-hook (lambda()
				(semantic-mode 1)
				(global-semantic-idle-scheduler-mode 1)			
				))
;; esemantic


;; bprojects
(add-hook 'c-mode-common-hook (lambda()
				(global-ede-mode 1)
				(ede-cpp-root-project "app"
						      :file "~/projects/test/CMakeLists.txt"
						      :include-path '("~/projects/test/include"))				
				))
;; eprojects

;; bac
(require 'auto-complete)
(require 'ac-c-headers)
(ac-config-default)
(setq ac-auto-start nil)
(define-key ac-mode-map (kbd "C-x c") 'auto-complete)
(add-hook 'c-mode-common-hook (lambda()
				(add-to-list 'ac-sources 'ac-source-semantic)
				(add-to-list 'ac-sources 'ac-source-c-headers)
				;; (add-to-list 'ac-sources 'ac-source-c-header-symbols t)	
				
				))
;; eac




;; bhelm
(use-package helm
  :init
  (progn
    (require 'helm-config)
    (require 'helm-grep)
    ;; To fix error at compile:
    ;; Error (bytecomp): Forgot to expand macro with-helm-buffer in
    ;; (with-helm-buffer helm-echo-input-in-header-line)
    (if (version< "26.0.50" emacs-version)
        (eval-when-compile (require 'helm-lib)))

    (defun helm-hide-minibuffer-maybe ()
      (when (with-helm-buffer helm-echo-input-in-header-line)
        (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
          (overlay-put ov 'window (selected-window))
          (overlay-put ov 'face (let ((bg-color (face-background 'default nil)))
                                  `(:background ,bg-color :foreground ,bg-color)))
          (setq-local cursor-type nil))))

    (add-hook 'helm-minibuffer-set-up-hook 'helm-hide-minibuffer-maybe)
    ;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
    ;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
    ;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
    (global-set-key (kbd "C-c h") 'helm-command-prefix)
    (global-unset-key (kbd "C-x c"))

    (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebihnd tab to do persistent action
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
    (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

    (define-key helm-grep-mode-map (kbd "<return>")  'helm-grep-mode-jump-other-window)
    (define-key helm-grep-mode-map (kbd "n")  'helm-grep-mode-jump-other-window-forward)
    (define-key helm-grep-mode-map (kbd "p")  'helm-grep-mode-jump-other-window-backward)

    (when (executable-find "curl")
      (setq helm-google-suggest-use-curl-p t))

    (setq helm-google-suggest-use-curl-p t
          helm-scroll-amount 4 ; scroll 4 lines other window using M-<next>/M-<prior>
          ;; helm-quick-update t ; do not display invisible candidates
          helm-ff-search-library-in-sexp t ; search for library in `require' and `declare-function' sexp.

          ;; you can customize helm-do-grep to execute ack-grep
          ;; helm-grep-default-command "ack-grep -Hn --smart-case --no-group --no-color %e %p %f"
          ;; helm-grep-default-recurse-command "ack-grep -H --smart-case --no-group --no-color %e %p %f"
          helm-split-window-in-side-p t ;; open helm buffer inside current window, not occupy whole other window

          helm-echo-input-in-header-line t

          ;; helm-candidate-number-limit 500 ; limit the number of displayed canidates
          helm-ff-file-name-history-use-recentf t
          helm-move-to-line-cycle-in-source t ; move to end or beginning of source when reaching top or bottom of source.
          helm-buffer-skip-remote-checking t

          helm-mode-fuzzy-match t

          helm-buffers-fuzzy-matching t ; fuzzy matching buffer names when non-nil
                                        ; useful in helm-mini that lists buffers
          helm-org-headings-fontify t
          ;; helm-find-files-sort-directories t
          ;; ido-use-virtual-buffers t
          helm-semantic-fuzzy-match t
          helm-M-x-fuzzy-match t
          helm-imenu-fuzzy-match t
          helm-lisp-fuzzy-completion t
          ;; helm-apropos-fuzzy-match t
          helm-buffer-skip-remote-checking t
          helm-locate-fuzzy-match t
          helm-display-header-line nil)

    (add-to-list 'helm-sources-using-default-as-input 'helm-source-man-pages)

    (global-set-key (kbd "M-x") 'helm-M-x)
    (global-set-key (kbd "M-y") 'helm-show-kill-ring)
    (global-set-key (kbd "C-x b") 'helm-buffers-list)
    (global-set-key (kbd "C-x C-f") 'helm-find-files)
    (global-set-key (kbd "C-c r") 'helm-recentf)
    (global-set-key (kbd "C-h SPC") 'helm-all-mark-rings)
    (global-set-key (kbd "C-c h o") 'helm-occur)
    (global-set-key (kbd "C-c h o") 'helm-occur)

    (global-set-key (kbd "C-c h w") 'helm-wikipedia-suggest)
    (global-set-key (kbd "C-c h g") 'helm-google-suggest)

    (global-set-key (kbd "C-c h x") 'helm-register)
    ;; (global-set-key (kbd "C-x r j") 'jump-to-register)

    (define-key 'help-command (kbd "C-f") 'helm-apropos)
    (define-key 'help-command (kbd "r") 'helm-info-emacs)
    (define-key 'help-command (kbd "C-l") 'helm-locate-library)

    ;; use helm to list eshell history
    (add-hook 'eshell-mode-hook
              #'(lambda ()
                  (define-key eshell-mode-map (kbd "M-l")  'helm-eshell-history)))

;;; Save current position to mark ring
    (add-hook 'helm-goto-line-before-hook 'helm-save-current-pos-to-mark-ring)

    ;; show minibuffer history with Helm
    (define-key minibuffer-local-map (kbd "M-p") 'helm-minibuffer-history)
    (define-key minibuffer-local-map (kbd "M-n") 'helm-minibuffer-history)

    (define-key global-map [remap find-tag] 'helm-etags-select)

    (define-key global-map [remap list-buffers] 'helm-buffers-list)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; PACKAGE: helm-swoop                ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Locate the helm-swoop folder to your path
    (use-package helm-swoop
      :bind (("C-c h o" . helm-swoop)
             ("C-c s" . helm-multi-swoop-all))
      :config
      ;; When doing isearch, hand the word over to helm-swoop
      (define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)

      ;; From helm-swoop to helm-multi-swoop-all
      (define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop)

      ;; Save buffer when helm-multi-swoop-edit complete
      (setq helm-multi-swoop-edit-save t)

      ;; If this value is t, split window inside the current window
      (setq helm-swoop-split-with-multiple-windows t)

      ;; Split direcion. 'split-window-vertically or 'split-window-horizontally
      (setq helm-swoop-split-direction 'split-window-vertically)

      ;; If nil, you can slightly boost invoke speed in exchange for text color
      (setq helm-swoop-speed-or-color t))

    (helm-mode 1)

    (use-package helm-projectile
      :init
      (helm-projectile-on)
      (setq projectile-completion-system 'helm)
      (setq projectile-indexing-method 'alien))))
;; ehelm

;; bggtags
(require 'ggtags)

;; (ggtags-mode 1)
(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode 'asm-mode)
              (ggtags-mode 1))))
(add-hook 'text-mode-hook (lambda() (ggtags-mode 1)))
(add-hook 'shell-mode-hook (lambda() (ggtags-mode 1)))

(dolist (map (list ggtags-mode-map ;; dired-mode-map
		   ))
  (define-key map (kbd "C-c g s") 'ggtags-find-other-symbol)
  (define-key map (kbd "C-c g h") 'ggtags-view-tag-history)
  (define-key map (kbd "C-c g r") 'ggtags-find-reference)
  (define-key map (kbd "C-c g f") 'ggtags-find-file)
  (define-key map (kbd "C-c g c") 'ggtags-create-tags)
  (define-key map (kbd "C-c g u") 'ggtags-update-tags)
  (define-key map (kbd "C-c g a") 'helm-gtags-tags-in-this-function)
  (define-key map (kbd "M-.") 'ggtags-find-tag-dwim)
  (define-key map (kbd "M-,") 'pop-tag-mark)
  (define-key map (kbd "C-c <") 'ggtags-prev-mark)
  (define-key map (kbd "C-c >") 'ggtags-next-mark))
;; eggtags

;; byasnippet
(require 'yasnippet)
(yas-global-mode 1)
;; eyasnippet

;; brpm
(autoload 'rpm-spec-mode "rpm-spec-mode.el" "RPM spec mode." t)
 (setq auto-mode-alist (append '(("\\.spec" . rpm-spec-mode))
                               auto-mode-alist))
;; erpm

;; -------------------------------------------------------------auto-generated----------------------------------------------------
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(initial-buffer-choice t)
 '(package-selected-packages
   (quote
    (yasnippet-snippets yasnippet ggtags ac-c-headers helm-projectile projectile use-package helm auto-complete rpm-spec-mode)))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "black" :foreground "dark gray" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 113 :width normal :foundry "PfEd" :family "DejaVu Sans Mono"))))
 '(font-lock-comment-face ((t (:foreground "lawn green")))))
