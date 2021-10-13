@this is comment

@the information that tells arm-none-eabi-as what arch. to assemble to 
	.cpu arm926ej-s
	.fpu softvfp

@this is code section
@note, we must have the main function for the simulator's linker script
	.text
	.align	2   @align 4 byte
	.global	main
	
TEST:
    .include "test.s"
main:
    LDR r0,=string0	@print出 "PC    condition    instruction    destination"
    push {r14}
    bl printf
    MOV r9,#-4          @用r9來記錄目前處理第幾行指令 用來計算PC值
    ADR r10, main
    ADR r11, TEST
LOOP:
    LDR r1, [r11],#4        @r1=指令的編碼
	ADD r9,r9,#4

    @處理PC
    push {r1,r9}             @輸出PC值  
    LDR r0,=string_pc	
	MOV r1,r9             @PC值
    bl printf
    pop {r1,r9}

    @處理condition
	push {r1,r9}
    LSR r1,r1,#28                  @判斷cond:28~32位 把他右移成四位數
    ADR r2,CONDITION
	ADD r1,r1,r1,LSL #1         @r1=3*r1   因為兩個英文字加一個\0
    ADD r1,r2,r1				@condition是多少 跳到他要的位置
	LDR r0,=string_cond
    bl printf			        @print出condition code
    pop {r1,r9}

    @處理剩下的看他屬於哪類指令
    AND r2,r1,#3<<26         @r2判斷第一條指26 27位是不是00(data processing) => and 11 要等於 00
    AND r3,r1,#5<<25	     @r3判斷第一條指令25~27位是不是101(branch)  => and 101 要等於 111
    CMP r2,#0                @判斷是否為data processing指令
    BEQ DATA_PROCESSING    
    CMPNE r3,#5<<25        @不是data processing的話看是不是branch指令
    BNE NEXT		     @假如兩類都不是 就跳過做下一條指令
    BEQ BRANCH

NEXT:
	push {r1,r9,r10,r11}
	LDR r0,=nextline
	blNE printf
	pop {r1,r9,r10,r11}
    CMP r11,r10              @比較 .test檔是不是讀完了
    BNE LOOP
	pop {r14}
    BXEQ lr


@another function
DATA_PROCESSING:
    @輸出instruction (opcode)
	push {r1,r9}
    AND r0,r1,#15<<21           @判斷opcode:24~21位
    LSR r0,#21
    ADR r2,OPCODE
	LSL r0,#2
    ADD r1,r2,r0		@opcode是多少 跳到他要的位置
	LDR r0,=string_op
    bl printf			@print出opcode對應到的指令
    pop {r1,r9}

    @輸出destination
    push {r1,r9}
    AND r1,r1,#15<<12	     @判斷12~15位是多少 來看是哪一個目標暫存器
	LSR r1,#12
    LDR r0,=string_dest
    bl printf
    pop {r1,r9}

    B NEXT

BRANCH:
    @判斷是BL還是B
    AND r5,r1,#1<<24	     @r4判斷第24位是不是一(是branch的話 =1就是branch link)	=> and 1 要等於 1
    CMP r5,#0    
	push {r1,r9}
    LDREQ r1,=OPCODE_B      @r0="B"
    LDRNE r1,=OPCODE_BL	     @r0="BL"

    @輸出instruction (print出“ＢＬ”或“Ｂ”)
    LDR r0,=string_op
    bl printf
    pop {r1,r9}

    @輸出destination
	push {r1,r9}
    LSL r1,#8		@先左移刪掉左邊的8 bit
	ASR r1,#8		@在右移 最高位補sign bit
    LDR r0,=string_int
    bl printf
    pop {r1,r9}

    B NEXT


CONDITION:
	  .asciz "EQ"   @0000
	  .asciz "NE"
	  .asciz "CS"
      .asciz "CC"
	  .asciz "MI"
      .asciz "PL"
	  .asciz "VS"
      .asciz "VC"
	  .asciz "HI"
      .asciz "LS"
	  .asciz "GE"
      .asciz "LT"
	  .asciz "GT"
      .asciz "LE"
	  .asciz "AL"
      .asciz "NV"   @1111


OPCODE:
	  .asciz "AND"   @0000
	  .asciz "EOR"
	  .asciz "SUB"
      .asciz "RSB"
	  .asciz "ADD"
      .asciz "ADC"
	  .asciz "SBC"
      .asciz "RSC"
	  .asciz "TST"
      .asciz "TEQ"
	  .asciz "CMP"
      .asciz "CMN"
	  .asciz "ORR"
      .asciz "MOV"
	  .asciz "BIC"
      .asciz "MVN"   @1111


OPCODE_B:
	  .asciz "B"
	  .align
	  
OPCODE_BL:
	  .asciz "BL"
	  .align
	  
string0:
	.ascii	"   PC    condition    instruction    destination\n\0"
	.align

string_int:
	.ascii "%15d\n\0"
	.align

string_pc:
    .ascii "%5d\0" 
    .align

string_cond:
    .ascii "%13s\0"         
    .align
	
string_op:
    .ascii "%15s\0"      
    .align

string_dest:
	.ascii	"             r%d\n\0"
	.align

nextline:
	.ascii	"\n\0"
	.align
	
    .end
    
    