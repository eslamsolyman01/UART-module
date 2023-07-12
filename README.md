# UART-module
UART [Rx, Tx] modules based on verilog

## the following is a description of the design process of [UART-RX]


### modules

- modulus_counter
> which is a counter which counts till a predetermined value then counts over again,
 and there is an enable signal added to make the control proccess easier 

![image](https://github.com/eslamsolyman01/UART-module/assets/138836583/13955d14-94d8-486a-b807-760bb0ed4791)

- right_shift_reg
> which is a simple shift reg with enable 

![image](https://github.com/eslamsolyman01/UART-module/assets/138836583/e87e35b5-5037-42a6-8051-055745620e15)


- UART-RX-FSM
> this module contains the whole thing, which we will describe in detail
    the module ports is as follows 
![image](https://github.com/eslamsolyman01/UART-module/assets/138836583/ee9e4bea-c2be-4c9b-905d-f4ee31fa6312)



> and the functionality of UART-RX requires that we over sample the signal 
    which means that we need operate on a clock which is 16 times the "baud rate"
    the sampling process is as follows: 
    
![image](https://github.com/eslamsolyman01/UART-module/assets/138836583/88694196-ddda-43d4-a258-30f5007df63b)


> so in order to sample the data after 16 cycles we need a "ticker" to enable sampling at that time
    and this is ```the first instance we have``` 
    and since we determined the size of the data-bits to be 8
    so we need a ```bit_counter``` module to indicate the number of bits recived and based on that the logic carries on
    and the last instance we have is the ```shift register``` to store the data sent

> after describing the instances and the modules used, we talk about the FSM module: 
    the main targe of this module is to control the signals of the inistanitated modules.
    so, at first here is the state diagram: 

![image](https://github.com/eslamsolyman01/UART-module/assets/138836583/cf25dcd9-d190-4663-8c98-dfb2b0311d09)


- describtion of the states: 
> Describing the state's behavior and how the circuit works:
At first the FSM will be reseted to the idle state

> a comment about the control signals: 
    I belive there is an issue due to the signals of the reset and enable
    must have a default value in case It's not defined within the state 
    the default value of the reset signal of all must be the global reset
    and we can can change it within the states as we want
    the enable signals default value is zero. However, we will set it to one within the states


* idle :
    if (Rx == 1) we remain in this state
    we will be waiting for a zero to start reciveing the bits 
    in order to make sure that it's a real zero not a glitch we go to the "check_start" state

    All the reset_n signals must be activated  

* check_start :
    First of all when we enter this state we must enable the <tick_enable>  and when the counter hits value of (8) we sample the RX into the <sampled_bit> and check if it's a zero 
    ```
    if (sampled bit == 1'b0) >>  
    Begin 
    state_next = recive data ;
    Ticker_reset = 1'b0;
    end
    else >> //then the signal was a glitch and 
    state_next= idle;
    ```

* Recive_data :
    Since we reseted the ticker before we must lift this signal and make sure it's enabled all the time
    and must make sure that the bit counter is enabled 
    and whenever the ticker_out == 16 bits will be sampled and stored in the shift reg 
    and the shift_ reg enable will be enabled 
    and the bit_counter must be enabled

    ```
    if (ticker_out == 16)
    begin 
    sampled bit = RX;
    shift_reg_en= 1'b1;
    bit_counter_en = 1'b1;
    end
    ```

    the other case is when the bit counter reaches (8) meaning that we've received all of the data >>   so we are expecting that the RX bit will be one, if it's correct then we move to finish receive state, else >> means that there have been an error and the data is corrupted so we move to idle state 

    ``` if(bit_counter_out == 8)
    Begin
    //first disable the shift reg enable signal 
    shift_reg_en = 1'b0;

    if(sampled bit == 1)
    state_next = finish_receive;
    
    else //means the data is corrupted
    state_next  =idle;
    end ```


* finish receive : 
    in this state we just raise the data_ready flag and checks for the next bit if it's a one then the next state is idle, else the next state will be check_start
    //enable the ticker counter
    
    ```ticker_en = 1'b1;
    if (ticker_out == 16)
    sampled_bit = Rx;
    if (RX)
    state_next = idle;
    else
    state_next = check_start;
    ```

- the test bench results : 
> the test values were choosen carefully in order to make sure there is no issue regarding the functionality

![image](https://github.com/eslamsolyman01/UART-module/assets/138836583/66215816-b417-4ffb-9c0a-3967abd66e25)

    
