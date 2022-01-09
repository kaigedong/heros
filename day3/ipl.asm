; hello-os
; TAB=4

; ORG: origin, 告诉nask，程序要从指定的这个地址开始，即把程序装载到内存中的指定地址。
; CPU中名为寄存器的存储电路，具有代表性的有8个，全都是16位寄存器
; AX--accumulator, 累加寄存器
; CX--counter, 计数...
; DX--data, 数据...
; BX--base, 基址...
; SP--stack pointer, 栈指针...
; BP--base pointer, 基址指针...
; SI--source index, 源变址...
; DI--destination index, 目的变址...
; 另外，CPU中还有8个8位寄存器

CYLS EQU  10                ; EQU用来声明常量。CYLS=cylinders 声明CYLS=10

    ORG 0x7c00              ; 指明程序的装载地址

; 以下的记述用于标准的FAT12格式的磁盘

fat12:
    JMP entry
    DB  0x90
    DB  "HELLOIPL"          ; 启动扇区名称（8字节）
    DW  512                 ; 每个扇区（sector）大小（必须为512字节）
    DB  1                   ; 簇（cluster）大小，（必须为1个扇区)
    DW  1                   ; FAT起始位置（一般为第一个扇区)
    DB  2                   ; FAT个数（必须为2）
    DW  224                 ; 根目录大小（一般为224项）
    DW  2880                ; 该磁盘大小（必须为2880扇区1440*1024/512)
    DB  0xf0                ; 磁盘类型（必须为0xf0)
    DW  9                   ; FAT的长度（必??9扇区)
    DW  18                  ; 一个磁道(track)有几个扇区(必须为18)
    DW  2                   ; 磁头数(必??2)
    DD  0                   ; 不使用分区，必须是0
    DD  2880                ; 重写一次磁盘大小
    DB  0, 0, 0x29          ; 意义不明（固定）
    DD  0xffffffff          ; (可能是)卷标号码
    DB  "HERO-OS    "       ; 磁盘的名称（必须为11字？不足填空格)
    DB  "FAT12   "          ; 磁盘格式名称（必须8字？不足填空格)
    RESB    18              ; 先空出18字节

; 程序主体
entry:
    MOV AX, 0               ; 初始化寄存器,即：AX=0
    MOV SS, AX
    MOV SP, 0x7c00
    MOV DS, AX

; 读取磁盘
; 指定 ES = 0x0820, BX=0表示软盘中的数据将被装载到内存0x8200到0x83ff的地方
; 0x8000~0x81ff这512字节是留给启动区的
    MOV AX, 0x0820
    MOV ES, AX
    MOV CH, 0                 ; 柱面0
    MOV DH, 0                 ; 磁头0
    MOV CL, 2                 ; 扇区2
readloop:
    MOV SI, 0                 ; 记录失败次数寄存器
retry:
    MOV AH, 0x02              ; AH=0x02 : 读盘，BIOS的说明里记载，读盘返回值为0/1
    MOV AL, 1                 ; 1个扇区
    MOV BX, 0
    MOV DL, 0x00              ; A 驱动器
    INT 0x13                  ; 调用磁盘BIOS
    JNC  next                 ; JC: jump if not crray，即标志位为0就跳转
    ADD SI, 1                 ; 往SI加1
    CMP SI, 5                 ; 比较SI与5
    JAE error                 ; SI>=5跳转到Error
    MOV AH, 0x00              ; 出错跳转前的处理：AH=0x00, DL=0x00, INT 0x13. BIOS网页说明这种设置为复位软盘状态
    MOV DL, 0x00              ; A 驱动器
    INT 0x13                  ; 重置驱动器
    JMP retry

; 用循环读到18扇区
; 实现了把磁盘C0-H0-S2到C0-H0-S18的512*17=8704字节的内容装载到了内存的0x8200~0xa3ff处
next:                         ; 要读下一个扇区，只要CL+1(扇区号), ES + 0x20即可
    MOV AX, ES                ; 把内存地址后移0x200 (512/16十六进制转换)
    ADD AX, 0x0020

    MOV ES, AX                ; ADD ES, 0x20因为没有ADD ES，智能通过AX进行
    ADD CL, 1                 ; 往CL里面加1
    CMP CL, 18                ; 比较CL 与 18
    JBE readloop              ; CL<=18跳转到readloop, JBE: jump if below or equal
    MOV CL, 1
    ADD DH, 1
    CMP DH, 2
    JB readloop               ; DH < 2 跳转到readloop
    MOV DH, 0
    ADD CH, 1
    CMP CH, CYLS
    JB readloop               ; CH < CYLS 跳转到readloop, JB: jump if below

; 读取完毕，跳转到haribote.sys 执行！
    MOV [0x0ff0], CH          ; 注意 IPL 已经读了多远
    JMP 0xc200

error:
    MOV SI, msg

putloop:
    MOV AL, [SI]
    ADD SI, 1               ; 给SI加1
    CMP AL, 0
    JE  fin
    MOV AH, 0x0e            ; 显示一个文字
    MOV BX, 15              ; 指定字符颜色
    INT 0x10                ; 调用显卡BIOS
    JMP putloop

fin:
    HLT                     ; 让CPU停止，等待指令
    JMP fin                 ; 无限循环

msg:
    DB  0x0a, 0x0a          ; 换行2次
    DB  "load error"
    DB  0x0a                ; 换行
    DB  0

;0x1fe-($-$$)
; 源文件中没有这一步，不妨加上
    RESB	0x1fe-($-$$)	; 填写0x00直到0x001fe
    DB		0x55, 0xaa

