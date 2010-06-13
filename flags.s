# File: flags.s
# Global functions: set_carry_flag, clear_carry_flag, set_zero_flag, clear_zero_flag,
#                   set_interrupt_disable_flag, clear_interrupt_disable_flag,
#                   set_decimal_flag, clear_decimal_flag, set_break_flag, clear_break_flag,
#                   set_overflow_flag, clear_overflow_flag, set_negative_flag, clear_negative_flag
#                   store_carry_flag, load_carry_flag, store_zero_flag, store_overflow_flag, store_negative_flag
#                   store_flags_n_z, store_flags_n_z_c, store_flags_n_v_c, store_flags_n_v_z_c
# Global variables: -

# Note: All functions in this file will preserve all the general purpose registers (EAX, EBX, ECX, EDX, ESI, EDI). However, all of them will change the flags.

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


.global set_carry_flag,             clear_carry_flag
.global set_zero_flag,              clear_zero_flag
.global set_interrupt_disable_flag, clear_interrupt_disable_flag
.global set_decimal_flag,           clear_decimal_flag
.global set_break_flag,             clear_break_flag
.global set_overflow_flag,          clear_overflow_flag
.global set_negative_flag,          clear_negative_flag
.global load_carry_flag
.global store_carry_flag, store_zero_flag, store_overflow_flag, store_negative_flag
.global store_flags_n_z, store_flags_n_z_c, store_flags_n_v_c, store_flags_n_v_z_c

