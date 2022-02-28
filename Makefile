export DOTFILES_IS_LIGHTWEIGHT=0
export DOTFILES_WITH_APPS=1
export DOTFILES_WITH_ASDF=1
export DOTFILES_WITH_BREW=1
export DOTFILES_WITH_LSP=1
export DOTFILES_WITH_VIRT=1

ifdef DOTFILES_DEBUG
DOTFILES_INSTALL_FLAGS += -vv
endif

BASH_SCRIPTS := $(shell grep -lRE '^\#.*bash' scripts tmux/scripts)
PERL_SCRIPTS := $(shell grep -lRE '^\#.*perl' scripts tmux/scripts)

help: ## Print command list
	@perl -nle'print $& if m{^[a-zA-Z0-9_-]+:.*?## .*$$}' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

_dotfiles:
	@./install $(DOTFILES_INSTALL_FLAGS)

macos: _dotfiles ## Setup macOS
	@./etc/macos

fedora-server: DOTFILES_WITH_APPS=0
fedora-server: DOTFILES_WITH_BREW=0
fedora-server: _dotfiles ## Setup Fedora server

unix-server: DOTFILES_WITH_APPS=0
unix-server: DOTFILES_WITH_LSP=0
unix-server: _dotfiles ## Setup UNIX server

unix-server-light: DOTFILES_IS_LIGHTWEIGHT=1
unix-server-light: DOTFILES_WITH_APPS=0
unix-server-light: DOTFILES_WITH_BREW=0
unix-server-light: DOTFILES_WITH_LSP=0
unix-server-light: DOTFILES_WITH_VIRT=0
unix-server-light: _dotfiles ## Setup UNIX server (light)

check: ## Check shell/perl scripts (requires shellcheck and Perl::Critic)
	@shellcheck \
		etc/macos \
		fzf/*.sh \
		shell/*.sh \
		$(BASH_SCRIPTS)
	@perlcritic $(PERL_SCRIPTS)
