{ pkgs, user, flatpakPackages, ... }:

''
echo setting up flathub repo...
${pkgs.sudo}/bin/sudo -u ${user} ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo installing flatpak packages...
${pkgs.sudo}/bin/sudo -u ${user} ${pkgs.flatpak}/bin/flatpak install --user -y flathub ${toString flatpakPackages}

echo updating flatpak packages...
${pkgs.sudo}/bin/sudo -u ${user} ${pkgs.flatpak}/bin/flatpak update --user -y
''
