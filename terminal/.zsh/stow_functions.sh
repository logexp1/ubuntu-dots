# as of stow 2.2.2, READMEs are automatically ignored
restow() {
	cd ~/ubuntu-dots && \
		stow -Rvt ~/ emacs terminal wm remap
}

unstow() {
	cd ~/mydots && \
		stow -Dvt ~/ emacs terminal wm remap
}
