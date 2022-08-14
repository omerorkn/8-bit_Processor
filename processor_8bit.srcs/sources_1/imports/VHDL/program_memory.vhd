-- Author / Engineer : omerorkn

-- Program Memory(ROM) (Sub-module of Memory)
------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity program_memory is
	port(
			-- Input Ports
			clk			: in std_logic;
			address		: in std_logic_vector(7 downto 0);

			-- Output Ports
			data_out	: out std_logic_vector(7 downto 0)
	);
end program_memory;

architecture arch of program_memory is

-- All commands:

-- Save / Load Commands
constant LOAD_A_CNS			:std_logic_vector(7 downto 0) := x"86";
constant LOAD_A				:std_logic_vector(7 downto 0) := x"87";
constant LOAD_B_CNS			:std_logic_vector(7 downto 0) := x"88";
constant LOAD_B				:std_logic_vector(7 downto 0) := x"89";
constant SAVE_A				:std_logic_vector(7 downto 0) := x"96";	
constant SAVE_B				:std_logic_vector(7 downto 0) := x"97";

-- ALU Commands		
constant ADD_AB				:std_logic_vector(7 downto 0) := x"42";
constant SUB_AB				:std_logic_vector(7 downto 0) := x"43";
constant AND_AB				:std_logic_vector(7 downto 0) := x"44";
constant OR_AB				:std_logic_vector(7 downto 0) := x"45";
constant UP_A				:std_logic_vector(7 downto 0) := x"46";
constant UP_B				:std_logic_vector(7 downto 0) := x"47";
constant DOWN_A				:std_logic_vector(7 downto 0) := x"48";
constant DOWN_B				:std_logic_vector(7 downto 0) := x"49";

-- Skip Commands (Conditional / Unconditional)
constant SKIP				:std_logic_vector(7 downto 0) := x"20";
constant SKIP_IF_NEG		:std_logic_vector(7 downto 0) := x"21";
constant SKIP_IF_POS		:std_logic_vector(7 downto 0) := x"22";
constant SKIP_EQ_ZERO		:std_logic_vector(7 downto 0) := x"23";
constant SKIP_NOT_ZERO		:std_logic_vector(7 downto 0) := x"24";
constant SKIP_OVERFLOW		:std_logic_vector(7 downto 0) := x"25";
constant SKIP_NOT_OVERFLOW	:std_logic_vector(7 downto 0) := x"26";
constant SKIP_CARRY			:std_logic_vector(7 downto 0) := x"27";
constant SKIP_NOT_CARRY		:std_logic_vector(7 downto 0) := x"28";

type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);
	constant ROM : rom_type := (	
                                	0	=> LOAD_A,
									1	=> x"F0",	-- input port - 00
									2	=> LOAD_B,
									3	=> x"F1",	-- input port - 01
									4 	=> ADD_AB,
									5   => SKIP_EQ_ZERO,
									6   => x"0B",		
									7   => SAVE_A,
									8   => X"80",	
									9	=> SKIP,
									10	=> x"20",
									11	=> LOAD_A,
									12	=> x"F2",	-- input port - 02	
									13  => SKIP,
									14  => x"04",											
									others 	=> x"00"
								);
								
-- Signals:

signal enable : std_logic;
begin

process(address)
begin
	if(address >= x"00" and address <= x"7F") then -- between 0 - 127
		enable <= '1';
	else
		enable <= '0';
	end if;
end process;

process(clk)
begin
	if(rising_edge(clk)) then
		if(enable = '1') then
			data_out <= ROM(to_integer(unsigned(address)));
		end if;
	end if;
end process;

end architecture;