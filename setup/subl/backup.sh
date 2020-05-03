set -euxo pipefail

git rm -rf User || true
cp -r ~/.config/sublime-text-3/Packages/User .
git add User
git commit -m "backing up subl config"
