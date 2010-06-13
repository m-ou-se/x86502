# File: 6502.s
# Global functions: init, step
# Global variables: MEM, IR, A, X, Y, S, P, PC, IS, II, OM, OA, BA, IC

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


.global init, step
.global MEM, IR, A, X, Y, S, P, PC, IS, II, OM, OA, BA, IC

.data
	
	# The memory of the 6502
	MEM: 
		.incbin "coptergame/coptergame.65b"
	
	# The registers of the 6502
	A:  .byte 0        # accumulator
	X:  .byte 0        # general purpose register
	Y:  .byte 0        # general purpose register
	S:  .byte 0xFF     # stack pointer
	P:  .byte 0        # processor status register (bits: NOXBDIZC -> negative, overflow, unused, break, decimal, interrupt disable, zero, carry)
	IR: .byte 0        # instruction register (contains the current instruction)
	IS: .byte 0        # instruction set of the current instruction (the least significant two bits of IR)
	II: .byte 0        # instruction index of the current instruction (the most significant three bits of IR)
	OM: .byte 0        # the operand mode of the current instruction (the three bits between IS and II in IR)
	OA: .long 0        # a pointer to the operand of the current instruction
	BA: .word 0        # the 'branch address': only used by branch instructions... the new value for PC after the branch is taken (if it is taken anyway)
	PC: .word 0        # program counter (points to the next instruction)
	
	
.text
	
	#--------------------
	# init
	# Initialize the 6502.
	#--------------------
	init:
		movw MEM+0xFFFC, %ax    # \ load the initial PC from memory ...
		movw %ax, PC            # /  ... and store it in the program counter
		ret
		
	#--------------------
	# step
	# Execute the next instruction.
	#--------------------
	step:
		call read               # < read the next instruction and its operand
		call execute            # < execute the instruction
		ret
		
