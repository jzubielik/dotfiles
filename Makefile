DEPS := curl gnupg tmux vim zsh
MAKEFLAGS+=--silent
OSTYPE := $(shell uname -s)

deps:
	@echo "********\033[1m Installing dependencies \033[0m********"
	if [ $(OSTYPE) = "Linux" ]; then \
		for PKG in $(DEPS); do \
			dpkg -l | grep $$PKG | grep -c ii >/dev/null || \
			sudo apt-get install -y $$PKG; \
		done; \
	elif [ $(OSTYPE) = "Darwin" ]; then \
		which brew >/dev/null || \
			sh -c "ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""; \
		for PKG in $(DEPS); do \
			brew list -1 | grep "^$$PKG$$" >/dev/null || \
			brew install $$PKG; \
		done; \
	fi

home: deps
	@echo "********\033[1m Building home \033[0m******************"
	[ -d ~/.yadr ] || \
		sh -c "`curl -fsSL https://raw.githubusercontent.com/skwp/dotfiles/master/install.sh`" && \
	[ -f ~/.zsh.prompts/prompt_mudasobwa_setup ] || \
		curl -sSL https://gist.githubusercontent.com/jzubielik/968aa4dc52e0efc030de/raw -o \
		~/.zsh.prompts/prompt_mudasobwa_setup && \
	[ -f ~/.zsh.prompts/prompt_paradox_setup ] || \
		curl -sSL https://raw.githubusercontent.com/paradox460/prezto/paradox/modules/prompt/functions/prompt_paradox_setup -o \
		~/.zsh.prompts/prompt_paradox_setup && \
	[ -d ~/.vim/colors ] || mkdir ~/.vim/colors && \
	[ -f ~/.vim/colors/molokai.vim ] || \
		curl -sSL https://raw.githubusercontent.com/jzubielik/molokai/master/colors/molokai.vim -o \
		~/.vim/colors/molokai.vim && \
	echo "autoload -Uz promptinit\n\
promptinit\n\
prompt paradox\n\
set -o emacs" \
> ~/.zsh.after/profile.zsh && \
	[ -d ~/.vim/bundle/vim-airline ] || \
		~/.yadr/bin/yadr/yadr-vim-add-plugin -u https://github.com/vim-airline/vim-airline && \
	[ -d ~/.vim/bundle/vim-airline-themes ] || \
		~/.yadr/bin/yadr/yadr-vim-add-plugin -u https://github.com/vim-airline/vim-airline-themes && \
	grep -c "airline" ~/.vimrc.before >/dev/null 2>&1 || \
		echo "set laststatus=2\n\
let g:airline_theme = 'luna'\n\
let g:airline_powerline_fonts = 1" \
> ~/.vimrc.before
	grep -c "molokai" ~/.vimrc.after >/dev/null 2>&1 || \
		echo "let g:rehash256 = 1\n\
let g:molokai_transparent = 1\n\
colorscheme molokai\n\
\n\
set cul\n\
set cuc" \
> ~/.vimrc.after && \
	[ -d ~/.local/share/fonts ] || \
		(git clone https://github.com/powerline/fonts.git ~/.tmp-fonts && \
		 sh -c "cd ~/.tmp-fonts && bash ./install.sh" && \
		 rm -rf ~/.tmp-fonts && \
		 fc-cache -vf ~/.local/share/fonts)

test:
	docker build . -t home-test:latest && \
	docker run -it --rm \
		-v $PWD:/src \
		-p 1022:22 \
		home-test:latest \
		bash -c "cd /src && make home"
