# File: execute.s
# Global functions: execute
# Global variables: -

# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.


.global execute

.text
	
	# See docs/instructions.html for an overview of all the opcodes, sorted by IS, II and AM.
	
	#--------------------
	# execute
	# Execute the current instruction.
	# Find the right one using a switch table orgy.
	#--------------------
	
	execute:
		movzbl IS, %ecx                       # \
		jmp * execute_is_switch(,%ecx,4)      # / switch-case (using a lookup table) for IS
		
	# Switch II for IS 01
	execute_is01:
		movzbl II, %ecx                       # \
		jmp * execute_is01_ii_switch(,%ecx,4) # / switch-case for II
		
	# Switch II for IS 10
	execute_is10:
		movzbl II, %ecx                       # \
		jmp * execute_is10_ii_switch(,%ecx,4) # / switch-case for II
		
	# Switch OM for IS 00
	execute_is00:
		movzbl OM, %ecx                       # \
		jmp * execute_is00_om_switch(,%ecx,4) # / switch-case for OM
		
	# Check for STP in IS 11
	execute_is11:
		# No  opcodes exist in this instruction set, so we jump to 'execute_invalid'.
		jmp execute_invalid
		
	
	# Switch table for IS
	execute_is_switch:
		.long execute_is00
		.long execute_is01
		.long execute_is10
		.long execute_is11
		
	# Switch table for OM in IS 00
	execute_is00_om_switch:
		.long execute_is00_om000
		.long execute_is00_om001
		.long execute_is00_om010
		.long execute_is00_om011
		.long execute_is00_om100
		.long execute_is00_om101
		.long execute_is00_om110
		.long execute_is00_om111
		
	# Switch table for II in IS 01
	execute_is01_ii_switch:
		.long execute_is01_ii000
		.long execute_is01_ii001
		.long execute_is01_ii010
		.long execute_is01_ii011
		.long execute_is01_ii100
		.long execute_is01_ii101
		.long execute_is01_ii110
		.long execute_is01_ii111
		
	# Switch table for II in IS 10
	execute_is10_ii_switch:
		.long execute_is10_ii000
		.long execute_is10_ii001
		.long execute_is10_ii010
		.long execute_is10_ii011
		.long execute_is10_ii100
		.long execute_is10_ii101
		.long execute_is10_ii110
		.long execute_is10_ii111
		
	
	execute_is01_ii000:
		jmp execute_ora
		
	execute_is01_ii001:
		jmp execute_and
		
	execute_is01_ii010:
		jmp execute_eor
		
	execute_is01_ii011:
		jmp execute_adc
		
	execute_is01_ii100:
		cmpb $2, OM              # \ opcode 0x89 is undefined (one would expect STA with an immediate operand there, which is -af course- nonsense)
		je execute_invalid       # / 
		jmp execute_sta
		
	execute_is01_ii101:
		jmp execute_lda
		
	execute_is01_ii110:
		jmp execute_cmp
		
	execute_is01_ii111:
		jmp execute_sbc
		
	execute_is00_om000:
		movzbl II, %ecx                             # \
		jmp * execute_is00_om000_ii_switch(,%ecx,4) # / switch-case for II
		
	execute_is00_om001:
		movzbl II, %ecx                             # \
		jmp * execute_is00_om001_ii_switch(,%ecx,4) # / switch-case for II
		
	execute_is00_om010:
		movzbl II, %ecx                             # \
		jmp * execute_is00_om010_ii_switch(,%ecx,4) # / switch-case for II
		
	execute_is00_om011:
		movzbl II, %ecx                             # \
		jmp * execute_is00_om011_ii_switch(,%ecx,4) # / switch-case for II
		
	execute_is00_om100:
		movzbl II, %ecx                             # \
		jmp * execute_is00_om100_ii_switch(,%ecx,4) # / switch-case for II
		
	execute_is00_om101:
		cmpb $0b100, II
		je execute_sty
		cmpb $0b101, II
		je execute_ldy
		jmp execute_invalid
		
	execute_is00_om110:
		movzbl II, %ecx                             # \
		jmp * execute_is00_om110_ii_switch(,%ecx,4) # / switch-case for II
		
	execute_is00_om111:
		cmpb $0b101, II
		je execute_ldy
		jmp execute_invalid
		
	# Switch table for II in IS 00 with OM 000
	execute_is00_om000_ii_switch:
		.long execute_brk
		.long execute_jsr
		.long execute_rti
		.long execute_rts
		.long execute_invalid
		.long execute_ldy
		.long execute_cpy
		.long execute_cpx
		
	# Switch table for II in IS 00 with OM 001
	execute_is00_om001_ii_switch:
		.long execute_invalid
		.long execute_bit
		.long execute_invalid
		.long execute_invalid
		.long execute_sty
		.long execute_ldy
		.long execute_cpy
		.long execute_cpx
	
	# Switch table for II in IS 00 with OM 010
	execute_is00_om010_ii_switch:
		.long execute_php
		.long execute_plp
		.long execute_pha
		.long execute_pla
		.long execute_dey
		.long execute_ldy
		.long execute_iny
		.long execute_inx
	
	# Switch table for II in IS 00 with OM 011
	execute_is00_om011_ii_switch:
		.long execute_invalid
		.long execute_bit
		.long execute_jmp
		.long execute_jmp
		.long execute_sty
		.long execute_ldy
		.long execute_cpy
		.long execute_cpx
	
	# Switch table for II in IS 00 with OM 100
	execute_is00_om100_ii_switch:
		.long execute_bpl
		.long execute_bmi
		.long execute_bvc
		.long execute_bvs
		.long execute_bcc
		.long execute_bcs
		.long execute_bne
		.long execute_beq
	
	# There is no switch table for II in IS 00 with OM 101, it is not needed
	
	# Switch table for II in IS 00 with OM 110
	execute_is00_om110_ii_switch:
		.long execute_clc
		.long execute_sec
		.long execute_cli
		.long execute_sei
		.long execute_tya
		.long execute_clv
		.long execute_cld
		.long execute_sed
		
	
	execute_is10_ii000:
		cmpb $0b000, OM
		je execute_invalid
		cmpb $0b100, OM
		je execute_invalid
		cmpb $0b110, OM
		je execute_invalid
		jmp execute_asl
		
	execute_is10_ii001:
		cmpb $0b000, OM
		je execute_invalid
		cmpb $0b100, OM
		je execute_invalid
		cmpb $0b110, OM
		je execute_invalid
		jmp execute_rol
		
	execute_is10_ii010:
		cmpb $0b000, OM
		je execute_invalid
		cmpb $0b100, OM
		je execute_invalid
		cmpb $0b110, OM
		je execute_invalid
		jmp execute_lsr
		
	execute_is10_ii011:
		cmpb $0b000, OM
		je execute_invalid
		cmpb $0b100, OM
		je execute_invalid
		cmpb $0b110, OM
		je execute_invalid
		jmp execute_ror
		
	execute_is10_ii100:
		cmpb $0b000, OM
		je execute_invalid
		cmpb $0b100, OM
		je execute_invalid
		cmpb $0b111, OM
		je execute_invalid
		cmpb $0b010, OM
		je execute_txa
		jmp execute_stx
		
	execute_is10_ii101:
		cmpb $0b100, OM
		je execute_invalid
		jmp execute_ldx
		
	execute_is10_ii110:
		cmpb $0b000, OM
		je execute_invalid
		cmpb $0b100, OM
		je execute_invalid
		cmpb $0b110, OM
		je execute_invalid
		cmpb $0b010, OM
		je execute_dex
		jmp execute_dec
		
	execute_is10_ii111:
		cmpb $0b000, OM
		je execute_invalid
		cmpb $0b100, OM
		je execute_invalid
		cmpb $0b110, OM
		je execute_invalid
		cmpb $0b010, OM
		je execute_nop
		jmp execute_inc
		
	
	#--------------------
	# execute_... (general)
	# Execute a 6502 instruction.
	# This section contains subroutines for all instruction except for branches and flag instructions.
	# See below for those subroutines.
	#--------------------
	
	execute_adc: # add with carry to accumulator
		movl OA, %esi           # \ load the operand ...
		movb (%esi), %al        # /  ... into AL
		testb $0b00001000, P    # \ if the decimal flag is set ...
		jnz execute_adc_bcd     # /  ... use the bcd-version of this routine
		call load_carry_flag    # load the carry flag (note that flag routines leave the general purpose registers, such as EAX, unchanged)
		adcb %al, A             # add the operand (AL) to the accumulator with carry
		jmp store_flags_n_v_z_c # and store the flags
	execute_adc_bcd:
		call load_carry_flag    # load the carry flag (note that flag routines leave the general purpose registers, such as EAX, unchanged)
		adcb A, %al             # \ add the accumulator to the operand (AL) with carry
		daa                     # | correct AL after addition for BCD
		movb %al, A             # / put the result back in the accumulator
		jmp store_flags_n_v_z_c # and store the flags
		
	execute_and: # binary and accumulator with operand
		movl OA, %esi           # \ load the operand ...
		movb (%esi), %al        # /  ... into AL
		andb %al, A             # 'and' the accumulator with the operand
		jmp store_flags_n_z     # and store the negative and zero flags
		
	execute_asl: # arthimetic shift left
		movl OA, %esi           # load the address of the operand (in ESI)
		shlb $1, (%esi)         # shift the operand left, once
		jmp store_flags_n_z_c   # and store the negative, zero and carry flags
		
	execute_bit: # bit test
		movl OA, %esi           # \ load the operand ...
		movb (%esi), %al        # /  ... into AL
		testb %al, A            # execute 'our' (x86) version of 'bit' ('test' is an 'and', without saving the result)
		call store_zero_flag    # store the zero flag (note that flag routines leave the general purpose registers, such as EAX, unchanged)
		andb $0b11000000, %al   # \ get bit 6 and 7 of the operand
		andb $0b00111111, P     # | remove the current bit 6 and 7 from the processor status register ...
		orb %al, P              # /  ... and insert bit 6 and 7 of the operand
		ret
		
	execute_brk: # break
		testb $0b00000100, P    # \ check the interrupt disable flag ...
		jnz execute_no_brk      # /  ... do nothing if it is set
		movw PC, %ax            # /  -> PC
		call push_word          # \ push it on the stack
		call execute_php        # < push the current status flags on the stack
		movb $0b00010000, %al   # /  -> the fake 'P'
		call push_byte          # \ push it on the stack
		movw MEM+0xFFFE, %ax    # \ load the address of the interupt handler ...
		movw %ax, PC            # /  ... into the PC
		ret
	execute_no_brk:             # When the BRK is not executed, it should not skip the next byte.
		decw PC                 # This corrects this default behaviour.
		ret
		
	execute_cmp: # compare with accumulator
		movl OA, %esi           # \ load the operand ...
		movb (%esi), %al        # /  ... into AL
		cmpb %al, A             # compare the operand with the accumulator
		cmc                     # complement carry flag
		jmp store_flags_n_z_c   # and store the flags
		
	execute_cpx: # compare with X (analogous to execute_cmp)
		movl OA, %esi
		movb (%esi), %al
		cmpb %al, X
		cmc
		jmp store_flags_n_z_c
		
	execute_cpy: # compare with y (analogous to execute_cmp)
		movl OA, %esi
		movb (%esi), %al
		cmpb %al, Y
		cmc
		jmp store_flags_n_z_c
		
	execute_dec: # decrement the operand
		movl OA, %esi           # load the address of the operand (in ESI)
		decb (%esi)             # decrement the operand
		jmp store_flags_n_z     # and store the flags
		
	execute_dex: # decrement X
		decb X                  # decrement X
		jmp store_flags_n_z     # and store the flags
		
	execute_dey: # decrement Y
		decb Y                  # decrement Y
		jmp store_flags_n_z     # and store the flags
		
	execute_eor: # binary 'xor' accumulator with operand
		movl OA, %esi           # \ load the operand ...
		movb (%esi), %al        # /  ... into AL
		xorb %al, A             # 'xor' the accumulator with the operand
		jmp store_flags_n_z     # and store the flags
		
	execute_inc: # increment the operand
		movl OA, %esi           # load the address of the operand (in ESI)
		incb (%esi)             # increment the operand
		jmp store_flags_n_z     # and store the flags
		
	execute_inx: # increment X
		incb X                  # increment X
		jmp store_flags_n_z     # and store the flags
		
	execute_iny: # increment Y
		incb Y                  # increment Y
		jmp store_flags_n_z     # and store the flags
		
	execute_jmp: # jump to the address in the operand
		movl OA, %esi           # \ load the operand ...
		movw (%esi), %ax        # |  ... (using AX) ...
		movw %ax, PC            # /  ... into the program counter
		ret
		
	execute_jsr: # jump to subroutine
		movw PC, %ax            # /  -> the current program counter
		call push_word          # \ push it on the stack
		jmp execute_jmp         # execute the jump
		
	execute_lda: # load accumulator
		movl OA, %esi           # \ load the operand ...
		movb (%esi), %al        # |  ... (using AL) ...
		movb %al, A             # /  ... into the accumulator
		testb %al, %al          # update our flags
		jmp store_flags_n_z     # and store these flags
		
	execute_ldx: # load X
		movl OA, %esi           # \ load the operand ...
		movb (%esi), %al        # |  ... (using AL) ...
		movb %al, X             # /  ... into X
		testb %al, %al          # update our flags
		jmp store_flags_n_z     # and store these flags
		
	execute_ldy: # load Y
		movl OA, %esi           # \ load the operand ...
		movb (%esi), %al        # |  ... (using AL) ...
		movb %al, Y             # /  ... into Y
		testb %al, %al          # update our flags
		jmp store_flags_n_z     # and store these flags
		
	execute_lsr: # logical binary shift right
		movl OA, %esi           # load the address of the operand (in ESI)
		shrb $1, (%esi)         # shift the operand right, once
		jmp store_flags_n_z_c   # and store the flags
		
	execute_nop: # no operation
		ret
		
	execute_ora: # binary 'or' accumulator with operand
		movl OA, %esi           # \ load the operand ...
		movb (%esi), %al        # /  ... into AL
		orb  %al, A             # 'or' the accumulator with the operand
		jmp store_flags_n_z     # and store the flags
		
	execute_pha: # push accumulator
		movb A, %al             # /  -> the accumulator
		jmp push_byte           # \ push it on the stack
		
	execute_php: # push processor status register
		movb P, %al             # /  -> the processor status register ...
		jmp push_byte           # \ push it on the stack
		
	execute_pla: # pull accumulator
		call pop_byte           # pop a byte from the stack
		movb %al, A             # and store it in the accumulator
		ret
		
	execute_plp: # pull processor status register
		call pop_byte           # pop a byte from the stack
		movb %al, P             # and store it in the processor status register
		ret
		
	execute_rol: # rotate left with carry
		movl OA, %esi           # load the address of the operand (in ESI)
		call load_carry_flag    # load the carry flag (note that flag routines leave the general purpose registers, such as ESI, unchanged)
		rclb $1, (%esi)         # rotate the operand left with carry
		call store_carry_flag
		movb (%esi), %al
		testb %al, %al
		jmp store_flags_n_z     # and store the flags
		
	execute_ror: # rotate right with carry
		movl OA, %esi           # load the address of the operand (in ESI)
		call load_carry_flag    # load the carry flag (note that flag routines leave the general purpose registers, such as ESI, unchanged)
		rcrb $1, (%esi)         # rotate the operand right with carry
		call store_carry_flag
		movb (%esi), %al
		testb %al, %al
		jmp store_flags_n_z     # and store the flags
		
	execute_rti: # return from interrupt
		call execute_plp        # restore the processor status register from the stack
		call pop_word           # \ pop the old program counter ...
		movw %ax, PC            # / ... into the program counter
		ret
		
	execute_rts: # return from subroutine
		call pop_word           # \ pop the old program counter ...
		incw %ax                # |  ... add the correction ...
		movw %ax, PC            # /  ... and put it in the program counter
		ret
		
	execute_sbc: # subtract with carry
		movl OA, %esi           # \ load the operand ...
		movb (%esi), %al        # /  ... into AL
		testb $0b00001000, P    # \ if the decimal flag is set ...
		jnz execute_sbc_bcd     # /  ... use the bcd-version of this routine
		call load_carry_flag    # load the carry flag (note that flag routines leave the general purpose registers, such as EAX, unchanged)
		cmc                     # complement the carry flag (the x86 uses the carry flag as the 'borrow flag' for sbb, exact the opposite way the 6502 sbc uses the carry flag)
		sbbb %al, A             # subtract the operand (AL) from the accumulator with borrow
		cmc                     # (see previous comment for cmc)
		jmp store_flags_n_v_z_c # and store the flags
	execute_sbc_bcd:
		call load_carry_flag    # load the carry flag (note that flag routines leave the general purpose registers, such as EAX, unchanged)
		cmc                     # complement the carry flag (the x86 uses the carry flag as the 'borrow flag' for sbb, exact the opposite way the 6502 sbc uses the carry flag)
		sbbb %al, A             # \ subtract the operand (AL) from the accumulator with borrow ...
		movb A, %al             # |  ... and store it in AL (DAS will still work since MOV does not modify any flags)
		das                     # | correct AL after subtraction for BCD
		movb %al, A             # / put the result back in the accumulator
		cmc                     # (see previous comment for cmc)
		jmp store_flags_n_v_z_c # and store the flags
		
	execute_sta: # store accumulator in the operand
		movl OA, %edi            # load the address of the operand
		movb A, %al              # \ move the accumulator ...
		movb %al, (%edi)         # /  ... into the operand
		ret
		
	execute_stx: # store X in the operand (analogous to execute_sta)
		movl OA, %edi           # load the address of the operand
		movb X, %al             # \ move X ...
		movb %al, (%edi)        # /  ... into the operand
		ret
		
	execute_sty: # store Y in the operand (analogous to execute_sta)
		movl OA, %edi           # load the address of the operand
		movb Y, %al             # \ move Y ...
		movb %al, (%edi)        # /  ... into the operand
		ret
		
	execute_txa: # transfer X to the accumulator
		movb X, %al              # \ load X ...
		movb %al, A              # /  ... into the accumulator
		testb %al, %al           # update our flags
		jmp store_flags_n_z      # and store these flags
		
	execute_tya: # transfer Y to the accumulator (analogous to execute_txa)
		movb Y, %al              # \ load Y ...
		movb %al, A              # /  ... into the accumulator
		testb %al, %al           # update our flags
		jmp store_flags_n_z      # and store these flags
		
	
	#--------------------
	# execute_... (branches)
	# Branch if a specific flag is cleared/set. Changes the PC to its operand if a specific bit in the P register has the right value.
	# 'testb' does a binary 'and' operation with its operands, and updates the zero flag depending on whether the result is zero or not. This is used to
	# branch only when the condition holds using a call 'execute_branch' using a jz or jnz after testb'ing P with the right bit.
	#--------------------
	
	execute_bcc: # branch if carry flag is clear
		testb $0b00000001, P
		jz execute_branch
		ret
	execute_bcs: # branch if carry flag is set
		testb $0b00000001, P
		jnz execute_branch
		ret
	execute_beq: # branch if equal (i.e. zero flag is set)
		testb $0b00000010, P
		jnz execute_branch
		ret
	execute_bmi: # branch if minus (i.e. negative flag is set)
		testb $0b10000000, P
		jnz execute_branch
		ret
	execute_bne: # branch if not equal (i.e. zero flag is clear)
		testb $0b00000010, P
		jz execute_branch
		ret
	execute_bpl: # branch if plus (i.e. negative flag is clear)
		testb $0b10000000, P
		jz execute_branch
		ret
	execute_bvc: # branch if overflow flag is clear
		testb $0b01000000, P
		jz execute_branch
		ret
	execute_bvs: # branch if overflow flag is set
		testb $0b01000000, P
		jnz execute_branch
		ret
	execute_branch:
		movw BA, %cx   # \ load the BA (branch address) ...
		movw %cx, PC   # /  ... and store it in PC
		ret
		
	
	#--------------------
	# execute_... (flag instructions)
	# Modify flags in the P register.
	# These instructions will set or clear one specific bit of the P register. See flags.s.
	#--------------------
	execute_clc: jmp clear_carry_flag
	execute_sec: jmp set_carry_flag
	execute_cli: jmp clear_interrupt_disable_flag
	execute_sei: jmp set_interrupt_disable_flag
	execute_clv: jmp clear_overflow_flag
	execute_cld: jmp clear_decimal_flag
	execute_sed: jmp set_decimal_flag
		
	
	#--------------------
	# execute_invalid
	# Invalid opcode.
	# Currently, we just ignore invalid opcodes. Maybe we can give some error in the future...
	#--------------------
	execute_invalid:
		ret
		
