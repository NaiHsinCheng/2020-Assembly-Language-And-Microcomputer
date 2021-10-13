	.fpu softvfp

@this is code section
@note, we must have the main function for the simulator's linker script
	.text
	.align	2   @align 4 byte
	.global	main
	
main:
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4

    @code body
	@判斷operand是否合法
	push {r1}
	BL rule
	pop {r1}
	
	@把intA轉成整數並存入r2
	ldr	r0, [r1,#4]
	push {r1,r2,r3,r4}
	bl atoi
	pop {r1,r2,r3,r4}
	mov r2,r0
	
	@把intB轉成整數並存入r3
	ldr r0, [r1,#8]
	push {r1,r2,r3,r4}
	bl atoi
	pop {r1,r2,r3,r4}
	mov r3,r0
	
	@把op轉成整數並存入r4
	ldr r0, [r1,#12]
	push {r1,r2,r3,r4}
	bl atoi
	pop {r1,r2,r3,r4}
	mov r4,r0
	
	@判斷opcode是否合法 若合法跳到適當的function
	adr r5, JUMPTABLE
	cmp r4, #8
	Bgt Invalid
	cmple r4, #0
	ldrge pc, [r5,r4,lsl #2]
Invalid:
	@如果opcode不合法
	ldr r0, =string11
	mov r1, r4
	bl printf
	B EXIT
Invalid2:
	@如果operands不合法
	pop {r1}
	ldr	r2, [r1,#4]
	ldr	r3, [r1,#8]
	mov r1,r2
	mov r2,r3
	ldr r0, =string12
	bl printf
	B EXIT

rule:
	ldr r6,[r1,#8]
loopr:
	ldr r7,[r1,#4]!
	cmp r7,r6
	bxeq lr
looprr:
	ldrb r0, [r7], #1
	cmp r0,#0
	beq loopr
	cmpne r0, #48
	blt Invalid2
	cmpge r0,#57
	bgt Invalid2
	ble looprr
	
JUMPTABLE:
		  .word L0
		  .word L1
		  .word L2
		  .word L3
		  .word L4
		  .word L5
		  .word L6
		  .word L7
		  .word L8

L0:
	ldr r0, =string0
	push {r2,r3}
	bl printString
	pop {r2,r3}
	ldr r0, =string10
	add r1,r2,r3
	bl printf
	B EXIT
	
L1:
	ldr r0, =string1
	push {r2,r3}
	bl printString
	pop {r2,r3}
	sub r1,r2,r3
	ldr r0, =string10
	bl printf
	B EXIT
	
L2:
	ldr r0, =string2
	@印出string0
	push {lr}
	mov r1,r2
	push {r2,r3}
	bl printf
	pop {r2,r3}
	mov r1,#0
	mov r6,#0
	mov r4,#31
loop2:
	cmp r4,#0
	andge r5,r2,#1
	lslge r5,r5,r4
	addge r1,r5,r1
	lsrge r2,r2,#1
	subge r4,r4,#1
	bge loop2
	ldr r0, =string10
	bl printf
	B EXIT
	
L3:
	ldr r0, =string3
	push {r2,r3}
	bl printString
	pop {r2,r3}
	mov r1,#0
loop3:
	cmp r2,r3
	subge r2,r2,r3
	addge r1,#1
	bge loop3
	ldr r0, =string10
	bl printf
	B EXIT
	
L4:
    ldr r0, =string4
	push {r2,r3}
	bl printString
	pop {r2,r3}
	cmp r2,r3
	movge r1,r2
	movlt r1,r3
	ldr r0, =string10
	bl printf
	B EXIT
	
L5:
    ldr r0, =string5
	push {r2,r3}
	bl printString
	pop {r2,r3}
	mov r1,r2
loop5:
	cmp r3,#1
	mulgt r1,r2,r1
	subgt r3,r3,#1
	bgt loop5
	ldr r0, =string10
	bl printf
	B EXIT
	
L6:
    ldr r0, =string6
	push {r2,r3}
	bl printString
	pop {r2,r3}
loop6:
	cmp r3,#0
	bne mod
	moveq r1,r2
	ldr r0, =string10
	bl printf
	B EXIT
mod:
	cmp r2,r3
	subge r2,r2,r3
	bge mod
	movlt r4,r3
	movlt r3,r2
	movlt r2,r4
	blt loop6
	
L7:
    ldr r0, =string7
	push {r2,r3}
	bl printString
	pop {r2,r3}
	mul r1,r2,r3
	ldr r0, =string10
	bl printf
	B EXIT
	
L8:
    ldr r0, =string8
	push {r2,r3}
	bl printString
	pop {r2,r3}
	mul r10,r2,r3
gcd:
	cmp r3,#0
	bne mod2
	moveq r5,r2   @r2 r3最大公因數存在r5
	beq second
mod2:
	cmp r2,r3
	subge r2,r2,r3
	bge mod2
	movlt r4,r3
	movlt r3,r2
	movlt r2,r4
	blt gcd
second:
	mov r1,r5
	mov r2,r9
	mov r3,r10
	mov r1,#0
division:
	cmp r10,r5	@r5是r2 r3最大公因數
	subge r10,r10,r5
	addge r1,#1
	bge division
	ldr r0, =string10
	bl printf
	B EXIT

printString:
	@印出string0
	push {lr}
	mov r1,r2
	push {r2,r3}
	bl printf
	pop {r2,r3}

	@印出string9
	mov r1,r3
	ldr r0, =string9
	push {r2,r3}
	bl printf
	pop {r2,r3}
	
	@return
	pop {lr}
	bx lr
	
string0:
	.ascii	"Function 0: addition of %d\0"
	.align
string1:
	.ascii	"Function 1: subtraction of %d\0"
	.align
string2:
	.ascii	"Function 2: Bit-reverse of %d\0"
	.align
string3:
	.ascii	"Function 3: division of %d\0"
	.align
string4:
	.ascii	"Function 4: maximum of %d\0"
	.align
string5:
	.ascii	"Function 5: exponent of %d\0"
	.align
string6:
	.ascii	"Function 6: greatest common divisior of %d\0"
	.align
string7:
	.ascii	"Function 7: Long-multiplication of %d\0"
	.align
string8:
	.ascii	"Function 8: least common multiply of %d\0"
	.align
string9:
	.ascii  " and %d\0"
	.align
string10:
	.ascii  " is %d.\n\0"
	.align
string11:
	.ascii  "Invalid opcode: %d\n\0"
	.align
string12:
	.ascii  "Invalid input operands: %s, %s\n\0"
	.align

EXIT:
	@epilogue
	sub	sp, fp, #4
	ldmfd	sp!, {fp, lr}
	bx	lr
