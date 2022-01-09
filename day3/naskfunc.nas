; naskfunc
; TAB = 4

; 汇编写的函数，之后还要与bootpack.obj链接，因此也许要编译成目标文件。因此设定为WCOFF模式
[FORMAT "WCOFF"]          ; 制作目标文件的模式
[BITS 32]                 ; 制作32位模式用的机器语言

; 制作目标文件的信息
[FILE "naskfunc.nas"]     ; 源文件名信息
      GLOBAL _io_hlt      ; 程序中包含的函数名，要加_，与 GLOBAL才能与C语言函数链接

; 以下是实际的函数
[SECTION .text]           ; 目标文件中写了这些后再写程序

_io_hlt                   ; void io_hlt(void);

      HLT
      RET
