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

export dsa_assignment="$HOME/programming/nyp/y2s1/data_structures_and_algorithms/assignment_1/"
export dotfiles="$HOME/dotfiles/"
export school="$HOME/programming/nyp/y2s1/"
export ap_assignment="$HOME/programming/nyp/y2s1/advanced_programming/assignment_2/ASN2_Student_Resource/ASN2_Student_Resource/"
export ip="$HOME/programming/nyp/y2s1/full_stack_dev/project/initiate-platform"
export ib="$HOME/programming/nyp/y2s1/full_stack_dev/project/initiate-backend"
export learning="$HOME/programming/personal/learning"
export celeste_mods="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Celeste/Mods/test"
export personal="$HOME/programming/personal"
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

initiate() {
  local BASE="$HOME/programming/nyp/y2s1/full_stack_dev/project"
  local BACKEND="$BASE/initiate-backend"
  local PLATFORM="$BASE/initiate-platform"

  cd "$BACKEND" || return
  pnpm install
  pnpx prisma db push
  pnpm db:gen
  pnpx prisma studio &
  pnpm cf:dev &         
  sleep 2           

  cd "$PLATFORM" || return
  pnpm install
  pnpm dev         
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

clone() {
  if [[ -z "$1" ]]; then
    echo "Usage: clone <github-https-url>"
    return 1
  fi

  local url="$1"

  # Check if it's a GitHub HTTPS URL
  if [[ ! "$url" =~ ^https://github\.com/ ]]; then
    echo "Error: Please provide a valid GitHub HTTPS URL"
    return 1
  fi

  # Extract the user/repo part from the URL
  local repo_path="${url#https://github.com/}"

  # Remove .git suffix if present
  repo_path="${repo_path%.git}"

  # Construct and execute the SSH clone command
  local ssh_url="git@github.com:${repo_path}.git"
  echo "Cloning: $ssh_url"
  git clone "$ssh_url"
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

link() {
  if [[ -z "$1" ]]; then
    echo "Usage: gitlink <github-https-url>"
    return 1
  fi

  local url="$1"

  # Validate GitHub HTTPS URL
  if [[ ! "$url" =~ ^https://github\.com/ ]]; then
    echo "Error: Please provide a valid GitHub HTTPS URL"
    return 1
  fi

  # Transform to SSH format
  local repo_path="${url#https://github.com/}"
  repo_path="${repo_path%.git}"
  local ssh_url="git@github.com:${repo_path}.git"

  echo "Adding remote origin: $ssh_url"
  git remote add origin "$ssh_url"

  push main
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



export PATH="$PATH:$HOME/.dotnet/tools"

. "$HOME/.local/bin/env"
eval "$(zoxide init zsh)"
