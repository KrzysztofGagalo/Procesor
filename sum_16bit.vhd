-- Komponent sumatora 16-bitowego
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Adder is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);
           SUM : out STD_LOGIC_VECTOR (15 downto 0);
           ADD_SUB : in STD_LOGIC);  -- Sygnał sterujący operacją (0 - dodawanie, 1 - odejmowanie)
end Adder;

architecture Behavioral of Adder is
begin
    process(A, B, ADD_SUB)
    begin
        if ADD_SUB = '0' then
            SUM <= A + B;  -- Dodawanie
        else
            SUM <= A - B;  -- Odejmowanie
        end if;
    end process;
end Behavioral;