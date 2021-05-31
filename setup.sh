#!/usr/bin/env bash

read -p "Do you want to enable non-free repos? [y/n]:" non_free
[[ $non_free =~ ^[Yy]$ ]] && read -p "Do you want to install proprietary nvidia drivers? [y/n]: " nvidia_install

read -p "Do you want to install configurations? [y/n]: " config_install
read -p "Do you want to install my desktop environment? [y/n]: " desktop_install
read -p "Do you want to install my st fork? [y/n]: " st_install
read -p "Do you want to install Neovim? [y/n]: " neovim_install
read -p "Do you want to install LaTeX? [y/n]: " latex_install

read -p "Do you want to install Nginx? [y/n]: " nginx_install
read -p "Do you want to install MariaDB? [y/n]: " mariadb_install
read -p "Do you want to install PHP and Composer? [y/n]: " php_install
read -p "Do you want to install Node.js? [y/n]: " node_install
read -p "Do you want to install MongoDB? [y/n]: " mongodb_install
read -p "Do you want to install Docker? [y/n]: " docker_install
read -p "Do you want to install Hugo? [y/n]: " hugo_install

read -p "Do you want to install Aerc? [y/n]: " aerc_install
read -p "Do you want to install Qtile? [y/n]: " qtile_install
read -p "Do you want to install termite? [y/n]: " termite_install

####################################################################################################

# Adding non-free repos if necessary.
if [[ $non_free =~ ^[Yy]$ ]]
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

echo "Updating system..."
sudo cp /tmp/sources.list /etc/apt/sources.list
sudo apt update
sudo apt upgrade

echo "Installing basic cli software..."
sudo apt install -y gpg keychain git pass build-essential
sudo apt install -y unzip wget curl rsync dnsutils tmux
sudo apt install -y apt-transport-https ca-certificates gnupg lsb-release
sudo apt install -y unrar-free

if [[ $nvidia_install =~ ^[Yy]$ ]]
then
  echo "Installing proprietary nvidia drivers..."
  sudo apt install nvidia-driver
fi

####################################################################################################

if [[ $config_install =~ ^[Yy]$ ]]
then
  echo "Installing configurations..."
  git clone https://git.matejamaric.com/dotfiles /tmp/dotfiles

  cp /tmp/dotfiles/.bash* $HOME
  cp /tmp/dotfiles/.dir_colors $HOME

  cp /tmp/dotfiles/.vimrc $HOME
  cp /tmp/dotfiles/.tmux.conf $HOME
  cp /tmp/dotfiles/.gnupg/gpg-agent.conf $HOME/.gnupg/

  cp /tmp/dotfiles/.Xdefaults $HOME
  cp /tmp/dotfiles/.xprofile $HOME
  cp /tmp/dotfiles/.xinit $HOME

  cp -r /tmp/dotfiles/.xmonad $HOME

  cp -r /tmp/dotfiles/.config $HOME
  sed -i "s/your-user-name/$USER/" $HOME/.config/nvim/coc-settings.json

  cp -r /tmp/dotfiles/.local/bin $HOME/.local/
fi

if [[ $desktop_install =~ ^[Yy]$ ]]
then
  echo "Installing Xorg, AwesomeWM, utilities..."
  sudo apt install -y xorg xorg-drivers xinit xterm pinentry-gtk-2 awesome

  echo "Installing additional software for desktop usage..."
  sudo apt install -y fonts-dejavu fonts-firacode
  sudo apt install -y numlockx pcmanfm
  sudo apt install -y dunst libnotify-bin udiskie
  sudo apt install -y feh suckless-tools rofi scrot irssi
  sudo apt install -y thunderbird libreoffice
  sudo apt install -y zathura zathura-pdf-poppler
  sudo apt install -y newsboat ffmpeg mpd mpc ncmpcpp mpv
  sudo systemctl disable --now mpd
  sudo apt -t buster-backports install -y youtube-dl
fi

if [[ $st_install =~ ^[Yy]$ ]]
then
  echo "Installing my st fork..."
  git clone https://git.matejamaric.com/st /tmp/st
  cd /tmp/st
  make
  sudo make install
fi


if [[ $neovim_install =~ ^[Yy]$ ]]
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

  # Adding shared clipboard support.
  sudo apt install -y xsel

  echo "Installing phpactor..."
  cd $HOME/programs
  git clone https://github.com/phpactor/phpactor
  cd phpactor
  composer install
fi


if [[ $latex_install =~ ^[Yy]$ ]]
then
  echo "Installing LaTeX.."
  sudo apt install -y texlive texlive-latex-base texlive-latex-extra
  sudo apt install -y texlive-extra-utils texlive-fonts-extra
  sudo apt install -y texlive-lang-english texlive-lang-cyrillic
fi

####################################################################################################

if [[ $nginx_install =~ ^[Yy]$ ]]
then
  echo "Installing Nginx..."
  sudo apt install -y nginx
fi

if [[ $mariadb_install =~ ^[Yy]$ ]]
then
  echo "Installing MariaDB..."
  sudo apt install -y mariadb-server
fi

if [[ $php_install =~ ^[Yy]$ ]]
then
  echo "Installing PHP and Composer stack..."
  sudo apt install -y php-fpm
  sudo apt install -y php_mysql phpunit php-intl php-curl php-zip php-mbstring php-gd php-soap php-xml php-xmlrpc
  sudo systemctl restart php7.3-fpm.service

  wget -O /tmp/composer-setup.php https://getcomposer.org/installer
  sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
  #sudo composer self-update
fi

if [[ $node_install =~ ^[Yy]$ ]]
then
  echo "Installing Node.js..."
  #curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
  wget --quiet -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
  VERSION=node_14.x
  DISTRO="$(lsb_release -s -c)"
  echo "deb https://deb.nodesource.com/$VERSION $DISTRO main" | sudo tee /etc/apt/sources.list.d/nodesource.list
  echo "deb-src https://deb.nodesource.com/$VERSION $DISTRO main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list
  sudo apt-get update
  sudo apt-get install -y nodejs
fi

if [[ $mongodb_install =~ ^[Yy]$ ]]
then
  echo "Installing MongoDB..."
  wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
  echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
  sudo apt update
  sudo apt install -y mongodb-org
  sudo systemctl enable --now mongod
fi

if [[ $docker_install =~ ^[Yy]$ ]]
then
  echo "Installing Docker..."
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io
fi

if [[ $hugo_install =~ ^[Yy]$ ]]
then
  echo "Installing Hugo..."
  sudo apt -t buster-backports install -y hugo
fi

####################################################################################################

if [[ $qtile_install =~ ^[Yy]$ ]]
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


if [[ $termite_install =~ ^[Yy]$ ]]
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


if [[ $aerc_install =~ ^[Yy]$ ]]
then
  echo "Installing Aerc.."
  sudo apt install -t buster-backports -y golang scdoc
  sudo apt install -y isync
  git clone https://git.sr.ht/~sircmpwn/aerc
  cd aerc && git checkout tags/0.5.2
  make
  sudo make install
fi
