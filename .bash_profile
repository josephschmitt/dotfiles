export EDITOR="nvim"
export OPENAI_API_KEY="op://Private/OPENAI_API_KEY/credential"
export ZJ_ALWAYS_NAME="true"
export ZJ_DEFAULT_LAYOUT="$HOME/development/zj/layouts/ide"
export ZJ_LAYOUTS_DIR="$HOME/development/zj/layouts"
export ZJ_DEFAULT_LAYOUT="ide"

# Add more bin paths to PATH for custom bin scripts
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/development/zide/bin:$PATH"
export PATH="$HOME/development/zj/bin:$PATH"

# Configure asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Configure volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
