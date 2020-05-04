set -euxo pipefail

cp -r ~/.config/sublime-text-3/Packages/User/ ~/.config/sublime-text-3/Packages/User-$(date +%s)/ 
cp -r ./User/* ~/.config/sublime-text-3/Packages/User/