BITS 32

extern XOpenDisplay
extern XDefaultScreen
extern XRootWindow
extern XCreateSimpleWindow
extern XSelectInput
extern XMapWindow
extern XCreateGC
extern XSetForeground
extern XFillRectangle
extern XNextEvent
extern XFlush
extern sleep

SECTION .data

colors:
    dd 0xFF0000   ; red
    dd 0x00FF00   ; green
    dd 0x0000FF   ; blue

frame:
    dd 0

SECTION .bss
display resd 1
window  resd 1
gc      resd 1
event   resb 192

SECTION .text
global _start

_start:

    push dword 0
    call XOpenDisplay
    add esp,4
    mov [display],eax

    ; screen (unused but required by call flow)
    push eax
    call XDefaultScreen
    add esp,4

    push dword eax
    push dword [display]
    call XRootWindow
    add esp,8

    push dword 0
    push dword 0
    push dword 1
    push dword 200
    push dword 400
    push dword 100
    push dword 100
    push eax
    push dword [display]
    call XCreateSimpleWindow
    add esp,36

    mov [window],eax

    push dword 0x8000
    push dword [window]
    push dword [display]
    call XSelectInput
    add esp,12

    push dword [window]
    push dword [display]
    call XMapWindow
    add esp,8

    push dword 0
    push dword 0
    push dword [window]
    push dword [display]
    call XCreateGC
    add esp,16

    mov [gc],eax


.wait:
    push event
    push dword [display]
    call XNextEvent
    add esp,8

    cmp dword [event],12
    jne .wait

.loop:

    mov eax,[frame]
    and eax,3
    shl eax,2
    mov ebx,[colors+eax]

    ; set foreground
    push ebx
    push dword [gc]
    push dword [display]
    call XSetForeground
    add esp,12

    push dword 200        ; height
    push dword 400        ; width
    push dword 0          ; y
    push dword 0          ; x
    push dword [gc]
    push dword [window]
    push dword [display]
    call XFillRectangle
    add esp,28

    ; flush to screen
    push dword [display]
    call XFlush
    add esp,4

    push dword 1
    call sleep
    add esp,4

    mov eax,[frame]
    inc eax
    and eax,3
    mov [frame],eax

    jmp .loop
