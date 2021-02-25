datasg segment
    return db 8 dup (0); адрес возврата из импровизированной функции, стоит первым, чтобы не быть перезаписанным в любое случае
    val1 db 32 dup (0); первая строка
    val2 db 32 dup (0); вторая строка
    sayhi db 'Specify input: $'
    len1 db 8 dup(0); длина первой строки
    len2 db 8 dup(0); длина второй строки
    converted1 db 4 dup (0); здесь лежат уже числа
    converted2 db 4 dup (0)
    counter db 2 dup(0)
    number db 2 dup(0)
datasg ends
codesg segment para 'code'
begin proc far
    assume cs:codesg, ds:datasg
    mov ax, datasg
    mov ds, ax

    lea bx, ds:return
    lea ax, return_1; в подобных блоках кода записываем адрес возрата из вызванной функции
    mov [bx], ax

    jmp printhi
return_1: 
    lea bx, ds:return
    lea ax, return_2
    mov [bx], ax

    lea cx, ds:val1
    jmp scanvalue; в ax лежит возвращаемое значение, в cx, dx, bx - аргументы
return_2:
    lea bx, ds:len1
    mov [bx], ax

    lea bx, ds:return
    lea ax, return_3
    mov [bx], ax

    jmp printhi
return_3:
    lea bx, ds:return
    lea ax, return_4
    mov [bx], ax

    lea cx, ds:val2
    jmp scanvalue
return_4:
    lea bx, ds:len2
    mov [bx], ax

    lea bx, ds:return
    lea ax, return_5
    mov [bx], ax

    lea cx, ds:val1
    lea bx, ds:len1
    mov dx, [bx]
    jmp convert
return_5:
    lea bx, ds:converted1
    mov [bx], ax

    lea bx, ds:return
    lea ax, return_6
    mov [bx], ax

    lea cx, ds:val2
    lea bx, ds:len2
    mov dx, [bx]
    jmp convert
return_6:
    lea bx, ds:converted2
    mov [bx], ax
    
    lea bx, ds:return
    lea ax, return_7
    mov [bx], ax

    lea bx, ds:converted1
    mov cx, [bx]
    jmp print_bin
return_7:
    lea bx, ds:return
    lea ax, final
    mov [bx], ax

    mov dx, 0ah
    mov ah, 02h
    int 21h

    lea bx, ds:converted2
    mov cx, [bx]
    jmp print_bin
    
final:
    jmp exit


print_bin: ; cx - число
    lea bx, ds:counter
    mov ax, 16
    mov [bx], ax
    lea bx, ds:number
    mov [bx], cx
    mov bx, 16
print_bin_loop:
    test bx, bx
    jz print_bin_return
    and cx, 8000h
    shr cx, 15
    add cx, 30h
    mov dx, cx
    mov ah, 02h
    int 21h
    lea bx, ds:counter
    mov cx, [bx]
    dec cx
    mov [bx], cx
    lea bx, ds:number
    mov cx, [bx]
    shl cx, 1
    mov [bx], cx
    lea bx, ds:counter
    mov bx, [bx]
    jmp print_bin_loop
print_bin_return:
    jmp return_proc

convert: 
    xor ax, ax
convert_loop:
    test dx, dx
    jz convert_return 
    mov bl, 10
    mul bl
    mov bx, cx
    mov bl, [bx]
    sub bl, 30h
    add ax, bx
    dec dx
    inc cx
    jmp convert_loop
convert_return:
    jmp return_proc     

scanvalue:
    mov dx, cx
scanvalue_loop:
    mov ah, 01h
    int 21h
    ;cmp al, 20h
    ;je return_proc
    cmp al, 0dh
    je scanvalue_return
    mov bx, cx
    mov [bx], al
    inc cx
    jmp scanvalue_loop
scanvalue_return:
    sub cx, dx
    mov ax, cx
    jmp return_proc



printhi:
    mov ah, 09h
    lea dx, ds:sayhi
    int 21h
    jmp return_proc
exit:
    mov ah, 4ch
    mov al, 0
    int 21h
return_proc:
    lea bx, ds:return
    mov dx, [bx]
    cmp dx, 0
    je exit
    jmp dx
begin endp
codesg ends
end begin
