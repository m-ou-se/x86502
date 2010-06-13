# File: operand.s
# Global functions: getoperand
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


.global getoperand

.text
	
	# Note: See instructions.html for an overview of the instructions and which operand modes they use.
	
	#--------------------
	# getoperand
	# Returns a pointer to the operand of the current instruction.
	# Advances the PC if needed.
	#--------------------
	getoperand:
		movzbl OM, %esi                     # \
		jmp * getoperand_om_switch(,%esi,4) # / switch-case (using a lookup table) for the operand mode (OM)
		
	# Switch table for all operand modes
	getoperand_om_switch:
		.long getoperand_om000
		.long getoperand_om001
		.long getoperand_om010
		.long getoperand_om011
		.long getoperand_om100
		.long getoperand_om101
		.long getoperand_om110
		.long getoperand_om111
		
	
	getoperand_om000: # all instructions in set 01 with an OM of 000 use indirect X operand mode, in the other instruction sets, immediate operand mode is used
		cmpb $0b01, IS     # \ if the instruction set is 01 ...
		je getoperand_inx  # /  ... use indirect X operand mode
		jmp getoperand_imm # otherwise, use immediate operand mode
		
	getoperand_om001: # all instructions with an OM of 001 use zero page operand mode
		jmp getoperand_zp  # use zero page operand mode
		
	getoperand_om010: # all instructions in set 01 with an OM of 010 use immediate operand mode, in the other instruction sets, accumulator operand mode is used
		cmpb $0b01, IS     # \ if the instruction set is 01 ...
		je getoperand_imm  # /  ... use immediate
		jmp getoperand_acc # otherwise, use accumulator operand mode
		
	getoperand_om011: # all instructions with an OM of 011, except the absolute JMP, use absolute operand mode
		cmpb $0x4C, IR     # \ if the instruction is 0x4C  (absolute JMP) ...
		je getoperand_imm  # /  ... use immediate operand mode
		jmp getoperand_abs # otherwise, use absolute operand mode
		
	getoperand_om100: # all instructions in set 01 with an OM of 100 use indirect Y operand mode, in the other instruction sets, relative operand mode is used
		cmpb $0b01, IS     # \ if the instruction set is 01 ...
		je getoperand_iny  # /  ... use indirect Y operand mode
		jmp getoperand_rel # otherwise, use relative operand mode
		
	getoperand_om101: # all instructions with an OM of 101, except STX and LDX, use zero page X operand mode
		cmpb $0x96, IR     # \ if the instruction is 0x96 (STX) ...
		je getoperand_zpy  # /  ... use zero page Y operand mode
		cmpb $0xB6, IR     # \ if the instruction is 0xB6 (LDX) ...
		je getoperand_zpy  # /  ... use zero page Y operand mode
		jmp getoperand_zpx # otherwise, use zero page X operand mode
		
	getoperand_om110: # all instructions in set 01 with an OM of 110 use absolute memory Y operand mode, in the other instruction sets, stack pointer operand mode is used
		cmpb $0b01, IS     # \ if the instruction set is 01 ...
		je getoperand_aby  # /  ... use absolute memory Y operand mode
		jmp getoperand_sp  # otherwise, use stack pointer operand mode
		
	getoperand_om111: # all instructions with an OM of 111, except LDX, use absolute X operand mode
		cmpb $0xBE, IR      # \ if the instruction is 0xBE (LDX) ...
		je getoperand_aby   # /  ... use absolute Y operand mode
		jmp getoperand_abx  # otherwise, use absolute X operand mode
		
	
	getoperand_imm: # immediate operand mode
		movzwl PC, %ecx         # get the address of the next byte in the 6502 memory (after the current instruction, that's where the immediate is stored)
		incw PC                 # increase the PC, because the byte it's currently pointing to is (being) processed
		leal MEM(%ecx), %eax    # return the address of the immediate operand
		ret
		
	getoperand_zp: # zero page operand mode
		movzwl PC, %ecx         # \ read one byte ...
		movzbl MEM(%ecx), %ecx  # |  ... into ECX ...
		incw PC                 # /  ... and increase the PC
		leal MEM(%ecx), %eax    # return the address of the byte with the address of ECX in the 6502 memory
		ret
		
	getoperand_zpx: # zero page X operand mode
		movzwl PC, %ecx         # \ read one byte ...
		movzbl MEM(%ecx), %ecx  # |  ... into ECX ...
		incw PC                 # /  ... and increase the PC
		addb X, %cl             # add X to the low byte of ECX
		leal MEM(%ecx), %eax    # return the address of the byte with the address of ECX in the 6502 memory
		ret
		
	getoperand_zpy: # zero page Y operand mode
		movzwl PC, %ecx         # \ read one byte ...
		movzbl MEM(%ecx), %ecx  # |  ... into ECX ...
		incw PC                 # /  ... and increase the PC
		addb Y, %cl             # add Y to the low byte of ECX
		leal MEM(%ecx), %eax    # return the address of the byte with the address of ECX in the 6502 memory
		ret
		
	getoperand_abs: # absolute memory operand mode
		movzwl PC, %ecx         # \ read two bytes ...
		movzwl MEM(%ecx), %ecx  # |  ... into ECX ...
		addw $2, PC             # /  ... and increase the PC
		leal MEM(%ecx), %eax    # return the address of the byte with the address of ECX in the 6502 memory
		ret
		
	getoperand_abx: # absolute memory X operand mode
		movzwl PC, %ecx         # \ read two bytes ...
		movzwl MEM(%ecx), %ecx  # |  ... into ECX ...
		addw $2, PC             # /  ... and increase the PC
		movzbw X, %ax           # \ add X
		addw %ax, %cx           # /  ... to it
		leal MEM(%ecx), %eax    # return the address of the byte with the address of ECX in the 6502 memory
		ret
		
	getoperand_aby: # absolute memory Y operand mode
		movzwl PC, %ecx         # \ read two bytes ...
		movzwl MEM(%ecx), %ecx  # |  ... into ECX ...
		addw $2, PC             # /  ... and increase the PC
		movzbw Y, %ax           # \ add Y
		addw %ax, %cx           # /  ... to it
		leal MEM(%ecx), %eax    # return the address of the byte with the address of ECX in the 6502 memory
		ret
		
	getoperand_inx: # indirect X operand mode
		movzwl PC, %ecx         # \ read one byte ...
		movzbl MEM(%ecx), %ecx  # |  ... into ECX ...
		incw PC                 # /  ... and increase the PC
		addb X, %cl             # add X to the low byte of ECX
		movzwl MEM(%ecx), %ecx  # read the address at this location on the zero page into ECX
		leal MEM(%ecx), %eax    # return the address of the byte with the address of ECX in the 6502 memory
		ret
		
	getoperand_iny: # indirect Y operand mode
		movzwl PC, %ecx         # \ read one byte ...
		movzbl MEM(%ecx), %ecx  # |  ... into ECX ...
		incw PC                 # /  ... and increase the PC
		movzwl MEM(%ecx), %ecx  # read the address at this location on the zero page into ECX
		movzbw Y, %ax           # \ add Y ...
		addw %ax, %cx           # / ... to this address
		leal MEM(%ecx), %eax    # return the address of the byte with the address of ECX in the 6502 memory
		ret
		
	getoperand_rel: # relative operand mode
		movzwl PC, %ecx         # \ read one byte ...
		movsbw MEM(%ecx), %ax   # |  ... (sign extended) into AX ...
		incw %cx                # |  ... and increase ...
		movw %cx, PC            # /  ... the PC
		addw %ax, %cx           # add it to the (new) PC
		movw %cx, BA            # store it in BA (branch address)
		leal BA, %eax           # return the address of BA
		ret
		
	getoperand_acc: # accumulator operand mode
		leal A, %eax            # return the address of the accumulator
		ret
		
	getoperand_sp: # stack pointer operand mode
		leal S, %eax            # return the address of the stack pointer
		ret
		
