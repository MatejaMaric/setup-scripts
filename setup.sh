#!/bin/bash

qtile_install=false;
config_install=false;
termite_install=false;
neovim_install=false;
latex_install=false;
non_free=false;
nvidia_install=false;

read -p "Do you want to install Qtile? " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] && $qtile_install=true;

read -p "Do you want to install configurations? " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] && $config_install=true;

read -p "Do you want to install termite? " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] && $termite_install=true;

read -p "Do you want to install Neovim? " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] && $neovim_install=true;

read -p "Do you want to install LaTeX? " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] && $latex_install=true;

read -p "Do you want to enable non-free repos?" -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] && $non_free=true;

if [[ $non_free ]]
then
read -p "Do you want to install proprietary nvidia drivers? " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] && $nvidia_install=true;
fi

# Adding non-free repos if necessary.
if [[ $non_free ]]
then
cat > /tmp/sources.list <<EOF
deb http://deb.debian.org/debian/ buster main contrib non-free
deb-src http://deb.debian.org/debian/ buster main contrib non-free

deb http://security.debian.org/debian-security buster/updates main contrib non-free
deb-src http://security.debian.org/debian-security buster/updates main contrib non-free

deb http://deb.debian.org/debian/ buster-updates main contrib non-free
deb-src http://deb.debian.org/debian/ buster-updates main contrib non-free

deb http://deb.debian.org/debian/ buster-backports main
deb-src http://deb.debian.org/debian/ unstable main contrib non-free
EOF

else
cat > /tmp/sources.list <<EOF
deb http://deb.debian.org/debian/ buster main
deb-src http://deb.debian.org/debian/ buster main

deb http://security.debian.org/debian-security buster/updates main
deb-src http://security.debian.org/debian-security buster/updates main

deb http://deb.debian.org/debian/ buster-updates main
deb-src http://deb.debian.org/debian/ buster-updates main

deb http://deb.debian.org/debian/ buster-backports main
deb-src http://deb.debian.org/debian/ unstable main
EOF
fi

sudo cp /tmp/sources.list /etc/apt/sources.list
sudo apt update
sudo apt upgrade

echo "Installing basic software..."
sudo apt install -y gpg keychain git pass build-essential
sudo apt install -y unzip wget curl


echo "Installing Xorg..."
sudo apt install -y xorg xorg-drivers xinit xterm pinentry-gtk-2
[[ $nvidia_install ]] && sudo apt install nvidia-driver


if [[ $qtile_install ]]
then
  echo "Installing Qtile..."
  sudo apt install -y libxcb-render0-dev libffi-dev libcairo2 libpangocairo-1.0-0 python-dbus
  sudo apt install -y python3-pip

  [[ ! -d $HOME/programs ]] && mkdir $HOME/programs
  cd $HOME/programs

  git clone https://github.com/qtile/qtile
  cd qtile

  pip3 install -r requirements.txt
  pip3 install .


cat > /tmp/qtile.desktop <<EOF
[Desktop Entry]
Name=Qtile
Comment=Qtile Window Menager
Exec=/home/$USER/.local/bin/qtile
Type=Application
Keywords=wm;tiling
EOF

  sudo cp /tmp/qtile.desktop /usr/share/xsessions/qtile.desktop
  sudo chown root:root /usr/share/xsessions/qtile.desktop
  sudo chmod 644 /usr/share/xsessions/qtile.desktop
fi


echo "Installing additional software..."
sudo apt install -y numlockx pcmanfm
sudo apt install -y dunst libnotify-bin udiskie rsync dnsutils
sudo apt install -y feh suckless-tools rofi scrot irssi
sudo apt install -y thunderbird libreoffice
sudo apt install -y zathura zathura-pdf-poppler
sudo apt install -y newsboat ffmpeg mpd mpc ncmpcpp mpv
sudo systemctl disable --now mpd

sudo apt -t buster-backports install -y youtube-dl
sudo apt install -y unrar-free


if [[ $config_install ]]
then
  echo "Installing configurations..."
  git clone https://git.matejamaric.com/dotfiles /tmp/dotfiles

  cp /tmp/dotfiles/.bash* $HOME
  cp /tmp/dotfiles/.dir_colors $HOME

  cp /tmp/dotfiles/.vimrc $HOME
  cp /tmp/dotfiles/.Xdefaults $HOME
  cp -r /tmp/dotfiles/.xmonad $HOME

  cp -r /tmp/dotfiles/.config $HOME
  sed -i "s/your-user-name/$USER/" $HOME/.config/nvim/coc-settings.json

  [[ ! -d $HOME/stuff ]] && mkdir $HOME/stuff
  cp -r /tmp/dotfiles/scripts $HOME/stuff
fi


echo "Installing work software..."
sudo apt install -y nginx php-fpm mariadb-server
sudo apt install -y php_mysql phpunit php-intl php-curl php-zip php-mbstring php-gd php-soap php-xml php-xmlrpc
sudo systemctl restart php7.3-fpm.service
sudo apt install -y tmux

wget -O /tmp/composer-setup.php https://getcomposer.org/installer
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
#sudo composer self-update  

sudo apt -t buster-backports install -y nodejs npm

if [[ $latex_install ]]
then
  echo "Installing LaTeX.."
  sudo apt install -y texlive texlive-latex-base texlive-latex-extra
  sudo apt install -y texlive-extra-utils texlive-fonts-extra
  sudo apt install -y texlive-lang-english texlive-lang-cyrillic
fi


if [[ $termite_install ]]
then
  [[ ! -d $HOME/programs ]] && mkdir $HOME/programs
  cd $HOME/programs

  echo "Installing termite dependencies..."
  sudo apt install -y g++ libgtk-3-dev gtk-doc-tools gnutls-bin valac intltool libpcre2-dev
  sudo apt install -y libglib3.0-cil-dev libgnutls28-dev libgirepository1.0-dev libxml2-utils gperf libtool

  echo "Cloning termite..."
  [[ ! -d vte-ng ]] && git clone https://github.com/thestinger/vte-ng.git
  [[ ! -d termite ]] && git clone --recursive https://github.com/thestinger/termite.git

  echo "Compiling and installing termite..."
  echo export LIBRARY_PATH="/usr/include/gtk-3.0:$LIBRARY_PATH"
  cd vte-ng && ./autogen.sh && make && sudo make install
  cd ../termite && make && sudo make install
  sudo ldconfig

  echo "Installing termite terminfo..."
  sudo mkdir -p /lib/terminfo/x
  sudo ln -s /usr/local/share/terminfo/x/xterm-termite /lib/terminfo/x/xterm-termite
fi


if [[ $neovim_install ]]
then
  [[ ! -d $HOME/programs ]] && mkdir $HOME/programs
  cd $HOME/programs

  echo "Build dependencies..."
  sudo apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
  echo "NeoVim dependencies..."
  sudo apt install -y gperf libluajit-5.1-dev libunibilium-dev libmsgpack-dev libtermkey-dev libvterm-dev libjemalloc-dev lua5.1 lua-lpeg lua-mpack lua-bitop

  echo "NeoVim repo..."
  [[ ! -d neovim ]] && git clone https://github.com/neovim/neovim

  echo "NeoVim compile and install..."
  cd neovim
  make CMAKE_BUILD_TYPE=Release
  sudo make install

  pip3 install pynvim
  sudo npm install -g neovim

  echo "Installing phpactor..."
  cd $HOME/programs
  git clone https://github.com/phpactor/phpactor
  cd phpactor
  composer install
fi
