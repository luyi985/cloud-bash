#!/bin/bash
NVM_VERSION="0.38.0"
function install_nvm () {
    nvm --version || {
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash && {
            echo "nvm ${NVM_VERSION} installed";
        }
    }
}
function uninstall_nvm() {
    rm -rf ~/.nvm
    rm -rf ~/.npm
    rm -rf ~/.bower
}