#!/bin/bash

#|-----< Global vars >-----|#
CLONE_DIR="$HOME/Downloads"
on_success="OKI"
on_fail="ERR"
white="\e[1;37m"
green="\e[1;32m"
red="\e[1;31m"
nc="\e[0m"

#|-----< Log file >-----|#
touch foo.log

#|-----< Spinner >-----|#
_spinner() {
    # $1 start/stop
    #
    # on start: $2 - Display message
    # on stop : $2 - Process exit status
    #           $3 - Spinner function pid (supplied from stop_spinner)
    case $1 in
        start)
            echo -ne ":: ${2}  "

            # Start spin
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "Spinner is not running ..."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # Inform the user uppon success or failure
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "Invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

start_spinner() {
    # $1 : Msg to display
    _spinner "start" "${1}" &
    # Set global spinner pid
    _sp_pid=$!
    disown
}

stop_spinner() {
    # $1 : Command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}


#|-----< Helper functions >-----|#

pkg_installed() {
  local PKG=$1
  if pacman -Qi $PKG &> /dev/null
  then
    # Found
    return 0
  else
    # Not found
    return 1 
  fi
}

reset() {
  cd $CLONE_DIR/Kde-Dots
}

backup() {
  if ! [ -d $HOME/.backup ];
  then
    mkdir -p $HOME/.backup
  fi

  local DIR=$1
  cp -r $DIR $HOME/.backup/
  echo ":: $DIR backed up to $HOME/.backup ${green}${on_success}${nc}"
}

build_applets_icons() {
	cd clock-applet
	mkdir build && cd build
	start_spinner 'Building clock applet'
	cmake -DCMAKE_INSTALL_PREFIX=`kf5-config --prefix` -DCMAKE_BUILD_TYPE=Release -DLIB_INSTALL_DIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON ../ > foo.log 2>&1
	stop_spinner $?
	start_spinner 'Making clock applet'
	make >> foo.log 2>&1
	stop_spinner $?
	start_spinner 'Installing clock applet'
	sudo make install >> foo.log 2>&1
	stop_spinner $?
	cd .. && rm -rf build
	reset # In kde-dots dir

	cd kstyle-theme
	mkdir build && cd build
	start_spinner 'Building k-style'
	cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_TESTING=OFF .. >> foo.log 2>&1
	stop_spinner $?
	start_spinner 'Making k-style'
	make >> foo.log 2>&1
	stop_spinner $?
	start_spinner 'Installing k-style'
	sudo make install >> foo.log 2>&1
	stop_spinner $?
	cd .. && rm -rf build
	reset

	cd window-deco
	mkdir build && cd build
	start_spinner 'Building window decorations'
	cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DBUILD_TESTING=OFF -DKDE_INSTALL_USE_QT_SYS_PATHS=ON >> foo.log 2>&1
	stop_spinner $?
	start_spinner 'Making window decorations'
	make >> foo.log 2>&1
	stop_spinner $?
	start_spinner 'Installing window decorations'
	sudo make install >> foo.log 2>&1
	stop_spinner $? 
	cd .. && rm -rf build
	reset

	start_spinner 'Cloning reversal dark icons'
	git clone --depth 1 https://github.com/yeyushengfan258/Reversal-icon-theme.git >> foo.log 2>&1
	stop_spinner $? 
	cd Reversal-icon-theme
	chmod +x install.sh
	start_spinner 'Installing reversal dark icons'
	./install.sh -black >> foo.log 2>&1
	stop_spinner $? 
	reset
}

copy_configs() {
	if ! [ -d $HOME/.local/share/color-schemes ];
	then
	mkdir -p $HOME/.local/share/color-schemes
	fi
	cp -r color-schemes/* $HOME/.local/share/color-schemes/

	if ! [ -d $HOME/.local/share/icons ];
	then
	mkdir -p $HOME/.local/share/icons
	fi
	cp -r cursors/* $HOME/.local/share/icons/

	if ! [ -d $HOME/.themes ];
	then
	mkdir -p $HOME/.themes
	fi
	cp -r gtk/* $HOME/.themes

	if ! [ -d $HOME/.local/share/plasma/desktoptheme ];
	then
	mkdir -p $HOME/.local/share/plasma/desktoptheme
	fi
	cp -r plasma/desktoptheme/* $HOME/.local/share/plasma/desktoptheme/

	if ! [ -d $HOME/.local/share/wallpapers ];
	then
	mkdir -p $HOME/.local/share/wallpapers
	fi
	cp -r walls/* $HOME/.local/share/wallpapers/

  # Backup existing configs
  if [ -d $HOME/.config/kitty ];
  then
    backup $HOME/.config/kitty 
  fi
  if [ -d $HOME/.config/neofetch ];
  then
    backup $HOME/.config/neofetch
  fi

  cp -r config/* $HOME/.config/

  cp home/.zshrc $HOME/
}

zsh_setup() {
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting 
}

iosevka() {
  reset
  curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.tar.xz
  tar -xvf Iosevka.tar.xz -C ~/.local/share/fonts/Iosevka
}

fonts_setup() {
  if ! [ -d $HOME/.local/share/fonts ];
  then
    mkdir -p $HOME/.local/share/fonts
  fi
  cp -r fonts/*  $HOME/.local/share/fonts/

  iosevka
}

#|-----< Deps for different Distros >-----|#
deps_arch() {
  #|-----< Check git >-----|#
  echo ":: Updating system ..."
  sudo pacman -Syu

  echo ":: Installing git ..."
  if pkg_installed git
  then
    echo ":: Git already installed, skipping ..."
  else
    sudo pacman -S git less
    echo -e ":: Git Installed [${green}${on_success}${nc}]"
  fi
  sleep 1
  #|-----< Check yay >-----|#

  if ! [ -d $CLONE_DIR ];
  then
    mkdir -p $CLONE_DIR
  fi

  echo ":: Installing AUR helper(yay) ..."
  if pkg_installed yay
  then
    echo ":: Yay already installed, skipping ..."
  else
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/yay.git $CLONE_DIR/yay/
    cd $CLONE_DIR/yay
    makepkg -si
    echo -e ":: Yay Installed [${green}${on_success}${nc}]"
  fi

  #|-----< Install necessary dependencies >-----|#
  echo ":: Installing dependencies ..."

  sudo pacman -S cmake extra-cmake-modules kdecoration qt5-declarative qt5-x11extras kitty neofetch zsh starship imagemagick latte-dock neovim
  yay -S cava plasma5-applets-latte-separator

  echo -e ":: Deps installed [${green}${on_success}${nc}]"
}

deps_ubuntu() {
  #|-----< Check git >-----|#
  echo ":: Updating system ..."
  sudo apt-get update

  echo ":: Installing git ..."
  sudo apt install git
  echo -e ":: Git Installed [${green}${on_success}${nc}]"
  sleep 1
  #|-----< Clone dir >-----|#

  if ! [ -d $CLONE_DIR ];
  then
    mkdir -p $CLONE_DIR
  fi

  #|-----< Install necessary dependencies >-----|#
  echo ":: Installing dependencies ..."

  sudo apt install cmake build-essential libkf5config-dev libkdecorations2-dev libqt5x11extras5-dev qtdeclarative5-dev extra-cmake-modules libkf5guiaddons-dev libkf5configwidgets-dev libkf5windowsystem-dev libkf5coreaddons-dev libkf5iconthemes-dev gettext qt3d5-dev
  sudo apt install kitty neofetch zsh imagemagick latte-dock cava neovim
  curl -sS https://starship.rs/install.sh | sh

  echo -e ":: Deps installed [${green}${on_success}${nc}]"
}

deps_opensuse() {
  #|-----< Check git >-----|#
  echo ":: Updating system ..."
  sudo zypper refresh

  echo ":: Installing git ..."
  sudo zypper install git
  echo -e ":: Git Installed [${green}${on_success}${nc}]"
  sleep 1
  #|-----< Clone dir >-----|#

  if ! [ -d $CLONE_DIR ];
  then
    mkdir -p $CLONE_DIR
  fi

  #|-----< Install necessary dependencies >-----|#
  sudo zypper install cmake gcc-c++ extra-cmake-modules libQt5Gui-devel libQt5DBus-devel libqt5-qttools-devel libqt5-qtx11extras-devel libQt5OpenGL-devel libQt5Network-devel libepoxy-devel kconfig-devel kconfigwidgets-devel kcrash-devel kglobalaccel-devel ki18n-devel kio-devel kservice-devel kinit-devel knotifications-devel kwindowsystem-devel kguiaddons-devel kiconthemes-devel kpackage-devel kwin5-devel xcb-util-devel xcb-util-cursor-devel xcb-util-wm-devel xcb-util-keysyms-devel
  sudo zypper install kitty neofetch zsh ImageMagick latte-dock cava neovim
  curl -sS https://starship.rs/install.sh | sh
  echo -e ":: Deps installed [${green}${on_success}${nc}]"
}


#|-----< Firefox, Spotify >-----|#
#
#  NOTE: Only supported for Arch linux, open for contribs :)
#
firefox_spotify() {
  #|-----< Firefox >-----|#
  read -p "?: Do you want to install Firefox and its config? (y/n): " choice

  if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
      echo "Installing Firefox ..."
      sudo pacman -S firefox
      echo ":: Installing Firefox config ..."
      firefox &     #
      sleep 3       #
      pkill firefox # To create the directory of *.default-release
      cp -r firefox-css/* $HOME/.mozilla/firefox/*.default-release/
      echo -e ":: [${green}Done${nc}]"
  else
      echo ":: Firefox installation skipped"
  fi

  read -p "?: Do you want to install Spotify and its config? (y/n): " choice

  if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
      echo "Installing Spotify ..."
      yay -S spotify spicetify-cli
      echo ":: Installing Spicetify config ..."
      sudo chmod a+wr /opt/spotify
      sudo chmod a+wr /opt/spotify/Apps -R

      cp -r spicetify/* $HOME/.config/spicetify/Themes/
      # spicetify config current_theme Snow
      # spicetify backup apply # Manually as needs login!
      echo -e ":: [${green}Done${nc}]"
  else
      echo ":: Spotify installation skipped"
  fi
}

#|-----< Script start >-----|#
cat<<"EOF"

┬┌─┌┬┐┌─┐ ┌┬┐┌─┐┌┬┐┌─┐
├┴┐ ││├┤───│││ │ │ └─┐
┴ ┴─┴┘└─┘ ─┴┘└─┘ ┴ └─┘

EOF

#|-----< Check Distro >-----|#
DISTRO=$(awk -F= '/^ID=/{print $2}' /etc/os-release | tr -d '"')

case $DISTRO in
    arch)
        echo -e ":: Distro found ${DISTRO}"
        deps_arch
        ;;
    ubuntu)
        echo -e ":: Distro found ${DISTRO}"
        deps_ubuntu
        ;;
    opensuse)
        echo -e ":: Distro found ${DISTRO}"
        deps_opensuse
        ;;
    *)
        echo -e ":: ${red}${DISTRO}${nc} is unsupported for now :("
        echo -e ":: Contact ${green}re1san${nc} on github :)"
        exit 1
        ;;
esac



#|-----< Cloning repo >-----|#
echo ":: Cloning dots in $CLONE_DIR ..."

git clone https://github.com/re1san/Kde-Dots.git $CLONE_DIR/Kde-Dots/

echo -e ":: Dots cloned [${green}${on_success}${nc}]"

#|-----< Build applets >-----|#
echo ":: Logs will be written in foo.log ^^"

if ! [ "$(pwd)" == "$CLONE_DIR/Kde-Dots" ];
then
  reset
fi

git switch tsuki

build_applets_icons

#|-----< Setup zsh >-----|#

if ! [ -d $HOME/.zsh ];
then
  mkdir -p $HOME/.zsh
fi
start_spinner 'Setting up zsh'
zsh_setup >> foo.log 2>&1
stop_spinner $?

#|-----< Configs >-----|#
start_spinner 'Copying config files'
copy_configs >> foo.log 2>&1
stop_spinner $?

#|-----< Fonts >-----|#

start_spinner 'Copying fonts'
fonts_setup >> foo.log 2>&1
stop_spinner $?

#|-----< Fox, Spotify >-----|#
case $DISTRO in
    arch)
      firefox_spotify
        ;;
    # ubuntu)
    #     ;;
    # opensuse)
    #     ;;
    # *)
    #     ;;
esac

#|-----< Nvim Config >-----|#

read -p "?: Do you want to install Neovim config? (y/n): " choice

if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    git clone https://github.com/re1san/Kode ~/.config/nvim --depth 1
    echo -e ":: [${green}Done${nc}], please open neovim by command 'nvim' after completion of script to install all plugins and colorscheme"
else
    echo ":: Neovim config installation skipped"
fi

cat<<"EOF"

┌┬┐┌─┐┌┐┌┌─┐
 │││ ││││├┤ 
─┴┘└─┘┘└┘└─┘

EOF

echo -e "${green}Follow the README for next steps, Thankyou! ^^${nc}"
