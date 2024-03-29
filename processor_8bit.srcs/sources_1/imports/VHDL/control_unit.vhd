-- Author / Engineer : omerorkn

-- Control Unit (Sub-module of CPU)
------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity control_unit is
	port(
			-- Input Ports
			clk			: in std_logic;
			rst			: in std_logic;
			CCR_Result	: in std_logic_vector(3 downto 0);
			IR			: in std_logic_vector(7 downto 0);
			-- Output Ports
			IR_Load		: out std_logic;	
			MAR_Load 	: out std_logic;
			PC_Load 	: out std_logic;
			PC_Inc 		: out std_logic;
			A_Load 		: out std_logic;
			B_Load 		: out std_logic;
			ALU_Sel 	: out std_logic_vector(2 downto 0);
			CCR_Load 	: out std_logic;
			BUS1_Sel	: out std_logic_vector(1 downto 0);
			BUS2_Sel	: out std_logic_vector(1 downto 0);
			write_en	: out std_logic

	);
end control_unit;

architecture rtl of control_unit is

type state_type_t is  (
						S_FETCH_0, S_FETCH_1, S_FETCH_2, S_DECODE_3,
						S_LDA_IMM_4, S_LDA_IMM_5, S_LDA_IMM_6,
						S_LDA_DIR_4, S_LDA_DIR_5, S_LDA_DIR_6, S_LDA_DIR_7, S_LDA_DIR_8,
						S_LDB_IMM_4, S_LDB_IMM_5, S_LDB_IMM_6,
						S_LDB_DIR_4, S_LDB_DIR_5, S_LDB_DIR_6, S_LDB_DIR_7, S_LDB_DIR_8,
						S_STA_DIR_4, S_STA_DIR_5, S_STA_DIR_6, S_STA_DIR_7,
						S_ADD_AB_4,
						S_BRA_4, S_BRA_5, S_BRA_6,
						S_BEQ_4, S_BEQ_5, S_BEQ_6, S_BEQ_7
					);
					
signal current_state, next_state : state_type_t;

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

