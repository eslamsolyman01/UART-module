library verilog;
use verilog.vl_types.all;
entity UART_RX is
    port(
        RX              : in     vl_logic;
        reset_n         : in     vl_logic;
        sys_clk         : in     vl_logic;
        data_ready      : out    vl_logic;
        data_out        : out    vl_logic_vector(7 downto 0)
    );
end UART_RX;
