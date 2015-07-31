nasm -f bin -o boot1.bin boot1.s
nasm -f bin -o boot2.bin boot2.s

dd if=boot1.bin of=boot.img
dd if=boot2.bin of=boot.img bs=512 seek=1

kvm -cpu host -fda boot.img