begin

	-- Current State Logic
	process (clk, rst)
	begin

		if (rst = '1') then
			current_state <= S_FETCH_0;
		elsif (rising_edge(clk)) then
			current_state <= next_state;
		end if;

	end process;

	-- Next State Logic
	process(current_state, IR, CCR_Result)
	begin
		
		case current_state is

			when S_FETCH_0  =>

				next_state <= S_FETCH_1;

			when S_FETCH_1  =>

				next_state <= S_FETCH_2;

			when S_FETCH_2  =>

				next_state <= S_DECODE_3;

			when S_DECODE_3  =>

				if (IR = LOAD_A_CNS) then
					next_state <= S_LDA_IMM_4;
				elsif (IR = LOAD_A) then
					next_state <= S_LDA_DIR_4;
				elsif (IR = LOAD_B_CNS) then
					next_state <= S_LDB_IMM_4;
				elsif (IR = LOAD_B) then
					next_state <= S_LDB_DIR_4;
				elsif (IR = SAVE_A) then
					next_state <= S_STA_DIR_4;
				elsif (IR = ADD_AB) then
					next_state <= S_ADD_AB_4;
				elsif (IR = SKIP) then
					next_state <= S_BRA_4;
				elsif (IR = SKIP_EQ_ZERO) then
					if (CCR_Result(2) = '1') then	-- NZVC, Zero info on bit 2
						next_state <= S_BEQ_4;
					else	-- Z = '0'
						next_state <= S_BEQ_7;
					end if;
				else
					next_state <= S_FETCH_0;
				end if;

			when S_LDA_IMM_4 =>

				next_state <= S_LDA_IMM_5;

			when S_LDA_IMM_5 =>
			
				next_state <= S_LDA_IMM_6;

			when S_LDA_IMM_6 =>

				next_state <= S_FETCH_0;

		
			when S_LDA_DIR_4 =>

				next_state <= S_LDA_DIR_5;

			when S_LDA_DIR_5 =>

				next_state <= S_LDA_DIR_6;

			when S_LDA_DIR_6 =>

				next_state <= S_LDA_DIR_7;

			when S_LDA_DIR_7 =>	

				next_state <= S_LDA_DIR_8;

			when S_LDA_DIR_8 =>

				next_state <= S_FETCH_0;

			when S_LDB_IMM_4 =>

				next_state <= S_LDB_IMM_5;

			when S_LDB_IMM_5 =>

				next_state <= S_LDB_IMM_6;

			when S_LDB_IMM_6 =>

				next_state <= S_FETCH_0;
		
			when S_LDB_DIR_4 =>

				next_state <= S_LDB_DIR_5;

			when S_LDB_DIR_5 =>

				next_state <= S_LDB_DIR_6;

			when S_LDB_DIR_6 =>

				next_state <= S_LDB_DIR_7;

			when S_LDB_DIR_7 =>	

				next_state <= S_LDB_DIR_8;

			when S_LDB_DIR_8 =>
			
				next_state <= S_FETCH_0;
			
			when S_STA_DIR_4 =>

				next_state <= S_STA_DIR_5;

			when S_STA_DIR_5 =>

				next_state <= S_STA_DIR_6;

			when S_STA_DIR_6 =>

				next_state <= S_STA_DIR_7;

			when S_STA_DIR_7 =>

				next_state <= S_FETCH_0;

			when S_ADD_AB_4 =>

				next_state <= S_FETCH_0;

			when S_BRA_4 =>

				next_state <= S_BRA_5;

			when S_BRA_5 =>

				next_state <= S_BRA_6;

			when S_BRA_6 =>

				next_state <= S_FETCH_0;

			when S_BEQ_4 =>

				next_state <= S_BEQ_5;

			when S_BEQ_5 =>

				next_state <= S_BEQ_6;

			when S_BEQ_6 =>

				next_state <= S_FETCH_0;
				
			when S_BEQ_7 =>						-- Z = '0' condition

				next_state <= S_FETCH_0;

			when others =>

				next_state <= S_FETCH_0;	
				
		end case;	
	end process;

	-- Output Logic

	process(current_state)
	begin

		IR_Load <= '0';
		MAR_Load <= '0';
		PC_Load <= '0';
		PC_Inc <= '0';
		A_Load <= '0';
	    B_Load <= '0';
		ALU_Sel <= (others => '0');
		CCR_Load <= '0';
		BUS1_Sel <= (others => '0');
		BUS2_Sel <= (others => '0');
		write_en <= '0';
		
		case current_state is
			
			when S_FETCH_0  =>
				
				BUS1_Sel <= "00"; 				-- PC
				BUS2_Sel <= "01"; 				-- BUS1
				MAR_Load <= '1';  				-- program counter on BUS2 to MAR
			when S_FETCH_1  =>

				PC_Inc <= '1';

			when S_FETCH_2  =>

				BUS2_Sel <= "10";				-- from memory
				IR_Load <= '1';

			when S_DECODE_3  =>
				-- next state updated already

			when S_LDA_IMM_4 =>

				BUS1_Sel <= "00";				-- PC
				BUS2_Sel <= "01"; 				-- BUS1
				MAR_Load <= '1';  				-- program counter on BUS2 to MAR
			when S_LDA_IMM_5 =>

				PC_Inc <= '1';	
			when S_LDA_IMM_6 =>

				BUS2_Sel <= "10";				-- from memory
				A_Load <= '1';
		
			when S_LDA_DIR_4 =>

				BUS1_Sel <= "00";				-- PC
				BUS2_Sel <= "01"; 				-- BUS1
				MAR_Load <= '1';  				-- program counter on BUS2 to MAR

			when S_LDA_DIR_5 =>

				PC_Inc <= '1';	

			when S_LDA_DIR_6 =>

				BUS2_Sel <= "10";				-- from memory
				MAR_Load <= '1';  				-- program counter on BUS2 to MAR

			when S_LDA_DIR_7 =>	

				-- NONE : Waits reading from memory

			when S_LDA_DIR_8 =>

				BUS2_Sel <= "10";				-- from memory
				A_Load <= '1';

			when S_LDB_IMM_4 =>

				BUS1_Sel <= "00";				-- PC
				BUS2_Sel <= "01"; 				-- BUS1
				MAR_Load <= '1';  				-- program counter on BUS2 to MAR

			when S_LDB_IMM_5 =>

				PC_Inc <= '1';

			when S_LDB_IMM_6 =>

				BUS2_Sel <= "10";				-- from memory
				B_Load <= '1';

			when S_LDB_DIR_4 =>

				BUS1_Sel <= "00";				-- PC
				BUS2_Sel <= "01"; 				-- BUS1
				MAR_Load <= '1';  				-- program counter on BUS2 to MAR

			when S_LDB_DIR_5 =>

				PC_Inc <= '1';
			when S_LDB_DIR_6 =>

				BUS2_Sel <= "10";				-- from memory
				MAR_Load <= '1';  				-- program counter on BUS2 to MAR

			when S_LDB_DIR_7 =>

				-- NONE : Waits reading from memory

			when S_LDB_DIR_8 =>

				BUS2_Sel <= "10";				-- from memory
				B_Load <= '1';

			when S_STA_DIR_4 =>

				BUS1_Sel <= "00";				-- PC
				BUS2_Sel <= "01"; 				-- BUS1
				MAR_Load <= '1';  				-- program counter on BUS2 to MAR

			when S_STA_DIR_5 =>

				PC_Inc <= '1';

			when S_STA_DIR_6 =>

				BUS2_Sel <= "10";				-- from memory
				MAR_Load <= '1';  				-- program counter on BUS2 to MAR

			when S_STA_DIR_7 =>

				BUS1_Sel <= "01";				-- A_reg
				write_en <= '1';

			when S_ADD_AB_4 =>

				BUS1_Sel <= "01";				-- A_reg
				BUS2_Sel <= "00";				-- ALU result
				ALU_Sel <= "000";				-- addition code from ALU
				A_Load <= '1';
				CCR_Load <= '1';

			when S_BRA_4 =>

				BUS1_Sel <= "00";				-- PC
				BUS2_Sel <= "01"; 				-- BUS1
				MAR_Load <= '1';  				-- program counter on BUS2 to MAR

			when S_BRA_5 =>

				-- NONE

			when S_BRA_6 =>

				BUS2_Sel <= "10";				-- from memory
				PC_Load <= '1';					-- BUS2 data to program counter register


			when S_BEQ_4 =>

				BUS1_Sel <= "00";				-- PC
				BUS2_Sel <= "01"; 				-- BUS1
				MAR_Load <= '1';  				-- program counter on BUS2 to MAR	

			when S_BEQ_5 =>
				
				-- NONE
			when S_BEQ_6 =>

				BUS2_Sel <= "10";				-- from memory
				PC_Load <= '1';					-- Program sayaci registerina BUS2 verisini al

			when S_BEQ_7 =>	-- Z = '0' condition
				PC_Inc <= '1';

			when others =>

				IR_Load <= '0';
				MAR_Load <= '0';
				PC_Load <= '0';
				A_Load <= '0';
			    B_Load <= '0';
				ALU_Sel <= (others => '0');
				CCR_Load <= '0';
				BUS1_Sel <= (others => '0');
				BUS2_Sel <= (others => '0');
				write_en <= '0';		
				
		end case;
	end process;

end rtl;