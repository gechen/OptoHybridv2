----------------------------------------------------------------------------------
-- Company:        IIHE - ULB
-- Engineer:       Thomas Lenzi (thomas.lenzi@cern.ch)
-- 
-- Create Date:    11:02:05 07/08/2015
-- Design Name:    OptoHybrid v2
-- Module Name:    wb_registers_test - Behavioral 
-- Project Name:   OptoHybrid v2
-- Target Devices: xc6vlx130t-1ff1156
-- Tool versions:  ISE  P.20131013
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
 
library work;
use work.types_pkg.all;
use work.wb_pkg.all;

entity wb_registers_test is
generic(
    BASE    : std_logic_vector(31 downto 0) := x"00000000";
    SIZE    : integer := 32;
    WB_MASK : std_logic_vector(31 downto 0) := x"FFFFFFFF";
    WE_MASK : std_logic_vector(31 downto 0) := x"00000000"
);
end wb_registers_test;
 
architecture behavior of wb_registers_test is 

    --Inputs
    signal wb_clk_i         : std_logic := '0';
    signal reset_i          : std_logic := '0';
    signal wb_req_i         : wb_req_t;
    signal stb_i            : std_logic_vector((SIZE - 1) downto 0);
    signal data_i           : register_array_t((SIZE - 1) downto 0);

    --Outputs
    signal wb_res_o         : wb_res_t;
    signal valid_o          : std_logic_vector((SIZE - 1) downto 0);
    signal data_o           : register_array_t((SIZE - 1) downto 0);

    constant wb_clk_period  : time := 10 ns;
    constant empty_sig      : wb_req_t := (addr  => (others => '0'), data  => (others => '0'), we    => '0', stb   => '0');

begin
 
    -- Instantiate the Unit Under Test (UUT)
    uut : entity work.wb_registers 
    generic map(
        BASE        => BASE,
        SIZE        => SIZE,
        WB_MASK     => WB_MASK,
        WE_MASK     => WE_MASK
    )
    port map(
        wb_clk_i    => wb_clk_i,
        reset_i     => reset_i,
        wb_req_i    => wb_req_i,
        wb_res_o    => wb_res_o,
        stb_i       => stb_i,
        data_i      => data_i,
        valid_o     => valid_o,
        data_o      => data_o
    );
    
    -- Clock process definitions
    process
    begin
        wb_clk_i <= '1';
        wait for wb_clk_period / 2;
        wb_clk_i <= '0';
        wait for wb_clk_period / 2;
    end process;
    
    -- Reset process
    process
    begin		
        reset_i <= '1';
        wait for 100 ns;
        reset_i <= '0';
        wait;
    wait;
    end process;
    
    -- Data process
    process
    begin
        wb_req_i <= empty_sig;
        stb_i <= (others => '0');
        data_i <= (others => (others => '0'));
        wait for 150 ns;
        wb_req_i <= (addr  => x"00000001",
                     data  => x"ABCDEF01",
                     we    => '1',
                     stb   => '1');      
        wait for wb_clk_period;
        wb_req_i.stb <= '0';     
        wait for wb_clk_period * 3;
        stb_i(1) <= '1';
        data_i(1) <= x"01234567";
        wb_req_i <= (addr  => x"00000002",
                     data  => x"02010203",
                     we    => '1',
                     stb   => '1');      
        wait for wb_clk_period;
        stb_i(1) <= '0';
        wb_req_i.stb <= '0';     
        wait for wb_clk_period * 3;
        wb_req_i <= (addr  => x"00000001",
                     data  => x"00000000",
                     we    => '0',
                     stb   => '1');      
        wait for wb_clk_period;
        wb_req_i.stb <= '0';  
        wait;
    end process;

end;
