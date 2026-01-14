{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_22
    pnpm

    nodePackages.typescript
    nodePackages.typescript-language-server

    treefmt
    alejandra
    nodePackages.prettier
    nodePackages.eslint

    git
  ];

  shellHook = ''
    echo "🚀 React + TypeScript + Vite development environment"
    echo "Node version: $(node --version)"
    echo "pnpm version: $(pnpm --version)"
    echo ""
    echo "Available commands:"
    echo "  pnpm install  - Install dependencies"
    echo "  pnpm dev      - Start dev server"
    echo "  pnpm build    - Build for production"
    echo "  pnpm preview  - Preview production build"
    echo "  treefmt       - Formatting"
    echo ""
  '';

  PNPM_HOME = "${toString ./.}/.pnpm-store";
}
