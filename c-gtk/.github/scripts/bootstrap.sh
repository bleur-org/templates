bootstrap () {
  local _cwp="$(pwd)"
  local _build="$(pwd)/build"

  log "warn" "let's see if build folder is fine..."

  if [ -d "$_build" ]; then
    log "trace" "seems like everything lookin' fine here..."

    return
  fi

  if [ ! -d "$_build" ]; then
    log "warn" "boostrapping build directory..."
    mkdir -p $_build

    # Enter build folder
    cd $_build

    # Bootstrap cmake
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..

    # Return back
    cd $_cwp
  fi

  return
}

bootstrap
