# Angel Velásquez <angvp[at]archlinux.org>
#
# Last update: mayo 03, 2012 (jueves, 11:38h) 
# First i've tried to move some of my bash stuff to zsh then I copied sort of
# stuff from people from #archlinux-tu.
#
# Thanks to Bluewind, jelly1 and CryptoCrack for let me see their configs .


# Aliases
alias ls='ls --color=auto -hF'
alias cp="cp -ri"
alias rm="rm -i"
alias mv="mv -i"
alias cls="clear"
alias vi="vim"
alias ll="ls -la"

#zsh options

# prompt
# see my theme on .oh-my-zsh/themes/angvp.theme

## some better colors for ls
eval "`dircolors ~/.dircolors`"

#keybindings

# Development
WORKON_HOME=~/virtualenvs
pythonvirtualenv() { source /usr/bin/virtualenvwrapper.sh }
perlvirtualenv() { source ~/perl5/perlbrew/etc/zshrc }
#functions
daemon() {
    sudo rc.d $2 $1;
}

vc() { # list content of archive but don't unpack
    if [ -f "$1" ]; then
         case "$1" in
       *.tar.bz2|*.tbz2|*.tbz)  tar -jtf "$1"     ;;
       *.tar.gz)                tar -ztf "$1"     ;;
       *.tar|*.tgz|*.tar.xz)    tar -tf  "$1"     ;;
       *.gz)                    gzip -l  "$1"     ;;    
       *.rar)                   rar vb   "$1"     ;;
       *.zip)                   unzip -l "$1"     ;;
       *.7z)                    7z l     "$1"     ;;
       *.lzo)                   lzop -l  "$1"     ;;  
       *.xz|*.txz|*.lzma|*.tlz) xz -l    "$1"     ;;
         esac
    else
        echo "Sorry, '$1' is not a valid archive.\nValid archive types are: \ntar.bz2, tar.gz, tar.xz, tar, gz, \ntbz2, tbz, tgz, lzo, rar \nzip, 7z, xz and lzma\n"
    fi
}

x() { # decompress an archive 
   if [ -f "$1" ] ; then
       case "$1" in
       *.tar.bz2|*.tgz|*.tbz2|*.tbz) tar xvjf   "$1"  ;;
       *.tar.gz)                     tar xvzf   "$1"  ;;
       *.tar.xz)                     tar xvJf   "$1"  ;;
       *.tar)                        tar xvf    "$1"  ;;
       *.rar)                        7z x       "$1"  ;;
       *.zip)                        unzip      "$1"  ;;
       *.7z)                         7z x       "$1"  ;;
       *.lzo)                        lzop -d    "$1"  ;;  
       *.gz)                         gunzip     "$1"  ;;
       *.bz2)                        bunzip2    "$1"  ;;
       *.Z)                          uncompress "$1"  ;;
       *.xz|*.txz|*.lzma|*.tlz)      xz -d      "$1"  ;; 
       *)               
       esac
   else
        echo "Sorry, '$1' is not a valid archive.\nValid archive types are: \ntar.bz2, tar.gz, tar.xz, tar, gz, \ntbz2, tbz, tgz, lzo, rar \nzip, 7z, xz and lzma\n"
   fi
}

if [ -f .banner ] ; then
    ./.banner
    cal
else
    cal
fi

#Packager functions
#- Arch Linux Maintainance stuff
PACKAGER="Angel Velasquez <angvp@archlinux.org>"
ARCH_HASKELL="Angel Velasquez <angvp@archlinux.org>"

alias mktesting="upchr testing/a64 && mkchr testing/a64 && upchr t32 && mkchr t32"
alias mkstable="mkchr a64 && mkchr a32"
alias mkstaging="upchr staging/a64 && mkchr staging/a64 && upchr s32 && mkchr s32"

ARCH_CHROOT_DIR="/opt/chroot"

upchr() {
    case "$1" in
        "a32") echo "Updating stable a32 arch chroot" ; linux32 sudo mkarchroot -u $ARCH_CHROOT_DIR/stable/a32/root/ ;;
        "a64") echo "Updating stable a64 arch chroot" ; sudo mkarchroot -u $ARCH_CHROOT_DIR/stable/a64/root/ ;;
        "t32") echo "Updating testing a32 arch chroot" ; linux32 sudo mkarchroot -u $ARCH_CHROOT_DIR/testing/a32/root/ ;;
        "t64") echo "Updating testing a64 arch chroot" ; sudo mkarchroot -u $ARCH_CHROOT_DIR/testing/a64/root/ ;;
        "s32") echo "Updating staging a32 arch chroot" ; linux32 sudo mkarchroot -u $ARCH_CHROOT_DIR/staging/a32/root/ ;;
        "s64") echo "Updating staging a64 arch chroot" ; sudo mkarchroot -u $ARCH_CHROOT_DIR/staging/a64/root/ ;;
        "all") echo "Updating all chroots on the system" ; upchr a32 ; upchr a64 ; upchr t32 ; upchr t64 ; upchr s32 ; upchr s64 ;;
    esac
}