.text
	
	#--------------------
	# set/clear_..._flag 
	# Modify flags in the P register. These functions will set or clear one specific bit of the P register.
	# This is done with 'and' and 'or' operatons using this simple fact: and'ing a bit with 0 clears it, or'ing it with 1 sets it. The other two
	# possibilities (and'ing with 1 and or'ing with 0) leave the bit unchanged.
	#--------------------
	
	clear_carry_flag:
		andb $0b11111110, P
		ret
	set_carry_flag:
		orb  $0b00000001, P
		ret
		
	clear_zero_flag:
		andb $0b11111101, P
		ret
	set_zero_flag:
		orb  $0b00000010, P
		ret
		
	clear_interrupt_disable_flag:
		andb $0b11111011, P
		ret
	set_interrupt_disable_flag:
		orb  $0b00000100, P
		ret
		
	clear_decimal_flag:
		andb $0b11110111, P
		ret
	set_decimal_flag:
		orb  $0b00001000, P
		ret
		
	clear_break_flag:
		andb $0b11101111, P
		ret
	set_break_flag:
		orb  $0b00010000, P
		ret
		
	clear_overflow_flag:
		andb $0b10111111, P
		ret
	set_overflow_flag:
		orb  $0b01000000, P
		ret
		
	clear_negative_flag:
		andb $0b01111111, P
		ret
	set_negative_flag:
		orb  $0b10000000, P
		ret
		
	
	#--------------------
	# load_carry_flag 
	# Copy the carry flag from the virtual 6502 to our x86.
	# The carry flag is the only one that alters the results
	# of certain instructions, and thus the only one we need to copy to our x86.
	#--------------------
	
	load_carry_flag:
		testb $0b00000001, P
		jnz load_carry_flag_set
	load_carry_flag_clear:
		clc
		ret
	load_carry_flag_set:
		stc
		ret
		
	
	#--------------------
	# store_..._flag 
	# Copy a flag from our x86 to the virtual 6502.
	#--------------------
	
	store_carry_flag:
		jc set_carry_flag
		jmp clear_carry_flag
		
	store_zero_flag:
		jz set_zero_flag
		jmp clear_zero_flag
		
	store_overflow_flag:
		jo set_overflow_flag
		jmp clear_overflow_flag
		
	store_negative_flag:
		js set_negative_flag
		jmp clear_negative_flag
		
	
	#--------------------
	# store_flags_n[_v][_z][_c] - Copy multiple flags from our x86 to the virtual 6502.
	# Use a 'binary flag jump search' to figure out what flags to set before setting any.
	# This way we don't have to pushf and popf each time.
	#--------------------
	
	# Copy the negative and zero flag from our x86 to the virtual 6502
	store_flags_n_z: #n-----z-
		js nz_1x                # check if negative (sign) flag should be set
		jz nz_01                # check if zero flag should be set
	nz_00: 
		andb $0b01111101, P     # unset negative and zero flag
		ret
	nz_01: 
		andb $0b01111111, P     # unset negative flag
		orb  $0b00000010, P     # set zero flag
		ret
	nz_1x: 
		jz nz_11                # check if zero flag should be set
	nz_10: 
		andb $0b11111101, P     # unset zero flag
		orb  $0b10000000, P	    # set negative flag
		ret	
	nz_11: 
		orb  $0b10000010, P     # set negative and zero flag (negative zero lolwut?)
		ret
		
	
	
	# Copy the negative, zero and carry flag from our x86 to the virtual 6502
	store_flags_n_z_c: #n-----zc
		js nzc_1xx              # check if negative flag should be set
		jz nzc_01x              # check if zero flag should be set
		jc nzc_001              # check if carry flag should be set
	nzc_000: 
		andb $0b01111100, P     # unset the negative, zero and carry flag
		ret
	nzc_001: 
		andb $0b01111100, P     # unset the negative and zero flag
		orb  $0b00000001, P     # set the carry flag
		ret
	nzc_01x: 
		jc nzc_011              # check if the cary flag should be set
	nzc_010: 
		andb $0b01111110, P     # unset the negative and carry flag
		orb  $0b00000010, P     # set the zero flag
		ret
	nzc_011: 
		andb $0b01111111, P     # unset the negative flag
		orb  $0b00000011, P     # set the zero and carry flag
		ret
	nzc_1xx: 
		jz nzc_11x              # check if zero flag should be set
		jc nzc_101              # check if carry flag should be set
	nzc_100: 
		andb $0b11111100, P     # unset the zero and carry flag
		orb  $0b10000000, P     # set the negative flag
		ret
	nzc_101: 
		andb $0b11111101, P     # unset the zero flag
		orb  $0b10000001, P     # set the negative and carry flag
		ret
	nzc_11x: 
		jc nzc_111              # check if carry flag should be set
	nzc_110:
		andb $0b11111110, P     # unset the carry flag
		orb  $0b10000010, P     # set the negative and zero flag (negative zero lolwut?)
		ret
	nzc_111:
		orb  $0b10000011, P     # set the negative, zero and carry flag
		ret
	
	# Copy the negative, overflow and zero flag from our x86 to the virtual 6502
	store_flags_n_v_z: #nv----z-
		js nvz_1xx 
		jo nvz_01x              # check if overflow flag should be set
		jz nvz_001              # check if zero flag should be set
	nvz_000:
		andb $0b01111100, P     # unset the negative, overflow and zero flag
		ret
	nvz_001:
		andb $0b00111111, P     # unset the negative and overflow flag
		orb  $0b00000010, P     # set the zero flag
		ret
	nvz_01x:
		jz nvz_011              # check if zero flag should be set
	nvz_010:
		andb $0b01111101, P     # unset the negative and zero flag
		orb  $0b01000000, P     # set the overflow flag
		ret
	nvz_011:
		andb $0b01111111, P     # unset the negative flag
		orb  $0b01000010, P     # set the overflow and zero flag
		ret
	nvz_1xx:
		jo nvz_11x              # check if overflow flag should be set
		jz nvz_101              # check if zero flag should be set
	nvz_100:
		andb $0b10111101, P     # unset the overflow and zero flag
		orb  $0b10000000, P     # set the negative flag
		ret
	nvz_101:
		andb $0b10111111, P     # unset the overflow flag
		orb  $0b10000010, P     # set the negative and zero flag
		ret
	nvz_11x:
		jz nvz_111              # check if zero flag should be set
	nvz_110:
		andb $0b11111101, P     # unset the zero flag
		orb  $0b11000000, P     # set the negative and overflow flag
		ret
	nvz_111:
		orb  $0b11000010, P     # set the negative, overflow and zero flag
		ret
		
		
	# Copy the negative, overflow, zero and carry flag from our x86 to the virtual 6502
	store_flags_n_v_z_c: #nv----zc
		js nvzc_1xxx 
		jo nvzc_01xx            # check if overflow flag should be set
		jz nvzc_001x            # check if zero flag should be set
		jc nvzc_0001            # check if carry flag should be set
	nvzc_0000:
		andb $0b00111100, P     # unset the negative, overflow, zero and carry flag
		ret
	nvzc_0001:
		andb $0b00111101, P     # unset the negative, overflow and zero flag
		orb  $0b00000001, P     # set the carry flag
		ret
	nvzc_001x:
		jc nvzc_0011            # check if carry flag should be set
	nvzc_0010:
		andb $0b00111110, P     # unset the negative, overflow and carry flag
		orb  $0b00000010, P     # set the zero flag
		ret
	nvzc_0011:
		andb $0b00111111, P     # unset the negtaive and overflow flag
		orb  $0b00000011, P     # set the negative and carry flag
		ret
	nvzc_01xx:
		jz nvzc_011x            # check if zero flag should be set
		jc nvzc_0101            # check if carry flag should be set
	nvzc_0100:
		andb $0b10111100, P     # unset the negative, zero and carry flag
		orb  $0b00100000, P     # set the overflow flag
		ret
	nvzc_0101:
		andb $0b01111101, P     # unset the negative and zero flag
		orb  $0b01000001, P     # set the overflow and carry flag
		ret
	nvzc_011x:
		jc nvzc_0111            # check if carry flag should be set
	nvzc_0110:
		andb $0b01111110, P     # unset the negative and carry flag
		orb  $0b01000010, P     # set the overflow and zero flag
		ret
	nvzc_0111:
		andb $0b01111111, P     # unset the negative flag
		orb  $0b01000011, P     # set the overflow, zero and carry flag
		ret
	nvzc_1xxx:
		jo nvzc_11xx            # check if overflow flag should be set
		jz nvzc_101x            # check if zero flag should be set
		jc nvzc_1001            # check if carry flag should be set
	nvzc_1000:
		andb $0b10111100, P     # unset the overflow, zero and carry flag
		orb  $0b10000000, P     # set the negative flag
		ret
	nvzc_1001:
		andb $0b10111101, P     # unset the overflow and zero flag
		orb  $0b10000001, P     # set the negative and carry flag
		ret
	nvzc_101x:
		jc nvzc_1011            # check if carry flag should be set
	nvzc_1010: 
		andb $0b10111110, P     # unset the overflow and carry flag
		orb  $0b10000010, P     # set the negative and zero flag
		ret
	nvzc_1011:
		andb $0b10111111, P     # unset the overflow flag
		orb  $0b10000011, P     # set the negative, zero and carry flag
		ret
	nvzc_11xx:
		jz nvzc_111x            # check if zero flag should be set
		jc nvzc_1101            # check if carry flag should be set
	nvzc_1100:
		andb $0b11111100, P     # unset the zero and carry flag
		orb  $0b11000000, P     # set the negative and overflow flag
		ret
	nvzc_1101:
		andb $0b11111101, P     # unset the zero flag
		orb  $0b11000001, P     # set the negative, overflow and carry flag
		ret
	nvzc_111x:
		jc nvzc_1111            # check if carry flag should be set
	nvzc_1110: 
		andb $0b11111110, P     # unset the carry flag
		orb  $0b11000010, P     # set the negative, overflow and zero flag
		ret
	nvzc_1111:
		orb  $0b11000011, P     # set the negative, overflow, zero and carry flag
		ret
		
