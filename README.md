# How To Run using Qemu

`❯ qemu-system-x86_64 -drive format=raw,file=build/boot.bin`

# How to Compile

`❯ nasm -f bin src/boot.asm -o build/boot.bin`

# Install All Dependency

## Arch Linux
`❯ sudo pacman -S qemu nasm make`
