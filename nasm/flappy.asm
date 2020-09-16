score:  equ 0x0fa0
grav:   equ 0x0fa2
next:   equ 0x0fa4
bird:   equ 0x0fa6
hole:   equ 0x0fa8 
cadr:   equ 0x0faa

mov ax, 0x0002
int 0x10
cld
mov ax, 0xb800
mov es, ax
mov ds, ax
@@GameRestart:
    mov di, score
    xor ax, ax
    stosw
    stosw
    mov al, 160
    stosw
    mov al, 108
    stosw
mov di, 0x0064
mov ax, 0x0f46
stosw
mov al, 'l'
stosw
mov al, 'o'
stosw
mov al, 'p'
stosw
mov al, 'p'
stosw
mov al, 'y'
stosw
mov al, '-'
stosw
mov al, 'B'
stosw
mov al, 'I'
stosw
mov al, 'R'
stosw
mov al, 'D'
stosw
mov al, ' '
stosw
stosw
mov al, 'S'
stosw
mov al, 'c'
stosw
mov al, 'o'
stosw
mov al, 'r'
stosw
mov al, 'e'
stosw
mov al, 's'
stosw
mov al, ':'
stosw
mov cx, 80
@@RenderNextHouse:
    push cx
    call MoveScene
    pop cx
    loop @@RenderNextHouse
@@ClearKeyBuf:
    mov ah, 0x01
    int 0x16
    pushf
    xor ax, ax
    int 0x16
    popf
    jnz @@ClearKeyBuf
@@MainGameLoop:
    mov al, [bird]
    add al, [grav]
    mov [bird], al
    and al, 11111000b
    mov ah, 0x14
    mul ah
    add ax, 0x0020
    xchg ax, di
    mov al, [cadr]
    and al, 6
    jz @@DrawWingDown
    mov al, [di-160]
    add al, [di]
    shr al, 1
    mov word [di-160], 0x0d1e
    mov word [di], 0x0d14
    jmp @@DrawHead
@@DrawWingDown:
    mov al, [di]
    mov word [di], 0x0d1f
@@DrawHead:
    add al, [di+2]
    mov word [di+2], 0x0d10
cmp al, 0x040
jz @@NoCollision
mov byte [di], 0x2a
mov byte [di+2], 0x2a
mov di, 0x07ca
mov ax, 0x0f42
stosw
mov al, 'A'
stosw
mov al, '['
stosw
mov al, ']'
stosw
mov cx, 100
@@Wait100Cadres:
    push cx
    call DelayBeforeCadr
    pop cx
    loop @@Wait100Cadres
    jmp @@GameRestart
@@NoCollision:
    call DelayBeforeCadr
    mov al, [cadr]
    and al, 7
    jnz $+6
    inc word [grav]
    mov al, 0x20
    mov [di-160], al
    mov [di+2], al
    call MoveScene
    call MoveScene
    cmp byte [0x00a0], 0xb0
    jz $+7
    cmp byte [0x00a2], 0xb0
    jnz @@NoNeedToEncreaseScore
    inc word [score]
    mov ax, [score]
    mov di, 0x008e
    mov ax, [score]
@@NextDigitOfScore:
    xor dx, dx
    mov bx, 10
    div bx
    add dx, 0x0c30
    xchg ax, dx
    std
    stosw
    mov byte [di], 0x20
    cld
    xchg ax, dx
    or ax, ax
    jnz @@NextDigitOfScore
@@NoNeedToEncreaseScore:
    mov ah, 0x01
    int 0x16
    jz @@ToJmp_Main
    mov ah, 0x00
    int 0x16
    cmp al, 0x1b
    jne @@KeyPressedButNotEsc
    int 0x20
@@KeyPressedButNotEsc:
    mov ax, [bird]
    sub ax, 0x10
    cmp ax, 0x08
    jb @@DeneadToOutOfScreen
    mov [bird], ax
@@DeneadToOutOfScreen:
    mov byte [grav], 0
@@ToJmp_Main:
    jmp @@MainGameLoop
DelayBeforeCadr:
    mov ah, 0x00
    int 0x1a
@@NotChanged:
    push dx
    xor ah, ah
    int 0x1a
    pop bx
    cmp bx, dx
    jz @@NotChanged
    inc word [cadr]
    ret
MoveScene:
    mov si, 0x00a2
    mov di, 0x00a0
@@NextString:
    mov cx, 79
    repz movsw
    mov ax, 0x0a20
    stosw 
    loadsw
    cmp si, 0x0fa2
    jnz @@NextString
    mov word [0x0f93], 0x02df
    in al, 0x40
    and al, 0x70
    jz @@NoHouse
    mov bx, 0x0408
    mov [0x0efe], bx
    mov di, 0x0e5e
    and al, 0x20
    jz @@OneFloor
    mov [di], bx
    sub di, 0x00a0
@@OneFloor:
    mov word [di], 0x091e
@@NoHouse:
    dec word [next]
    mov bx, [next]
    cmp bx, 0x03
    ja @@ExitFromScroll
    jne @@skipRandom
    in al, 0x40
    and ax, 0x0007
    and al, 0x04
    mov word [hole], ax
@@skipRandom:
    mov cx, [hole]
    or bx, bx
    mov dl, 0xb0
    jz @@skipDLchanging
    mov dl, 0xdb
    cmp bx, 0x03
    jb @@skipDLchanging
    mov dl, 0xb1
@@skipDLchanging:
    mov di, 0x013e
    mov ah, 0x0a
    mov al, dl
@@TopPartOfTube:
    stosw
    add di, 2*79
    loop @@TopPartOfTube
    mov al, 0xc4
    stosw
    add di, (2*79)*6+10
    mov al, 0xdf
    stosw
    add di, 2*79
@@BotPartOfTube:
    mov al, dl
    stosw
    add di, 2*79
    cmp di, 0x0f00
    jb @@BotPartOfTube
    or bx, bx
    jnz @@ExitFromScroll
    mov ax, [score]
    mov ah, 0x40
    sub ah, al
    cmp ah, 17
    ja @@NoSkinToSkin
    mov ah, 17
@@NoSkinToSkin:
    mov [next], ah
@@ExitFromScroll:
    ret
