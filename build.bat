wla-6502 -o stage2.asm 
wla-6502 -o stage3.asm 
wla-6502 -o payload.asm

wlalink -b stage2.cfg stage2.bin
wlalink -b stage3.cfg stage3.bin
wlalink -b payload.cfg payload.bin

convert_bin.py 2 1 stage2.bin
reverse_input.py stage2.inp
convert_bin.py 1 1 stage3.bin
convert_bin.py 1 1 payload.bin

copy stage2.rev.inp + stage3.inp + payload.inp console.inp
create_r16m.py console.inp
copy /b smb2_base.r16m + console.r16m replayfiles\\build.r16m