export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
if ! command -v node >/dev/null; then
  echo "Instal·lant Node.js via nvm..."
  nvm install --lts
fi
