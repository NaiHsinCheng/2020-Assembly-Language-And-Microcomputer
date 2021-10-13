@the information that tells arm-none-eabi-as what arch. to assemble to 
	.cpu arm926ej-s
	.fpu softvfp

@this is code section
@note, we must have the main function for the simulator's linker script
	.text
	.align	2   @align 4 byte
	.global	main
main:
    @prologue
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	
    @code body
	ldr r3, [r1,#4]
	adr r4, string1
	str r3, [r4, #4]
	
	@"a.out result: "
	ldr r0, =string0
	bl printf
	
	ldr r2, =string1
	
loop:	
	ldrb r1, [r2], #1
	cmp r1, #0 @endl
	beq end
	
	cmp r1, #65 @'A'
	blt loop
	cmp r1, #122 @'z'
	bgt loop
	
	@we get those in [65,122]
	cmp r1, #90 @'Z'
	addle r1, r1, #32
	
	@we get those in [91,122]
	cmp r1, #97 @'a'
	blt loop
	
	mov r0, r1
	push {r0,r1,r2}
	bl putchar
	pop {r0,r1,r2}
	b loop
	
end:
	@epilogue
	sub	sp, fp, #4
	ldmfd	sp!, {fp, lr}
	bx	lr
@data section

string0:
	.ascii	"a.out result: "
	.align

string1:
	.align
    .end
    
    