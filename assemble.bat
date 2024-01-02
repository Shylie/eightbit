@echo off
customasm %1 -f binary -o temporary_assembler_output.bin && py format_binary.py temporary_assembler_output.bin %2 --width 8 --depth 65536
