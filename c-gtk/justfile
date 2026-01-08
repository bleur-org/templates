run:
    cmake --build ./build && ./build/cgtk

build:
    cmake --build ./build

clean:
    rm -rf ./build

setup:
    rm -rf ./build
    mkdir -p ./build
    cd build && cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..

format:
    # I used absolute path because silly me aliased find to ripgrep
    /usr/bin/find . -iname '*.h' -o -iname '*.c' -exec clang-format -style=file -i {} \;
