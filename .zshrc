#
# ~/.zshrc
#

# Only run if the shell is interactive
[[ -o interactive ]] || return


alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[%n@%m %1~]$ '
alias vim="nvim"
alias vmi="nvim"
alias ivm="nvim"
alias imv="nvim"
alias miv="nvim"
alias mvi="nvim"
alias vba="source venv/bin/activate"
alias dnb="dotnet build"
alias ecp="mv /home/ivan/dotfiles/nvim/unused_plugins/copilot.lua /home/ivan/dotfiles/nvim/lua/plugins"
alias dcp="mv /home/ivan/dotfiles/nvim/lua/plugins/copilot.lua /home/ivan/dotfiles/nvim/unused_plugins"
alias reset_efcore_database="dotnet ef database drop && dotnet ef database update"
alias ssh-raspberrypi-home="ssh ivan@192.168.50.151"
alias ssh-raspberrypi-hotspot="ssh ivan@172.20.10.2"
alias enter-postgres="sudo -i -u postgres"

export celeste_mods="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Celeste/Mods/test"
export zishrc="$HOME/dotfiles/.zshrc"

# Start ssh-agent once per login
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
fi

# fastfetch

# Turso
export PATH="$PATH:/home/ivan/.turso"

# pnpm
export PNPM_HOME="/home/ivan/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

run() {
  # Ensure pnpm is installed
  if ! command -v pnpm > /dev/null 2>&1; then
    echo "Error: pnpm is not installed."
    return 1
  fi

  # Check for package.json to confirm we're in the project root
  if [ ! -f "package.json" ]; then
    echo "Error: package.json not found. Are you in the root directory of your pnpm project?"
    return 1
  fi

  # Install dependencies
  echo "Installing dependencies..."
  pnpm install || { echo "Error: Failed to install dependencies."; return 1; }

  # Run the project (assuming the "start" script is defined in package.json)
  echo "Starting the project..."
  pnpm run dev || { echo "Error: Failed to run the project."; return 1; }
}

push() {
  if [ ! -d .git ]; then
    echo "Error: No .git directory found. Are you in a Git repository?"
    return 1
  fi

  if [ -z "$1" ]; then
    echo "Usage: push <branch>"
    return 1
  fi

  # Add, commit, and push to the specified branch
  git push origin "$1"
}


pull() {
  if [ ! -d .git ]; then
    echo "Error: No .git directory found. Are you in a Git repository?"
    return 1
  fi

  if [ -z "$1" ]; then
    echo "Usage: push <branch>"
    return 1
  fi

  git pull origin "$1"
}

cbr() {
  if [ ! -f Cargo.toml ]; then
    echo "Currently not in a base cargo directory"
    return 1
  fi

  cargo build --quiet

  cargo run --quiet

}

