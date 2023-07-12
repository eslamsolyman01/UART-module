
//UART-Rx module
    /*well, the design of this module i didn't want it to be complecated so i devided it into some modules
      and actually the main motive was to separete the seq part from the comb. part for simpler design
      So, let's dive into the details 
      there are two counters within this module each of them is a <mod counter> which have a predetermined final value to reach
      
      on of these two counters is the <tickker counter>
      which will count till 16 then the sampling takes place 
      
      and the other one is the <bit_counter> 
      which counts the sampling events which took place then if the number of samples is 8 we shift to the stop_bit state or the idle state 
      I haven't decided yet ..
      
      and there is another module which is shift register with enable to store the values of the sampled data  */


module UART_RX #(parameters) 
(
    input RX, reset_n, sys_clk,
    output data_ready, 
    /*this is a sort of flag which indicates that the receiving process is done and data is ready, may put it at the stop bit state*/
    output [7:0] data_out 
);

    //reg to store the sampled_bit
    reg sampled_bit;

    //ticker (mod 16 counter), bit_counter 
        reg [:0] bit_counter_out, ticker_out;
    //ticker and bit_counter related signals
    reg ticker_enable, ticker_reset_n;
    reg bit_counter_en, bit_counter_reset_n;
    
    localparam bit_counter_final_value = 8;
    localparam ticker_final_value = 16;
    
    //ticker and bit_counter inistantiations
        modulus_counter_parametrized #(.counter_final_value(ticker_final_value)) ticker 
            (.clk(clk), .reset_n(ticker_reset_n), .enable(ticker_enable), .counter_out(ticker_out));

        modulus_counter_parametrized #(.counter_final_value(bit_counter_final_value)) bit_counter
            (.clk(clk), .reset_n(bit_counter_reset_n), .enable(bit_counter_en), .counter_out(bit_counter_out));
    
    //shift_reg signals
      wire shift_reg_en, shift_reg_reset_n; 
    //shift_reg instance
        right_shift_reg  shift_reg_inst
            (.clk(clk), .enable(shift_reg_en), .reset_n(shift_reg_reset_n), .shift_reg_input(sampled_bit), .shift_reg_out(data_out));


    //storage element connected to the shift reg module
        reg [7:0] shift_reg;

    //state definition
        localparam idle = 2'b00 ;
        localparam check_start = 2'b01 ;
        localparam recive_data = 2'b10 ;
        localparam stop_bit = 2'b11 ;

        reg [1:0] state_current, state_next;

    //seq state shifting part
    always @(posedge clk, negedge reset_n ) begin
        if (~reset_n)
            state_current <= idle;
        else
            state_current <= state_next;
    end
    


    //next state logic
    always @(*) begin

        case (state_current)
            
            idle:begin
                
            end 

            check_start:begin
                
            end

            recive_data:begin
                
            end

            stop_bit:begin
                
            end

            default: state_next = idle;
        endcase

        
    end






endmodule
