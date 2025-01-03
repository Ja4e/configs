#!/bin/zsh
#Dont forget to chmod this to run this
# Paths
USER_HOME="$HOME"
ROOT_HOME="/root"
ROOT_ZSHRC="$ROOT_HOME/.zshrc"
ROOT_OH_MY_ZSH="$ROOT_HOME/.oh-my-zsh"
BACKUP_DIR="$USER_HOME/.root_zsh_backup"

# Function to create a backup
create_backup() {
    echo "Creating a backup of root's current configuration..."
    mkdir -p "$BACKUP_DIR"
    if [[ -f "$ROOT_ZSHRC" ]]; then
        [[ ! -f "$BACKUP_DIR/.zshrc" ]] && sudo cp "$ROOT_ZSHRC" "$BACKUP_DIR/.zshrc" && echo "Backed up .zshrc."
    fi
    if [[ -d "$ROOT_OH_MY_ZSH" ]]; then
        [[ ! -d "$BACKUP_DIR/.oh-my-zsh" ]] && sudo cp -r "$ROOT_OH_MY_ZSH" "$BACKUP_DIR/.oh-my-zsh" && echo "Backed up .oh-my-zsh."
    fi
}

# Function to copy user's zshrc and Oh My Zsh to root
copy_to_root() {
    echo "Copying user's zshrc and Oh My Zsh to root..."
    create_backup
    sudo cp "$USER_HOME/.zshrc" "$ROOT_ZSHRC" && echo "Copied .zshrc to root."
    sudo cp -r "$USER_HOME/.oh-my-zsh" "$ROOT_OH_MY_ZSH" && echo "Copied .oh-my-zsh to root."
    sudo chsh -s "$(which zsh)" root && echo "Set Zsh as the default shell for root."
}

# Function to symlink user's zshrc and Oh My Zsh to root
symlink_to_root() {
    echo "Symlinking user's zshrc and Oh My Zsh to root..."
    create_backup
    sudo ln -sf "$USER_HOME/.zshrc" "$ROOT_ZSHRC" && echo "Symlinked .zshrc to root."
    sudo ln -sf "$USER_HOME/.oh-my-zsh" "$ROOT_OH_MY_ZSH" && echo "Symlinked .oh-my-zsh to root."
    sudo chsh -s "$(which zsh)" root && echo "Set Zsh as the default shell for root."
}

# Function to reverse symlinks by restoring files from symlinked paths
reverse_symlinks() {
    echo "Reversing symlinks in root's configuration..."
    if [[ -L "$ROOT_ZSHRC" ]]; then
        sudo cp "$USER_HOME/.zshrc" "$ROOT_ZSHRC" && echo "Reversed symlink for .zshrc."
    else
        echo ".zshrc is not a symlink; no changes made."
    fi
    if [[ -L "$ROOT_OH_MY_ZSH" ]]; then
        sudo rm "$ROOT_OH_MY_ZSH"
        sudo cp -r "$USER_HOME/.oh-my-zsh" "$ROOT_OH_MY_ZSH" && echo "Reversed symlink for .oh-my-zsh."
    else
        echo ".oh-my-zsh is not a symlink; no changes made."
    fi
}

# Function to restore root's original configuration
restore_root() {
    echo "Restoring root's original configuration..."
    if [[ -f "$BACKUP_DIR/.zshrc" ]]; then
        sudo cp "$BACKUP_DIR/.zshrc" "$ROOT_ZSHRC" && echo "Restored .zshrc."
    else
        echo "No backup found for .zshrc."
    fi
    if [[ -d "$BACKUP_DIR/.oh-my-zsh" ]]; then
        sudo rm -rf "$ROOT_OH_MY_ZSH"
        sudo cp -r "$BACKUP_DIR/.oh-my-zsh" "$ROOT_OH_MY_ZSH" && echo "Restored .oh-my-zsh."
    else
        echo "No backup found for .oh-my-zsh."
    fi
    sudo chsh -s "$(which bash)" root && echo "Reset root's shell to bash."
}

# Main script logic
case "$1" in
    copy)
        copy_to_root
        ;;
    symlink)
        symlink_to_root
        ;;
    reverse-symlink)
        reverse_symlinks
        ;;
    restore)
        restore_root
        ;;
    *)
        echo "Usage: $0 {copy|symlink|reverse-symlink|restore}"
        exit 1
        ;;
esac
