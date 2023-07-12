`timescale 1ns/1ps

module UART_RX_tb ();

//ports and parameter declaration
localparam sys_clk_period = 10 ;
localparam baudrate_period = 16 * sys_clk_period ;

reg sys_clk, data_in, reset_n;
wire  data_ready;
wire [7:0] data_out;

//UUT instance
    UART_RX UUT (.Rx(data_in), .reset_n(reset_n), .sys_clk(sys_clk), .data_out(data_out), data_ready(data_ready));
 
//stopwatch to finish if needed


//clk and stimulit generation
    //clk generation
        always  begin
            sys_clk = 1'b0;
            #(sys_clk_period / 2);
            sys_clk = 1'b1;
            #(sys_clk_period / 2);
        end

    //stimuli generation
        initial begin
            reset_n = 1'b0;
            data_in =1'b1;
            repeat (2) @(negedge sys_clk);
        
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b0; //begin the transmition
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b1;//stop bit
            #baudrate_period data_in =1'b1;//must return to idle 
            #baudrate_period data_in =1'b1;//still idle
            
            #baudrate_period data_in =1'b1;//still idle
            #baudrate_period data_in =1'b0; //begin the transmition
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b1;//data expected <10001011>
            #baudrate_period data_in =1'b1;//stop bit
            #baudrate_period data_in =1'b1;//must return to idle 
            #baudrate_period data_in =1'b1;//still idle
            
            #(baudrate_period * 10) $stop; 
        end

//monitoring the output

initial begin
    $monitor("time : %d\t, data_in = %b\t data_out = %b\t data_ready_flag = %b",$time, data_in, data_out, data_ready);
end
    
endmodule