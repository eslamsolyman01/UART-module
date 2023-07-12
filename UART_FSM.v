
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


module UART_RX 
(
    input RX, reset_n, sys_clk,
    output reg data_ready, data_corrupted,
    /*this is a sort of flag which indicates that the receiving process is done and data is ready, may put it at the stop bit state*/
    output [7:0] data_out 
);

    //reg to store the sampled_bit
        reg sampled_bit;

    //ticker (mod 16 counter), bit_counter 
        wire [3:0] bit_counter_out, ticker_out;
    //ticker and bit_counter related signals
        reg ticker_en, ticker_reset_n;
        reg bit_counter_en, bit_counter_reset_n;
        
        localparam bit_counter_final_value = 10;
        localparam ticker_final_value = 16;
    
    //ticker and bit_counter inistantiations
        modulus_counter_parametrized #(.counter_final_value(ticker_final_value)) ticker 
            (.clk(sys_clk), .reset_n(ticker_reset_n), .enable(ticker_en), .counter_out(ticker_out));

        modulus_counter_parametrized #(.counter_final_value(bit_counter_final_value)) bit_counter
            (.clk(sys_clk), .reset_n(bit_counter_reset_n), .enable(bit_counter_en), .counter_out(bit_counter_out));
    
    //shift_reg signals
      reg shift_reg_en, shift_reg_reset_n; 
    //shift_reg instance
        right_shift_reg  shift_reg_inst
            (.clk(sys_clk), .enable(shift_reg_en), .reset_n(shift_reg_reset_n), .shift_reg_input(sampled_bit), .shift_reg_out(data_out));


        //storage element connected to the shift reg module
        //  reg [7:0] shift_reg;
        //no need for it

    //state definition
        localparam idle = 2'b00 ;
        localparam check_start = 2'b01 ;
        localparam recive_data = 2'b10 ;
        localparam finish_receive = 2'b11 ;

        reg [1:0] state_current, state_next;

    //seq state shifting part
        always @(posedge sys_clk, negedge reset_n ) begin
            if (~reset_n)
                state_current <= idle;
            else
                state_current <= state_next;
        end
    


    //next state logic
        always @(*) begin
            /*reset signals reset value is set to the global reset by default
               the counter enable default value is zero*/
            ticker_reset_n = reset_n ;
            bit_counter_reset_n = reset_n;
            shift_reg_reset_n = reset_n; 

            shift_reg_en = 1'b0;
            bit_counter_en = 1'b0;
            ticker_en = 1'b0;

            //default value of the flag is zero 
            data_ready = 1'b0;
            data_corrupted =1'b0;

            case (state_current)
                
                idle:begin
                    //all reset signals are raised to start a clean process
                        ticker_reset_n = 1'b0 ;
                        bit_counter_reset_n = 1'b0;
                        shift_reg_reset_n = 1'b0; 
                    //check for RX value
                        if(RX)
                            state_next = idle;
                        else
                            state_next = check_start;

                end 

                check_start:begin
                    //enable the tick counter
                        ticker_en = 1'b1;

                        if (ticker_out == 8)begin
                            sampled_bit = RX;

                        //condition on the sampled bit
                        if(sampled_bit)begin
                            state_next = idle; //meaning it was a glitch
                           
                        end
                        else begin
                            ticker_reset_n = 1'b0; //to make sure it starts a new count to sample the bits in the next state
                            state_next = recive_data;
                        end
                    end
                end

                recive_data:begin
                    //make sure that the ticker is enabled in this state
                        ticker_reset_n = 1'b1;
                        ticker_en = 1'b1;
                    
                    //state's logic
                        if (ticker_out == 15) begin
                            sampled_bit = RX;
                            bit_counter_en = 1'b1;
                           
                            if(bit_counter_out < 8)
                                shift_reg_en = 1'b1;
                            else
                                shift_reg_en = 1'b0; // to make sure that it doesn't store the stop bit
                        end
                            //and this remains the same till the bit counter is equal to 9
                            //which means we've recived the data and expecting the stop bit  
                            if (bit_counter_out == 9) begin
                                
                                //I'm confused about if we need this statment to sample the stop bit or not
                                //eventually we will see and modify if needed
                                // if (ticker_out == 16) begin
                                    // sampled_bit = RX;
                                   
                                    if (sampled_bit) //which means it's the stop bit
                                        state_next = finish_receive;
                                    
                                    else  begin  //means that the data was corrupted 
                                     data_corrupted =1'b1;
                                        state_next = idle;
                                    end
                            end

                end

                finish_receive:begin
                    // the perpouse of this state is just to raise the data_ready flag and check for the next bit
                    //raise the ticker_en to sample the bit following to the stop bit
                        ticker_en = 1'b1;
                        data_ready = 1'b1;
                    //state logic
                        if(ticker_out == 15)
                        begin
                            sampled_bit = RX;
                        
                        // check the value of the sampled bit
                            if(RX) //meaning it's idle 
                                state_next = idle;
                            else
                                state_next = check_start;
                        end
                end

                default: state_next = idle;
            endcase

            
        end





endmodule