dbr() {
  if [[ -z "$1" ]]; then
    # No argument, use current directory
    if ! ls *.csproj >/dev/null 2>&1; then
      echo "No .csproj file found in current directory."
      echo "Usage: dbr <project-folder>"
      return 1
    fi

    dotnet build
    dotnet run
  else
    local current_directory=$(pwd)
    if ! ls "$1"/*.csproj >/dev/null 2>&1; then
      echo "No .csproj file found in '$1'."
      return 1
    fi

    cd $1
    dotnet build 
    dotnet run 
    cd $current_directory
  fi
}

cgb() {
  if [ ! -f Cargo.toml ]; then
    echo "Currently not in a base cargo directory"
    return 1
  fi

  cargo build --quiet

  echo "Successfully built project!"
}

# Clone a GitHub repo using SSH by default.
# Accepts:
#   owner/repo
#   https://github.com/owner/repo(.git)
#   git@github.com:owner/repo(.git)
# Optional 2nd arg = target dir.
clone() {
  if [[ -z "$1" ]]; then
    echo "Usage: clone <owner/repo|github-url|ssh-url> [target-dir]"
    return 1
  fi

  local input="$1" target="${2:-}" repo_path ssh_url

  # Normalize to owner/repo
  if [[ "$input" =~ ^https?://github\.com/ ]]; then
    repo_path="${input#*github.com/}"; repo_path="${repo_path%.git}"
  elif [[ "$input" =~ ^git@github\.com: ]]; then
    repo_path="${input#git@github.com:}"; repo_path="${repo_path%.git}"
  else
    repo_path="$input"
  fi

  ssh_url="git@github.com:${repo_path}.git"
  echo "Cloning: $ssh_url"

  if command -v gh >/dev/null 2>&1; then
    # gh is fine with full SSH URLs; this avoids HTTPS and any auto auth tweaks.
    [[ -n "$target" ]] && gh repo clone "$ssh_url" "$target" || gh repo clone "$ssh_url"
  else
    [[ -n "$target" ]] && git clone "$ssh_url" "$target" || git clone "$ssh_url"
  fi
}

# Link current repo to a GitHub remote over SSH and push current branch
# WITHOUT setting upstream.
link() {
  if [[ -z "$1" ]]; then
    echo "Usage: link <owner/repo|github-url|ssh-url>"
    return 1
  fi
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: not inside a git repository"
    return 1
  fi

  local input="$1" repo_path ssh_url

  # Normalize to owner/repo
  if [[ "$input" =~ ^https?://github\.com/ ]]; then
    repo_path="${input#*github.com/}"; repo_path="${repo_path%.git}"
  elif [[ "$input" =~ ^git@github\.com: ]]; then
    repo_path="${input#git@github.com:}"; repo_path="${repo_path%.git}"
  else
    repo_path="$input"
  fi

  ssh_url="git@github.com:${repo_path}.git"

  if git remote get-url origin >/dev/null 2>&1; then
    echo "Updating remote origin → $ssh_url"
    git remote set-url origin "$ssh_url"
  else
    echo "Adding remote origin → $ssh_url"
    git remote add origin "$ssh_url"
  fi

  # Push current branch WITHOUT setting upstream (-u)
  local branch
  branch="$(git symbolic-ref --quiet --short HEAD || git rev-parse --short HEAD)"
  echo "Pushing current branch '$branch' to origin (no upstream set)…"
  git push origin "$branch"
}

format() {
  # check if currently inside a ts project
  if [ ! -f package.json ]; then
    echo "Currently not in a TypeScript project directory"
    return 1
  fi

  # check for argument usage => format <file>
  if [ -z "$1" ]; then
    echo "Usage: format <file>"
    return 1
  fi

  # Disable glob pattern matching for this function
  setopt local_options NO_NOMATCH

  local file="$1"
  
  # Check if file exists (quoted to prevent glob expansion)
  if [ ! -f "$file" ]; then
    echo "File not found: $file"
    return 1
  fi

  # Use prettier's --write flag instead of redirection
  prettier --write "$file"
}

dnf() {
  if [[ -z "$1" ]]; then
    # No argument, use current directory
    if ! ls *.csproj >/dev/null 2>&1; then
      echo "No .csproj file found in current directory."
      echo "Usage: dbr <project-folder>"
      return 1
    fi

    dotnet format
  else
    local current_directory=$(pwd)
    if ! ls "$1"/*.csproj >/dev/null 2>&1; then
      echo "No .csproj file found in '$1'."
      return 1
    fi

    cd $1
    dotnet format
    cd $current_directory
  fi

  echo "Formatted files succellfully"
}

runpy() {
  local dir="."
  if [[ -n "$1" ]]; then
    dir="$1"
  fi

  if [[ ! -d "$dir" ]]; then
    echo "Unable to find directory: '$dir'" >&2
    return 1
  fi

  pushd "$dir" > /dev/null || return 1

  if [[ -f src/main.py ]]; then
    python src/main.py "${@:2}"
  elif [[ -f main.py ]]; then
    python main.py "${@:2}"
  else
    echo "No main.py found in '$dir' or '$dir/src'." >&2
    popd > /dev/null
    return 1
  fi

  popd > /dev/null
}


export PATH="$PATH:$HOME/.dotnet/tools"

# Initialize packages
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

