#!/bin/bash

#|-----< Global vars >-----|#
CLONE_DIR="$HOME/Downloads"

#|-----< Helper functions >-----|#

pkg_installed() 
{
  local PKG=$1
  if pacman -Qi $PKG &> /dev/null
  then
    # found
    return 0
  else
    # not found
    return 1 
  fi
}

reset()
{
  cd $CLONE_DIR/Kde-Dots
}

#|-----< Script start >-----|#
cat<<"EOF"

┬┌─┌┬┐┌─┐ ┌┬┐┌─┐┌┬┐┌─┐
├┴┐ ││├┤───│││ │ │ └─┐
┴ ┴─┴┘└─┘ ─┴┘└─┘ ┴ └─┘

EOF

#|-----< Check git >-----|#
echo "[*] Installing git ..."
if pkg_installed git
then
  echo "[*] Git already installed, skipping ..."
else
  sudo pacman -S git
  echo "[*] Git Installed."
fi

#|-----< Cloning repo >-----|#
echo "[*] Cloning dots in $CLONE_DIR ..."

if ! [ -d $CLONE_DIR ];
then
  mkdir -p $CLONE_DIR
fi

git clone https://github.com/re1san/Kde-Dots.git $CLONE_DIR/Kde-Dots/

echo "[*] Dots cloned."

#|-----< Install necessary dependencies >-----|#
echo "[*] Installing dependencies ..."

sudo pacman -S cmake extra-cmake-modules kdecoration qt5-declarative qt5-x11extras less

echo "[*] Deps installed."

#|-----< Build applets >-----|#
echo "[*] Installing clock applet ..."

if ! [ "$(pwd)" == "$CLONE_DIR/Kde-Dots" ];
then
  reset
fi

git switch mori && cd clock-applet

mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=`kf5-config --prefix` -DCMAKE_BUILD_TYPE=Release -DLIB_INSTALL_DIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON ../
make && sudo make install
cd .. && rm -rf build
reset # In kde-dots dir
echo "[*] Clock Applet installed."

echo "[*] Installing application style ..."
cd kstyle-theme
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_TESTING=OFF ..
make
sudo make install
cd .. && rm -rf build
reset
echo "[*] Application style installed."

echo "[*] Installing window decorations ..."
cd window-deco
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DBUILD_TESTING=OFF -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make
sudo make install
cd .. && rm -rf build
reset
echo "[*] Window Decorations installed."

echo "[*] Installing Reversal dark icons ..."
git clone --depth 1 https://github.com/yeyushengfan258/Reversal-icon-theme.git
cd Reversal-icon-theme
chmod +x install.sh
./install.sh black
reset
echo "[*] Done."

#|-----< Configs >-----|#

echo "[*] Copying config files ..."
if ! [ -d $HOME/.local/share/color-scheme ];
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

echo "[*] Done."

#|-----< Latte-dock >-----|#

echo "[*] Installing latte-dock ..."
sudo pacman -S latte-dock
if ! [ -d $HOME/.config/latte ];
then
  mkdir -p $HOME/.config/latte
fi
cp -r config/latte/* $HOME/.config/latte/*
echo "[*] Done."

#|-----< Go to Nya branch for terminal configs >-----|#

git switch nya
echo "[*] Installing terminal configs ..."
sudo pacman -S kitty neofetch zsh starship eza imagemagick
cp -r config/* $HOME/.config/

if ! [ -d $HOME/.zsh ];
then
  mkdir -p $HOME/.zsh
fi

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

cp home/.zshrc $HOME/
echo "[*] Done."

#|-----< Fonts >-----|#

echo "[*] Adding fonts and nya wall ..."
if ! [ -d $HOME/.local/share/fonts ];
then
  mkdir -p $HOME/.local/share/fonts
fi
sudo pacman -S ttf-iosevka-nerd
cp -r fonts/*  $HOME/.local/share/fonts/
cp -r wall/* $HOME/.local/share/wallpapers/

echo "[*] Wrapping up ..."

cat<<"EOF"

┌┬┐┌─┐┌┐┌┌─┐
 │││ ││││├┤ 
─┴┘└─┘┘└┘└─┘

EOF

echo "Follow the README for next steps, Thankyou."