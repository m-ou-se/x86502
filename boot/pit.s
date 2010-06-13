# File: pit.s
# Global functions: set_timer_frequency, set_timer_rate, set_speaker_frequency, enable_speaker, disable_speaker
# Global variables: -
# Description: Everything related to the Programmable Interval Timer is located in this file.

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


.global set_timer_frequency, set_timer_rate, set_speaker_frequency, enable_speaker, disable_speaker

.text
	
	
	#--------------------
	# set_timer_frequency(frequency)
	# Set the frequency of the timer that causes IRQ0.
	#--------------------
	# Note: See http://wiki.osdev.org/PIT
	set_timer_frequency:
		movl $0, %edx
		movl $1193046, %eax
		divl 4(%esp)
		pushl %eax
		call set_timer_rate
		addl $4, %esp
		ret
		
	#--------------------
	# set_timer_rate(rate)
	# Set the rate of the timer that causes IRQ.
	#--------------------
	# Note: See http://wiki.osdev.org/PIT
	set_timer_rate:
		movb $0x34, %al # channel 0, rate generator mode -> ...
		outb %al, $0x43 #  ... PIT Mode/Command port
		movl 4(%esp), %eax
		outb %al, $0x40 # low byte -> PIT channel 0 data port
		movb %ah, %al   # high byte -> ...
		outb %al, $0x40 #  ... PIT channel 0 data port
		ret
		
	
	#--------------------
	# set_speaker_frequency(frequency)
	# Set the frequency of the timer that controls the speaker.
	#--------------------
	# Note: See http://wiki.osdev.org/PIT
	set_speaker_frequency:
		movb $0xB6, %al # channel 2, square wave generator mode
		outb %al, $0x43 # PIT Mode/Command port
		movl $0, %edx
		movl $1193046, %eax
		divl 4(%esp)
		outb %al, $0x42 # low byte -> PIT channel 2 data port
		movb %ah, %al   # high byte -> ...
		outb %al, $0x42 #  ... PIT channel 2 data port
		ret
		
	
	#--------------------
	# enable_speaker
	# Enable the mainboard speaker.
	#--------------------
	# Note: See http://wiki.osdev.org/PC_Speaker
	enable_speaker:
		inb $0x61, %al
		orb $0b00000011, %al
		outb %al, $0x61
		ret
		
	#--------------------
	# disable_speaker
	# Disable the mainboard speaker.
	#--------------------
	# Note: See http://wiki.osdev.org/PC_Speaker
	disable_speaker:
		inb $0x61, %al
		andb $0b11111100, %al
		outb %al, $0x61
		ret
		
