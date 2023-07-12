`timescale 1ns/1ps

module UART_RX_tb ();

//ports and parameter declaration
localparam sys_clk_period = 10 ;
localparam baudrate_period = 16 * sys_clk_period ;

reg sys_clk, data_in, reset_n;
wire  data_ready, data_corrupted;
wire [7:0] data_out;

//UUT instance
    UART_RX UUT (.RX(data_in), .reset_n(reset_n), .sys_clk(sys_clk), .data_out(data_out), .data_ready(data_ready), .data_corrupted(data_corrupted));
 
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
            reset_n = 1'b1;
        
            #baudrate_period data_in =1'b1;
            //add a glitch bit
            data_in =1'b0;
            #(4 * sys_clk_period) data_in= 1'b1; //here a glitch zero was added then changed 
            //the purpose of this to make sure the functionality was meet correctly

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
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b0;//data expected <01001011>
            #baudrate_period data_in =1'b1;//stop bit
            #baudrate_period data_in =1'b1;//must return to idle 
            #baudrate_period data_in =1'b1;//still idle
            
             
            #baudrate_period data_in =1'b1;//still idle
            #baudrate_period data_in =1'b0; //begin the transmition
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b1;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b0;
            #baudrate_period data_in =1'b0;//data expected <01010101>
            //the previous seq. was choosen to show that we are sampling exactly 
            //at the mid of the bit
            #baudrate_period data_in =1'b1;//stop bit
            #baudrate_period data_in =1'b1;//must return to idle 
            #baudrate_period data_in =1'b1;//still idle

            #baudrate_period data_in =1'b0;//this will result a data corrupt flag to be raised

            #(baudrate_period * 10) ;
            $stop; 
        end

//monitoring the output

initial begin
    $monitor("time : %d\t, data_in = %b\t data_out = %b\t data_ready_flag = %b\t data_corrupted_flag = %b",$time, data_in, data_out, data_ready, data_corrupted);
end
    
endmodule