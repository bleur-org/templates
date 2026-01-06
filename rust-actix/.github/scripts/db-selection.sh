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
    echo "Are you using Docker or Podman?"
    echo "1) Docker"
    echo "2) Podman"
    read -p "Enter choice [1-2]: " container_choice

    case $container_choice in
      1)
        docker-compose up -d
        ;;
      2)
        export DOCKER_HOST="unix:///run/user/$UID/podman/podman.sock"
        systemctl --user is-active --quiet podman.socket \
          || systemctl --user start podman.socket

        if command -v podman-compose >/dev/null; then
          podman-compose up -d
        else
          docker-compose up -d
        fi
        ;;
      *)
        echo "Invalid choice. Skipping."
        ;;
    esac

    echo "PostgreSQL started: postgres://temp:temp@localhost:5432/temp"
    ;;
  3)
    echo "Skipping database setup."
    ;;
  *)
    echo "Invalid choice. Skipping database setup."
    ;;
esac
