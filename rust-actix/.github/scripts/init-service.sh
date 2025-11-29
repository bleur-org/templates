####################################################################
# Clean up after exiting the Nix shell using `trap`.
# ------------------------------------------------------------------
# Idea taken from
# https://unix.stackexchange.com/questions/464106/killing-background-processes-started-in-nix-shell
# and the answer provides a way more sophisticated solution.
#
# The main syntax is `trap ARG SIGNAL` where ARG are the commands to
# be executed when SIGNAL crops up. See `trap --help` for more.
####################################################################

trap \
  "
    ######################################################
    # Kill the running instance before exiting shell
    ######################################################
    # kill $CARGO_WATCH_PID
  " \
  EXIT

####################################################################
# Starting server with auto hot-reload for further debugging
# ==================================================================
# Change and uncomment necessary settings from configurations
# provided below.
####################################################################

######################################################
# Binding everything to cargo-watch
######################################################
cargo watch -x "run --bin "cli" &

######################################################
# Store the PID of the background process
######################################################
CARGO_WATCH_PID=$!
