----------------------------------------------------------------------------------
-- Company:        IIHE - ULB
-- Engineer:       Thomas Lenzi (thomas.lenzi@cern.ch)
-- 
-- Create Date:    08:44:34 08/18/2015 
-- Design Name:    OptoHybrid v2
-- Module Name:    sys - Behavioral 
-- Project Name:   OptoHybrid v2
-- Target Devices: xc6vlx130t-1ff1156
-- Tool versions:  ISE  P.20131013
-- Description:
--
-- 0 : VFAT2 mask for tracking data - 24 bits
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types_pkg.all;

entity sys is
port(

    ref_clk_i       : in std_logic;
    reset_i         : in std_logic;
    
    -- Wishbone slave
    wb_slv_req_i    : in wb_req_t;
    wb_slv_res_o    : out wb_res_t;
    
    --
    vfat2_tk_mask_o : out std_logic_vector(23 downto 0)
    
);
end sys;

architecture Behavioral of sys is
    
    -- Signals from the Wishbone Hub
    signal wb_stb       : std_logic_vector(31 downto 0);
    signal wb_we        : std_logic;
    signal wb_addr      : std_logic_vector(31 downto 0);
    signal wb_data      : std_logic_vector(31 downto 0);
    
    -- Signals for the registers
    signal reg_ack      : std_logic_vector(31 downto 0);
    signal reg_err      : std_logic_vector(31 downto 0);
    signal reg_data     : std32_array_t(31 downto 0);

begin

    --===============================--
    --== Wishbone request splitter ==--
    --===============================--

    wb_splitter_inst : entity work.wb_splitter
    generic map(
        SIZE        => 32,
        OFFSET      => 0
    )
    port map(
        ref_clk_i   => ref_clk_i,
        reset_i     => reset_i,
        wb_req_i    => wb_slv_req_i,
        wb_res_o    => wb_slv_res_o,
        stb_o       => wb_stb,
        we_o        => wb_we,
        addr_o      => wb_addr,
        data_o      => wb_data,
        ack_i       => reg_ack,
        err_i       => reg_err,
        data_i      => reg_data
    );
    
    --===============--
    --== Registers ==--
    --===============--

    registers_inst : entity work.registers
    generic map(
        SIZE        => 32
    )
    port map(
        ref_clk_i   => ref_clk_i,
        reset_i     => reset_i,
        stb_i       => wb_stb(31 downto 0),
        we_i        => wb_we,
        data_i      => wb_data,
        ack_o       => reg_ack(31 downto 0),
        err_o       => reg_err(31 downto 0),
        data_o      => reg_data(31 downto 0)
    );
    
    --=============--
    --== Mapping ==--
    --=============--
    
    vfat2_tk_mask_o <= reg_data(0)(23 downto 0);

end Behavioral;
