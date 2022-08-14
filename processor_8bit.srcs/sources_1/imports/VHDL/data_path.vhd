-- Author / Engineer : omerorkn

-- Data Path (Sub-module of CPU)
------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity data_path is
	port(
			-- Input Ports
			IR_Load 	: in  std_logic;
			MAR_Load 	: in  std_logic;
			PC_Load 	: in  std_logic;
			PC_Inc 		: in  std_logic;
			A_Load 		: in  std_logic;
			B_Load 		: in  std_logic;
			ALU_Sel 	: in  std_logic_vector(2 downto 0);
			CCR_Load 	: in  std_logic;
			BUS1_Sel 	: in  std_logic_vector(1 downto 0);
			BUS2_Sel 	: in  std_logic_vector(1 downto 0);
			from_memory : in  std_logic_vector(7 downto 0);
			clk			: in  std_logic;
			rst			: in  std_logic;
	
			-- Output Ports
			IR 				:	out  std_logic_vector(7 downto 0);
			CCR_Result 		:	out  std_logic_vector(3 downto 0);
			to_memory		:	out  std_logic_vector(7 downto 0);
			address			:	out  std_logic_vector(7 downto 0)
	
	);
end data_path;

architecture rtl of data_path is

	component ALU is
		port(	
				--Input Ports
				A 			: in std_logic_vector(7 downto 0);
				B 			: in std_logic_vector(7 downto 0);
				ALU_Sel 	: in std_logic_vector(2 downto 0);

				--Output Ports
				NZVC 			: out std_logic_vector(3 downto 0);
				ALU_Result 		: out std_logic_vector(7 downto 0)
		);
	end component;

	signal IR_Reg	 	: std_logic_vector(7 downto 0);
	signal MAR 			: std_logic_vector(7 downto 0);
	signal PC 			: std_logic_vector(7 downto 0);
	signal A_Reg 		: std_logic_vector(7 downto 0);
	signal B_Reg 		: std_logic_vector(7 downto 0);
	signal CCR	 		: std_logic_vector(3 downto 0);
	signal CCR_in		: std_logic_vector(3 downto 0);
	signal BUS1 		: std_logic_vector(7 downto 0);
	signal BUS2 		: std_logic_vector(7 downto 0);
	signal ALU_Result	: std_logic_vector(7 downto 0);

begin 

	--BUS1 MUX--
	BUS1 <= PC	   when BUS1_SEL <= "00" else
			A_Reg  when BUS1_SEL <= "01" else
			B_Reg  when BUS1_SEL <= "10" else (others => '0');
					
	--BUS2 MUX--
	BUS2 <= ALU_Result	 when BUS2_SEL <= "00" else
			BUS1  		 when BUS2_SEL <= "01" else
			from_memory  when BUS2_SEL <= "10" else (others => '0');
			
			
	--IR--
	process(clk,rst)
	begin

		if (rst = '1') then
			IR_Reg <= (others => '0');
		elsif (rising_edge(clk)) then
			if (IR_Load = '1') then
				IR_Reg <= BUS2;
			
			end if;	
		end if;
	end process;
	IR <= IR_Reg;

	--MAR--
	process(clk,rst)
	begin

		if (rst = '1') then
			MAR <= (others => '0');
		elsif (rising_edge(clk)) then
			if (MAR_Load = '1') then
				MAR <= BUS2;
			
			end if;	
		end if;
	end process;

	address <= MAR;
	
	--PC--
	process(clk,rst)
	begin

		if (rst = '1') then
			PC <= (others => '0');
		elsif (rising_edge(clk)) then
			if (PC_Load = '1') then
				PC <= BUS2;
			elsif (PC_Inc = '1' ) then 
				PC  <= PC + x"01";
			end if;	
		end if;
	end process;
	
	--A Register--
	process(clk,rst)
	begin

		if (rst = '1') then
			A_Reg <= (others => '0');
		elsif (rising_edge(clk)) then
			if (A_Load = '1') then
				A_Reg <= BUS2;
			end if;	
		end if;

	end process;
	
	--B Register--
	process(clk,rst)
	begin

		if (rst = '1') then
			B_Reg <= (others => '0');
		elsif (rising_edge(clk)) then
			if (B_Load = '1') then
				B_Reg <= BUS2;
			end if;	
		end if;

	end process;
	
	--ALU Port Map--
	ALU_pm: ALU 
	port map
					(	
						A			=> B_Reg,
						B			=> BUS1,
						ALU_Sel		=> ALU_Sel,
						NZVC		=> CCR_in,
						ALU_Result	=> ALU_Result
						
					);
		
		--CCR_Reg--
		process(clk,rst)
		begin
		
			if (rst = '1') then
				CCR <= (others => '0');
			elsif (rising_edge(clk)) then
				if (CCR_Load = '1') then
					CCR <= CCR_in;
				
				end if;	
			end if;
		
		end process;
	
		CCR_Result <= CCR;
		
		--Data Path to Memory signal
		to_memory <= BUS1;

end rtl;