;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(package! aggressive-indent)
(package! beacon)
(package! visual-fill-column)
;; When using org-roam via the `+roam` flag
;; (unpin! org-roam company-org-roam)
(package! org-roam-bibtex
  :recipe (:host github :repo "org-roam/org-roam-bibtex"))
(package! org-roam-ui)
(package! org-clock-convenience)
;; When using bibtex-completion via the `biblio` module
;; (unpin! bibtex-completion helm-bibtex ivy-bibtex)
;; (unpin! org-ref)
(package! org-ref)
(package! ox-gfm)
(package! anki-editor)
(package! elfeed)
(package! mw-thesaurus)
(package! dired-quick-sort)
(package! dired-atool)
(package! dired-toggle-sudo)
(package! dired-ranger)
(package! trashed)
(package! nov
  :recipe (:type git :repo "https://depp.brause.cc/nov.el.git"))
(package! justify-kp
  :recipe (:host github :repo "Fuco1/justify-kp"))
(package! mathpix.el
  :recipe (:host github :repo "jethrokuan/mathpix.el"))
(package! pyvenv)
(package! ob-async)
;; (package! jupyter
;;   :recipe (:host github :repo "nnicandro/emacs-jupyter"))
;; (package! org-alert)
;; slack client for emacs
(package! slack)
;; (package! ox-slack)
(package! copy-as-format)

(package! yuck-mode
  :recipe (:host github :repo "mmcjimsey26/yuck-mode" :files ("yuck-mode.el")))

(package! kbd-mode
  :recipe (:host github
           :repo "kmonad/kbd-mode"))

(package! vscode-icon)
(package! fcitx)

;; (package! treesit-auto)
(package! plz)
(package! org-present
  :recipe (:host github :repo "rlister/org-present"))

(package! ox-jira)

;; (package! gptel)
(package! ellama)

(package! gitconfig-mode
  :recipe (:host github :repo "magit/git-modes"
	   :files ("gitconfig-mode.el")))
(package! gitignore-mode
  :recipe (:host github :repo "magit/git-modes"
	   :files ("gitignore-mode.el")))

(package! kubel)
(package! kubel-evil)
;; (package! kubed)

(package! kubedoc)

(package! yaml-pro)
