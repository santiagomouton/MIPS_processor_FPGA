`timescale 1ns / 1ps

module rx_uart
#(
    parameter   NB_STATE        = 4,    // estados de la FSM
    parameter   N_DATA          = 8,    // cantidad de datos a recibir
    parameter   STARTS_TICKS    = 7,    // cantidad de bit para colcarse al centro del bit de start
    parameter   DATA_TICKS      = 15   // cantidad de bit para colcarse al centro del bit de dato
)
(
   /** 
   **  - Cables de salida -
   * dout:          Dato a ser enviado              8 bit
   * rx_done_tick:  bit de aviso para leer dout     1 bit
   *
   **  - Cables de entrada -
   * rx:        bit que llega al receptor           1 bit
   * s_tick:    bit que habilita la lectura de rx   1 bit
   * clock:     Para cambio de estado 
   **/
    input   wire        clock,
    input   wire        reset_i,
    input   wire        rx,s_tick,                   
    output  reg         rx_done_tick,
    output  wire [7:0]  dout
);
    // estados de la fsm
    localparam [ NB_STATE -1:0]
        STATE_IDLE  = 4'b0001,
        STATE_START = 4'b0010,
        STATE_DATA  = 4'b0100,
        STATE_STOP  = 4'b1000;
        
    /**
    No podemos inicializar los reg
    Es aceptable que comience con X o Z
    */
    /**
    El reset es el incializado donde todo comienza
    */
    reg  [7:0]     ptro, ptro_next;
    // contador de tick
    reg [3:0]           count_ticks_reg, count_ticks_next;
    // contador de datos leidos en rx
    reg [2:0]           count_data, count_data_next;
    // alamcenamitno del estado
    reg [NB_STATE - 1:0] current_state, next_state;
    
    /**
        Logica de cambio de estado
    **/
    always @(posedge clock) 
        begin
            if (reset_i) begin
                current_state       <= STATE_IDLE;
                count_ticks_reg     <= 4'b0;
                count_data          <= 3'b0;      
                ptro                <= 8'b0;  
            end
            else begin
                current_state       <= next_state;
                count_ticks_reg     <= count_ticks_next;
                count_data          <= count_data_next;
                ptro                <= ptro_next;
            end
           
        end
        
    always @(*) begin: state_logic
        rx_done_tick     = 1'b0;
        next_state       = current_state;
        count_ticks_next = count_ticks_reg;
        count_data_next  = count_data;
        ptro_next        = ptro;
         
        case (current_state)
            STATE_IDLE : begin
                if(!rx)                    
                    begin
                        count_ticks_next  = 4'b0;
                        next_state = STATE_START;
                    end
            end
            // -------------------------------------------------------------------------- //
            STATE_START : begin
                if (s_tick) begin
                    if (count_ticks_reg == STARTS_TICKS) begin
                        count_ticks_next    = 4'b0;
                        count_data_next     = 3'b0;
                        if (!rx)
                            next_state          = STATE_DATA;
                        else
                            next_state          = STATE_IDLE;   
                    end
                    else
                        count_ticks_next = count_ticks_reg + 1;
                end
            end
            // -------------------------------------------------------------------------- // 
            STATE_DATA : begin
                if (s_tick) begin
                    if (count_ticks_reg == DATA_TICKS) begin
                        count_ticks_next     = 4'b0;
                        //   0       0   0 0 0 0 0 0
                        // rx(i)     0   0 0 0 0 0 0 
                        // rx(i+1) rx(i) 0 0 0 0 0 0
//                            if(count_data == 4'b0000) begin
//                                ptro_next       = {rx, ptro[7:0]};
//                            end
//                            else 
                        ptro_next       = {rx, ptro[7:1]};
//                            dout [ptro]     = rx;
//                            ptro_next       = ptro + 1;
                        if(count_data == (N_DATA - 1))
                            next_state = STATE_STOP;
                        else
                            count_data_next = count_data + 1;   
                    end
                    else
                        count_ticks_next = count_ticks_reg + 1;
                end
            end
            // -------------------------------------------------------------------------- //
            STATE_STOP : begin
                if (s_tick) begin
                    if (count_ticks_reg == DATA_TICKS) begin
                        next_state        = STATE_IDLE;  
                        if(rx)
                            rx_done_tick  = 1'b1;
                    end
                    else
                        count_ticks_next = count_ticks_reg + 1;
                end
            end
        // -----------------------------------------------------------------------// 
            default : next_state = STATE_IDLE;
        endcase
    end

   assign dout = ptro;
    
endmodule
