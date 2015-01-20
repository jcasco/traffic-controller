----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Josue Casco		
-- 
-- Create Date:    17:59:46 04/17/2013 
-- Design Name: 
-- Module Name:    tlcfsm - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: FSM for traffic light controller, changes states after specific
--	time period. For the HG will stay in state if count is less than long wait or
-- car wait is less than short wait. Transitions to HY state for 1 sec. Then 
--	then transitions to SG where it will stay unit count reaches short wait. Stays
-- in SY for 1 sec then back to HG.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tlcfsm is
    Port ( tmr 	: in  STD_LOGIC;
           rst 	: in  STD_LOGIC;
           cs 		: in  STD_LOGIC;
			  HW 		: out  STD_LOGIC_VECTOR (7 downto 0);
           ST 		: out  STD_LOGIC_VECTOR (7 downto 0);
			  carOn	: out STD_LOGIC);
end tlcfsm;

architecture Behavioral of tlcfsm is

type state_type is (HG, HY, SG, SY);
signal state : state_type;

signal cnt : std_logic_vector(3 downto 0);				-- count for state change
signal csc : std_logic_vector(3 downto 0);				-- car sensor count

constant LW : std_logic_vector(3 downto 0) := "1011"; --long wait time
constant SW : std_logic_vector(3 downto 0) := "0011";	--short wait time
constant YEL : std_logic_vector(3 downto 0) := "0001";
   
begin

process(tmr, rst)
begin
	if(rst = '1')then
		state <= HG;
		cnt <= X"0";
		csc <= x"0";

	elsif( tmr' event and tmr = '1') then
		case state is			
			when HG =>  if cs = '1' and csc < sw then				--when button car is sensed
								state <= HG;
								csc <= csc + 1;
								carOn <= '1';
							elsif csc >= X"1" and csc < sw then 	--after car is sensed
								state <= HG;
								csc <= csc + 1;
							elsif cnt < LW  and csc = X"0" then		--no car, regular wait
								state <= HG;
								cnt <= cnt + 1;
							else										--next state
								state <= HY;
								cnt <= X"0";
								csc <= X"0";															
							end if;
			when HY =>	if (cnt < YEL) then					--at yellow for one second
								state <= HY;
								cnt <= cnt + 1;
							else
								state <= SG;
								carOn <= '0';											
								cnt <= X"0";
							end if;								
			when SG =>	if cnt < sw then				--at side street state for short wait
								state <= SG;
								cnt <= cnt + 1;
							else
								state <= SY;
								cnt <= X"0";
							end if;	
			when SY =>	if cnt < YEL then				--at yellow for one second
								state <= SY;
								cnt <= cnt + 1;
							else
								state <= HG;
								cnt <= X"0";
							end if;						
			when others =>
							state <= HG;
		end case;
	end if;
end process;
			
process(state)							--state outputs for highway and side street lights
begin
	case state is
		when HG => HW <="11110111";
					  ST <="10111111";
		when HY => HW <="11111110";
					  ST <="10111111";
		when SG => HW <="10111111";
					  ST <="11110111";
		when SY => HW <="10111111";
					  ST <="11111110";
		when others =>
					  HW <="10111111";
					  ST <="10111111";
	end case;
end process;	

end Behavioral;

