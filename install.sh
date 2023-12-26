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

backup()
{
  if ! [ -d $HOME/.backup ];
  then
    mkdir -p $HOME/.backup
  fi

  local DIR=$1
  cp -r $DIR $HOME/.backup/
  echo "[*] $DIR backed up to $HOME/.backup"
}

#|-----< Script start >-----|#
cat<<"EOF"

┬┌─┌┬┐┌─┐ ┌┬┐┌─┐┌┬┐┌─┐
├┴┐ ││├┤───│││ │ │ └─┐
┴ ┴─┴┘└─┘ ─┴┘└─┘ ┴ └─┘

EOF

#|-----< Check git >-----|#
echo "[*] Updating system ..."
sudo pacman -Syu

echo "[*] Installing git ..."
if pkg_installed git
then
  echo "[*] Git already installed, skipping ..."
else
  sudo pacman -S git less
  echo "[*] Git Installed."
fi
sleep 1
#|-----< Check yay >-----|#

if ! [ -d $CLONE_DIR ];
then
  mkdir -p $CLONE_DIR
fi

echo "[*] Installing AUR helper(yay) ..."
if pkg_installed yay
then
  echo "[*] Yay already installed, skipping ..."
else
  sudo pacman -S --needed base-devel
  git clone https://aur.archlinux.org/yay.git $CLONE_DIR/yay/
  cd $CLONE_DIR/yay
  makepkg -si
  echo "[*] Yay Installed."
fi

#|-----< Cloning repo >-----|#
echo "[*] Cloning dots in $CLONE_DIR ..."

git clone https://github.com/re1san/Kde-Dots.git $CLONE_DIR/Kde-Dots/

echo "[*] Dots cloned."

#|-----< Install necessary dependencies >-----|#
echo "[*] Installing dependencies ..."

sudo pacman -S cmake extra-cmake-modules kdecoration qt5-declarative qt5-x11extras

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
make
sudo make install
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
./install.sh -black
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
# cp -r walls/* $HOME/.local/share/wallpapers/ # Walls of mori branch dont want

echo "[*] Done."

#|-----< Latte-dock >-----|#

echo "[*] Installing latte-dock ..."
sudo pacman -S latte-dock 
if ! [ -d $HOME/.config/latte ];
then
  mkdir -p $HOME/.config/latte
fi
cp config/latte/* $HOME/.config/latte/
#latte-dock --import-layout $HOME/.config/latte/Mori.layout.latte
echo "[*] Done."

echo "[*] Installing latte seperator ..."
yay -S plasma5-applets-latte-separator
echo "[*] Done."

#|-----< Go to Nya branch for terminal configs >-----|#

git switch nya
echo "[*] Installing terminal configs ..."
sudo pacman -S kitty neofetch zsh starship imagemagick
yay -S cava
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

if ! [ -d $HOME/.zsh ];
then
  mkdir -p $HOME/.zsh
fi

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

if [ -f $HOME/.zshrc ];
then
  backup $HOME/.zshrc
fi

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

#|-----< Firefox >-----|#
read -p "[*] Do you want to install Firefox and its config? (y/n): " choice

if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo "Installing Firefox ..."
    sudo pacman -S firefox
    echo "[*] Installing Firefox config ..."
    firefox &     #
    sleep 3       #
    pkill firefox # To create the directory of *.default-release
    cp -r firefox-css/* $HOME/.mozilla/firefox/*.default-release/
    echo "[*] Done."
else
    echo "[*] Firefox installation skipped."
fi

read -p "[*] Do you want to install Spotify and its config? (y/n): " choice

if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo "Installing Spotify ..."
    yay -S spotify spicetify-cli
    echo "[*] Installing Spicetify config ..."
    sudo chmod a+wr /opt/spotify
    sudo chmod a+wr /opt/spotify/Apps -R

    cp -r spicetify/* $HOME/.config/spicetify/Themes/
    # spicetify config current_theme Snow
    # spicetify backup apply # Manually as needs login!
    echo "[*] Done."
else
    echo "[*] Spotify installation skipped."
fi

echo "[*] Wrapping up ..."

echo "[*] Launching Latte-dock ..."
latte-dock --import-layout $HOME/.config/latte/Mori.layout.latte &

# IG Just do it manually ...
echo "[*] Applying plasma themes ..."

#plasma-apply-wallpaperimage $HOME/.local/share/wallpapers/nya.png
#plasma-apply-colorscheme $HOME/.local/share/color-schemes/MoriDark.colors
#plasma-apply-desktoptheme $HOME/.local/share/plasma/desktoptheme/Mori
#plasma-apply-cursortheme $HOME/.local/share/icons/Mori_Snow

cat<<"EOF"

┌┬┐┌─┐┌┐┌┌─┐
 │││ ││││├┤ 
─┴┘└─┘┘└┘└─┘

EOF

echo "Follow the README for next steps, Thankyou!"
