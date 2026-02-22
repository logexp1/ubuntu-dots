# as of stow 2.2.2, READMEs are automatically ignored
restow() {
	cd ~/ubuntu-dots && \
		stow -Rvt ~/ emacs terminal wm remap common scripts
}

unstow() {
	cd ~/ubuntu-dots && \
		stow -Dvt ~/ emacs terminal wm remap common scripts
}
