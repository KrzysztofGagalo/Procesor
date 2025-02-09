-- Wersja układu z magistralą BUS, MUX8 i MUX2
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY Processor_Core IS
    PORT (
			SW: IN STD_LOGIC_VECTOR(17 DOWNTO 0);   -- Switches
			KEY: IN STD_LOGIC_VECTOR(3 DOWNTO 0);    -- Keys
			LEDR: OUT STD_LOGIC_VECTOR(17 DOWNTO 0);   -- LEDs
		  
			
		  
		  	HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
						
		  
			R0Q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); 
			R1Q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); 
			R2Q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); 
			R3Q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); 
			R4Q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); 
			R5Q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); 
			R6Q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			GQ : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			AQ : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END Processor_Core;


ARCHITECTURE Behavioral OF Processor_Core IS

    COMPONENT regn IS
        PORT(
              R : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
              Rin, Clock : IN STD_LOGIC;
              Q : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0)
            );
    END COMPONENT;
    
    COMPONENT upcount IS
        PORT (
            Clear, Clock : IN STD_LOGIC;
            Q : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT dec3to8 IS
        PORT (
            W  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            En : IN STD_LOGIC;
            Y  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
    
    
    COMPONENT Mux8to1 IS
        PORT (
            IN_0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_4 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_5 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_6 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_7 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_8 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				IN_9 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            SEL  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);       
            MUX_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT Adder IS
        PORT (
            A : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            SUM : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            ADD_SUB : IN STD_LOGIC
        ); 
    END COMPONENT;
	 
	 
	 COMPONENT hex_to_7seg IS
        PORT(
              binary_in : in  STD_LOGIC_VECTOR (3 downto 0); 
				  seg_out   : out STD_LOGIC_VECTOR (6 downto 0)
            );
    END COMPONENT;
	 

   SIGNAL BUS_WIRES : STD_LOGIC_VECTOR(15 DOWNTO 0); -- BUS displayed as LEDR(15 DOWNTO 0)
   SIGNAL DIN : STD_LOGIC_VECTOR(15 DOWNTO 0);      -- DIN connected to SW(15 DOWNTO 0)
   SIGNAL CLK : STD_LOGIC;                          -- Clock connected to KEY(1)
   SIGNAL Resetn : STD_LOGIC;                       -- Resetn connected to KEY(0)
   SIGNAL Run : STD_LOGIC;
	SIGNAL Done : STD_LOGIC;
	
	SIGNAL Rin	: STD_LOGIC_VECTOR(7 DOWNTO 0); -- R0in, R1in, R2in, R3in, R4in, R5in, R6in, Ain
	SIGNAL Gin : STD_LOGIC;
	SIGNAL IRin : STD_LOGIC;
	
	SIGNAL Rout : STD_LOGIC_VECTOR(7 DOWNTO 0); --wejście adresowe/ mówi który adres w multiplekserze
	SIGNAL DINout : STD_LOGIC; 
	SIGNAL Gout : STD_LOGIC; 
			  
	SIGNAL ADD_SUB : STD_LOGIC;
	
	SIGNAL A_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL G_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL IR_OUTPUT : STD_LOGIC_VECTOR(8 DOWNTO 0);
	
	SIGNAL R0_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL R1_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL R2_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL R3_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL R4_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL R5_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL R6_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	SIGNAL SUM_SUB_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0); --wyjście z sumatora
	
	SIGNAL Xreg : STD_LOGIC_VECTOR(7 DOWNTO 0); --sygnal z dekodera po IR
	SIGNAL Yreg : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	SIGNAL MUX_SEL_REG : STD_LOGIC_VECTOR(9 DOWNTO 0); --
	SIGNAL Clear : STD_LOGIC; 
	SIGNAL Tstep_Q : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL I : STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	CONSTANT High : STD_LOGIC := '1';   -- Defining High as '1'
   CONSTANT Low  : STD_LOGIC := '0';   -- Optionally, you can define Low too

	
BEGIN
	DIN <= SW(15 DOWNTO 0);        -- Switches 15:0 are the DIN input
	CLK <= KEY(1);                 -- KEY(1) is the Clock signal  DODAĆ POTEM NOT 
	Resetn <= KEY(0);              -- KEY(0) is the Resetn signal
	Run <= SW(17);                 -- SW(17) is the Run signal
	LEDR(15 DOWNTO 0) <= BUS_WIRES;-- BUS_WIRES drives LEDs 15:0
	LEDR(17) <= Done;              -- Done signal drives LEDR(17)

	Clear <=  (((NOT Run OR Done) OR (NOT Resetn) )AND NOT(Tstep_Q(0) OR Tstep_Q(1))) OR Done; --OR (NOT Resetn); clearowanie licznika
	
	Tstep: upcount PORT MAP (Clear, CLK, Tstep_Q); --wyjście licznika
	
	I <= IR_OUTPUT(2 DOWNTO 0); --intrukcja
	decX: dec3to8 PORT MAP (IR_OUTPUT(5 DOWNTO 3), High, Xreg); --zamiana na 1zN
	decY: dec3to8 PORT MAP (IR_OUTPUT(8 DOWNTO 6), High, Yreg); 	
	
	
	
	controlsignals: PROCESS (Tstep_Q, I, Xreg, Yreg, Resetn)
	BEGIN
		Rout <= (OTHERS => '0');
		Rin <= (OTHERS => '0');
		DINout <= '0';
		Gout <= '0';
		GIN <= '0';
		Done <= '0';
		ADD_SUB <= '0';
		IRin <= '0';
		
	
	   IF Resetn = '0' THEN
        Rout <= (OTHERS => '0');
        Rin <= (OTHERS => '1');
        DINout <= '0';
        Done <= '0';
		  ADD_SUB <= '0';
		  
		ELSE
			CASE Tstep_Q IS
				 WHEN "00" => -- store DIN in IR as long as Tstep_Q = 0
						IRin <= '1';
				 WHEN "01" => -- step T1
					 CASE I IS
						WHEN "000" => -- instrukcja mv RX, RY  
							Rout <= Yreg; --Rxout <= Yreg
							Rin <= Xreg; 
							Done <= High; 
						WHEN "001" => -- instrukcja mvi RX,#D 
							DINout <= High; 
							Rin <= Xreg; 
							Done <= High; 
						WHEN "010" => -- instrukcja add RX, RY
							Rout <= Yreg; --R[y]
							Gin <= High; --zapis do G 
						WHEN "011" => -- instrukcja sub RX, RY
							ADD_SUB <= '1';
							Rout <= Yreg; --R[y]
							Gin <= High; --zapis do G  
						WHEN OTHERS =>
					 END CASE;
				 WHEN "10" => -- step T2
					 CASE I IS
						WHEN "000" => -- instrukcja mv RX, RY  
						WHEN "001" => -- instrukcja mvi RX,#D 
						WHEN "010" => -- instrukcja add RX, RY
							Gout <= high;  
							Rin <= Xreg;
							Done <= High; 
						WHEN "011" => -- instrukcja sub RX, RY
							ADD_SUB <= '1';
							Gout <= high;  
							Rin <= Xreg;
							Done <= High; 
						WHEN OTHERS =>
					 END CASE;
				 WHEN "11" => -- step T3
			 END CASE;
		  END IF; 
	 END PROCESS; 
 
	A: regn PORT MAP(R => BUS_WIRES, Rin=>Rin(7), Clock =>CLK, Q=>A_OUTPUT);
	G: regn PORT MAP(R => SUM_SUB_OUTPUT, Rin=>Gin, Clock =>CLK, Q=>G_OUTPUT);
	
	R0: regn PORT MAP(R => BUS_WIRES, Rin=>Rin(0), Clock =>CLK, Q=>R0_OUTPUT);
	R1: regn PORT MAP(R => BUS_WIRES, Rin=>Rin(1), Clock =>CLK, Q=>R1_OUTPUT);
	R2: regn PORT MAP(R => BUS_WIRES, Rin=>Rin(2), Clock =>CLK, Q=>R2_OUTPUT);
	R3: regn PORT MAP(R => BUS_WIRES, Rin=>Rin(3), Clock =>CLK, Q=>R3_OUTPUT);
	R4: regn PORT MAP(R => BUS_WIRES, Rin=>Rin(4), Clock =>CLK, Q=>R4_OUTPUT);
	R5: regn PORT MAP(R => BUS_WIRES, Rin=>Rin(5), Clock =>CLK, Q=>R5_OUTPUT);
	R6: regn PORT MAP(R => BUS_WIRES, Rin=>Rin(6), Clock =>CLK, Q=>R6_OUTPUT);
	
	HEX_DECODER0: hex_to_7seg PORT MAP(binary_in => R2_OUTPUT(3 DOWNTO 0), seg_out => HEX0);
	HEX_DECODER1: hex_to_7seg PORT MAP(binary_in => R2_OUTPUT(7 DOWNTO 4), seg_out => HEX1);
	
	HEX_DECODER2: hex_to_7seg PORT MAP(binary_in => R1_OUTPUT(3 DOWNTO 0), seg_out => HEX2);
	HEX_DECODER3: hex_to_7seg PORT MAP(binary_in => R1_OUTPUT(7 DOWNTO 4), seg_out => HEX3);
	
	HEX_DECODER4: hex_to_7seg PORT MAP(binary_in => A_OUTPUT(3 DOWNTO 0), seg_out => HEX4);
	HEX_DECODER5: hex_to_7seg PORT MAP(binary_in => A_OUTPUT(7 DOWNTO 4), seg_out => HEX5);
	
	HEX_DECODER6: hex_to_7seg PORT MAP(binary_in => G_OUTPUT(3 DOWNTO 0), seg_out => HEX6);
	HEX_DECODER7: hex_to_7seg PORT MAP(binary_in => G_OUTPUT(7 DOWNTO 4), seg_out => HEX7);
	
	IR: regn PORT MAP(R => DIN, Rin=>IRin, Clock =>CLK AND RUN, Q(8 DOWNTO 0) => IR_OUTPUT);
	
	
	reg_mux : Mux8to1 PORT MAP (
        IN_0 => R0_OUTPUT, 
		  IN_1 => R1_OUTPUT, 
		  IN_2 => R2_OUTPUT,
		  IN_3 => R3_OUTPUT, 
		  IN_4 => R4_OUTPUT, 
		  IN_5 => R5_OUTPUT, 
		  IN_6 => R6_OUTPUT, 
		  IN_7 => A_OUTPUT, 
		  IN_8 => DIN, 
		  IN_9 => G_OUTPUT,
		  SEL => MUX_SEL_REG, --Rout & DINout & Gout, 
		  MUX_OUT => BUS_WIRES
    ); 
	 
	 MUX_SEL_REG <= Gout & DINout & Rout; --sygnaly wyjsc controlUnit jako jeden
	 
	 
	 R0Q <= R0_OUTPUT; 
	 R1Q <= R1_OUTPUT;
	 R2Q <= R2_OUTPUT;
	 R3Q <= R3_OUTPUT;
	 R4Q <= R4_OUTPUT;
	 R5Q <= R5_OUTPUT;
	 R6Q <= R6_OUTPUT;
	 AQ <= A_OUTPUT;
	 GQ <= G_OUTPUT;
	 
	sumator: Adder PORT MAP(A => A_OUTPUT, B=>BUS_WIRES, SUM=>SUM_SUB_OUTPUT, ADD_SUB=>ADD_SUB);		
    
END Behavioral;
