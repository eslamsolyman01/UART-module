`timescale 1ns/1ps

//counter module with Tb

module modulus_counter_parametrized #(parameter counter_final_value = 16, parameter counter_bits = 5) 
(
    input clk, reset_n, enable, 
    output [counter_bits - 1: 0] counter_out
);

    reg [counter_bits : 0] q_reg, q_next;

    //seq part
        always @(posedge clk, negedge reset_n) begin
            if (~reset_n)
                q_reg <= 'd0;
            else
                q_reg <= q_next;
        end
    
    //next state logic

        always @(*) begin
            if (enable) begin
                    
                if (q_reg < counter_final_value)
                    q_next = q_reg + 1;
                else
                    q_next = 'd1;
                
            end

            else
                    q_next = q_reg; 
        end

    //output logic
        assign counter_out = q_reg;

endmodule

module modulus_counter_parametrized_tb ();
    
    
    //parameter and port declaration
        localparam period = 10;
        localparam counter_final_value = 16 ;
        localparam counter_bits = 5 ;

        reg clk, enable, reset_n; 
        wire [counter_bits-1 : 0] counter_out;

    //UUT inistantiation
    modulus_counter_parametrized #(.counter_final_value(counter_final_value), .counter_bits(counter_bits)) UUT
                                  (.clk(clk), .reset_n(reset_n), .enable(enable), .counter_out(counter_out));

    //generate clk & stimuli
        //clk generation
        always  begin
            clk = 1'b1;
            #(period / 2);
            clk = 1'b0;
            #(period / 2);
        end
        
        //stimuli generation
        initial begin
            enable = 1'b1;
            reset_n = 1'b0;
            @(negedge clk);
            reset_n = 1'b1;

            #(30 * period);
            enable = 1'b0;
            #(10 * period);
            
            enable = 1'b1;
            repeat(10) @(posedge clk);

            $stop;
        end

    //monitoring the output
        initial begin
            $monitor("time : %d\t, enable = %b\t, counter_out = %d", $time, enable, counter_out);
        end

endmodule