mkchr() {
    case "$1" in
        "a32") echo "Building package using the stable 32bit chroot" ; linux32 sudo makechrootpkg -c -r $ARCH_CHROOT_DIR/stable/a32/ ;;
        "a64") echo "Building package using the stable 64bit chroot" ; sudo makechrootpkg -c -r $ARCH_CHROOT_DIR/stable/a64/ ;;
        "t32") echo "Building package using the testing 32bit chroot" ; linux32 sudo makechrootpkg -c -r $ARCH_CHROOT_DIR/testing/a32/ ;;
        "t64") echo "Building package using the testing 64bit chroot" ; sudo makechrootpkg -c -r $ARCH_CHROOT_DIR/testing/a64/ ;;
        "s32") echo "Building package using the staging 32bit chroot" ; linux32 sudo makechrootpkg -c -r $ARCH_CHROOT_DIR/staging/a32/ ;;
        "s64") echo "Building package using the staging 64bit chroot" ; sudo makechrootpkg -c -r $ARCH_CHROOT_DIR/staging/a64/ ;;
    esac
}

create_chroots() {
    case "$1" in
        "stable") 
            if [[ -f $ARCH_CHROOT_DIR/$1/a32 || -f $ARCH_CHROOT_DIR/$1/a64 ]]; then 
                echo "Chroots exists on $ARCH_CHROOT_DIR" 
            else 
                sudo mkdir -p $ARCH_CHROOT_DIR/$1/{a32,a64} &&
                sudo mkarchroot $ARCH_CHROOT_DIR/stable/a64/root base base-devel sudo &&
                sudo $EDITOR $ARCH_CHROOT_DIR/$1/a64/root/etc/pacman.d/mirrorlist &&
                # 32 bit chroot
                sed -e 's@/etc/pacman.d/mirrorlist@/tmp/mirrorlist@g' /opt/chroot/$1/a64/root/etc/pacman.conf > /tmp/pacman.conf
                sudo linux32 mkarchroot /opt/chroot/$1/a32/root base base-devel sudo
            fi
        ;;
        "testing"|"staging")
            if [[ -f $ARCH_CHROOT_DIR/$1/a32 || -f $ARCH_CHROOT_DIR/$1/a64 ]]; then 
                echo "Chroots exists on $ARCH_CHROOT_DIR" 
            else 
                sudo mkdir -p $ARCH_CHROOT_DIR/$1/{a32,a64} && 
                sudo mkarchroot $ARCH_CHROOT_DIR/$1/a64/root base base-devel sudo &&
                sudo $EDITOR $ARCH_CHROOT_DIR/$1/a64/root/etc/pacman.conf
                sudo $EDITOR $ARCH_CHROOT_DIR/$1/a64/root/etc/pacman.d/mirrorlist
                # 32 bit chroot
                sed -e 's@/etc/pacman.d/mirrorlist@/tmp/mirrorlist@g' /opt/chroot/$1/a64/root/etc/pacman.conf > /tmp/pacman.conf &&
                sudo linux32 mkarchroot /opt/chroot/$1/a32/root base base-devel sudo
                sudo $EDITOR $ARCH_CHROOT_DIR/$1/a32/root/etc/pacman.conf
                sudo $EDITOR $ARCH_CHROOT_DIR/$1/a32/root/etc/pacman.d/mirrorlist
            fi
        ;;
        "all")
            create_chroots stable && create_chroots testing && create_chroots staging
        ;;
esac
}
# Remove every .pyc file from the current path.
delpyc() {
    find . -name "*.pyc" -delete
}

signpkg() {
    for pkg in *.pkg.tar.xz; do gpg --detach-sign $pkg; done
}

delswp() {
    find . -name "*.swp" -delete
}

# Let's load some aliases to work
#source ~/work.zshrc

# oh my zsh stuff

ZSH=$HOME/.oh-my-zsh
ZSH_THEME="angvp"
plugins=(git screen)
source $ZSH/oh-my-zsh.sh

unsetopt correct_all

bindkey "\e[5~" history-search-backward
bindkey "\e[6~" history-search-forward
bindkey "\e[7~" beginning-of-line # Home 
bindkey "\e[8~" end-of-line # End

# Exports
## history stuff
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
## path
PATH=$PATH:/usr/local/bin:$HOME:/usr/bin:$HOME/bin
#other stuff
GTK2_RC_FILES=$HOME/.gtkrc-2.0
PATH=$PATH:/usr/local/bin:$HOME:/usr/bin:$HOME/bin
#editor
EDITOR="vim"
VISUAL="vim"
PAGER=most
MANPAGER=most
mail=~/.mail
IGNOREEOF=3
GPG_TTY=$(tty)
LANG=es_VE.utf8
LC_ALL=es_VE.UTF-8
export GPG_TTY
export LANG