`timescale 1ns/1ps

//shift reg module with tb
    /*there is an issue within this module
        as the shifting process is not synch with the clock <actually only the output is synch, but the shifting process it self is performed within a combinational circuit>
        meaning that if the input was changed twice before the posedge the output will be the shifting of the two of them
        so the input it self must be synch with the clk and it must not change twice within the clk period 
        otherwise the module will not meet the expected functionality   */

module right_shift_reg  #(parameter reg_size = 8)
(
    input clk, enable, reset_n,
    input shift_reg_input, 
    output [reg_size - 1 : 0] shift_reg_out
);

reg [reg_size-1 : 0] q_reg, q_next;

//seq part
always @(posedge clk, negedge reset_n ) begin
    if(~reset_n)begin
        q_reg <= 'd0;
        q_next <= 'd0;
    end
    else
        q_reg <= q_next;
end

//next state logic
always @(*) begin
    if(enable)
        q_next = {shift_reg_input, q_reg[reg_size-1 : 1]};
    else
        q_next = q_reg;
end

//output logic 
assign shift_reg_out = q_reg;

    
endmodule

module right_shift_reg_tb ();

//parameter and port declaration
    localparam period = 10;
    localparam reg_size = 5;

    reg clk, reset_n, enable, shift_reg_input;
    wire [reg_size-1 : 0] shift_reg_out;

//UUT instantiation
    right_shift_reg #(.reg_size(reg_size)) UUT 
                    (.clk(clk), .enable(enable), .shift_reg_input(shift_reg_input), .shift_reg_out(shift_reg_out));

//stopwatch >> if needded

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
        shift_reg_input = 1'b1;
        reset_n = 1'b0;
        repeat(2) @(negedge clk);
        reset_n = 1'b1;

        #period shift_reg_input = 1'b1;
        #period shift_reg_input = 1'b1;
        #period shift_reg_input = 1'b1;
        #period shift_reg_input = 1'b1;

        enable = 1'b0;


        #period shift_reg_input = 1'b1;
        #period shift_reg_input = 1'b0;
        #period shift_reg_input = 1'b1;
        #period shift_reg_input = 1'b0;

        enable = 1'b1;
        
        #period shift_reg_input = 1'b0;
        #period shift_reg_input = 1'b1;
        #period shift_reg_input = 1'b1;
        #period shift_reg_input = 1'b0;

        repeat(20) @(posedge clk);
        $stop;

    end




//output monitoring
    initial begin
        $monitor("time : %d\t, enable = %b\t input = %b\t reg_output = %b", 
                  $time, enable, shift_reg_input, shift_reg_out);    
    end

endmodule
