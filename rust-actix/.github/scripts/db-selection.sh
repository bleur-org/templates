echo "Select database setup:"
echo "1) PostgreSQL via Nix (in-shell)"
echo "2) PostgreSQL via Docker/Podman"
echo "3) Skip database setup"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
  1)
    source ./.github/scripts/init-db.sh
    ;;
  2)
    # Check for actual Docker socket, otherwise use Podman
    if [ -S /var/run/docker.sock ] && docker info &> /dev/null 2>&1; then
      docker-compose up -d
    else
      export DOCKER_HOST="unix:///run/user/$UID/podman/podman.sock"
      systemctl --user is-active --quiet podman.socket || systemctl --user start podman.socket

      if command -v podman-compose &> /dev/null; then
        podman-compose up -d
      else
        docker-compose up -d
      fi
    fi

    [ $? -eq 0 ] && echo "PostgreSQL started: postgres://temp:temp@localhost:5432/temp"
    ;;
  3)
    echo "Skipping database setup."
    ;;
esac
