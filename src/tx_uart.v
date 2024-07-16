`timescale 1ns / 1ps

module tx_uart
#(
    parameter   NB_STATE        = 4,    // estados de la FSM
    parameter   N_DATA          = 8,    // cantidad de datos a recibir
    parameter   START_VALUE     = 0,    // Bit de start
    parameter   STOP_VALUE      = 1,     // Bit de stop
    parameter   DATA_TICKS      = 15    // cantidad de bit para colcarse al centro del bit de dato // agrege
)
(
    input   wire  [N_DATA - 1:0]   din,
    input   wire                tx_start , s_tick,
    input   wire                clock,
    input   wire                reset,
    output  wire                tx,   
    output  reg                 tx_done_tick,
    output wire [NB_STATE -1:0]state          
);

    // contador de tick
    reg [3:0] count_ticks_reg,count_ticks_next;
    // registro conteo de los datos de envio 
    reg [2:0] count_data_reg, count_data_next;
    // registro de guardado de la operacion de la alu
    reg [N_DATA - 1:0] din_reg, din_next;
    // registro asociado a la salida
    reg tx_reg, tx_next;
    
    // estados de la fsm
    localparam [ NB_STATE -1:0]
        STATE_IDLE  = 4'b0001,
        STATE_START = 4'b0010,
        STATE_DATA  = 4'b0100,
        STATE_STOP  = 4'b1000;

    reg [NB_STATE - 1:0] current_state, next_state;
    assign state = current_state;
    /**
        Logica de cambio de estado
    **/
    always @(posedge clock) 
        begin
            if (reset) begin
                din_reg             <= 8'b0; 
                count_data_reg      <= 3'b0;
                count_ticks_reg     <= 4'b0;
                tx_reg              <= 1'b1;
                current_state       <= STATE_IDLE; 
            end
            else begin
                din_reg          <= din_next; 
                count_data_reg   <= count_data_next;
                count_ticks_reg  <= count_ticks_next;
                tx_reg           <= tx_next;
                current_state    <= next_state;
            end
        end
        
    always @(*) begin: state_logic
        next_state         = current_state;
        count_data_next    = count_data_reg;
        count_ticks_next   = count_ticks_reg;
        tx_done_tick       = 1'b0;
        tx_next            = tx_reg;
        din_next           = din_reg;

        case (current_state)
            STATE_IDLE : begin
                tx_next = 1'b1;             // bit de conexion activa
                tx_done_tick = 1'b1;
                if(tx_start)
                    begin
                        din_next            = din;
                        count_ticks_next    = 4'b0;
                        next_state          = STATE_START;
                    end
/*                 else
                    begin
                        tx_done_tick = 1'b1;
                    end */    
            end
            // -------------------------------------------------------------------------- //
            STATE_START : begin
                tx_next = 1'b0;             // bit de start
                if (s_tick) begin                    
                    if (count_ticks_reg == DATA_TICKS) begin
                        count_ticks_next    = 4'b0;
                        count_data_next     = 3'b0;
                        next_state          = STATE_DATA; 
                    end
                    else
                        count_ticks_next = count_ticks_reg + 1;
                end
            end
            // -------------------------------------------------------------------------- // 
            STATE_DATA : begin
                tx_next = din_reg[count_data_reg];
                if (s_tick) begin
                    if (count_ticks_reg == DATA_TICKS) begin
                        count_ticks_next     = 4'b0;
                        count_data_next      = count_data_reg + 1;
                        if(count_data_reg == N_DATA-1) begin        //modificado aca, el -1
                            count_data_next  = 3'b0;
                            next_state       = STATE_STOP;
                        end                    
                    end
                    else
                        count_ticks_next = count_ticks_reg + 1;
                end
            end
            // -------------------------------------------------------------------------- //
            STATE_STOP : begin
                tx_next = 1'b1;
                if (s_tick) begin
                    if (count_ticks_reg == DATA_TICKS) begin
                        next_state      = STATE_IDLE;                    
                        // tx_done_tick    = 1'b1; 
                    end
                    else
                        begin
                            count_ticks_next = count_ticks_reg + 1;
                            // tx_done_tick       = 1'b0;
                        end
                end
            end
        // -----------------------------------------------------------------------// 
/*             default: begin
                next_state = STATE_IDLE;
            end */
            default : next_state      = STATE_IDLE;
        endcase
    end

   assign tx = tx_reg;
   
endmodule