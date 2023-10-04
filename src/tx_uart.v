`timescale 1ns / 1ps

module tx_uart
#(
    parameter   NB_STATE        = 5,    // estados de la FSM
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
    output  wire                read_tx,      
    output  wire                tx_done_tick
                    
//    output  wire [N_DATA - 1:0] CHECK_ENTRADA_TX

);
    reg     tx_done_tick_reg ;               //cambie
    reg     tx_done_tick_next;              //cambie
    // contador de tick
    reg [3:0]           count_ticks_reg;
    reg [3:0]           count_ticks_next;    //cambie
    // registro conteo de los datos de envio 
    reg [3:0]           count_data_reg;
    reg [3:0]           count_data_next;    //cambie
    // registro de guardado de la operacion de la alu
    reg [N_DATA - 1:0]           din_reg;
    reg [N_DATA - 1:0]           din_next;
    // registro asociado a la salida
    reg                 tx_reg;
    reg                 tx_next;
    // registro asociado al cable de lectura
    reg                 read_tx_reg;
    reg                 read_tx_next;
    
    // estados de la fsm
    localparam [ NB_STATE -1:0]
        STATE_IDLE  = 5'b00001,
        STATE_START = 5'b00010,
        STATE_DATA  = 5'b00100,
        STATE_PAR   = 5'b01000,
        STATE_STOP  = 5'b10000;

    reg [NB_STATE - 1:0] current_state  ;
    reg [NB_STATE - 1:0] next_state     ;
    
    
//    assign CHECK_ENTRADA_TX  = din;
    
    /**
        Logica de cambio de estado
    **/
    always @(posedge clock) 
        begin
            if (reset) begin
                din_reg             <= 0; 
                count_data_reg      <= 0;
                count_ticks_reg     <= 0;
                // tx_done_tick_reg    <= 0;
                tx_reg              <= 1'b1;
                read_tx_reg         <= 0;
                current_state       <= STATE_IDLE; 
            end
            else begin
                din_reg          <= din_next; 
                count_data_reg   <= count_data_next;
                count_ticks_reg  <= count_ticks_next;
                // tx_done_tick_reg <= tx_done_tick_next;
                tx_reg           <= tx_next;
                read_tx_reg      <= read_tx_next;
                current_state    <= next_state;
            end
        end
        
    always @(*) begin: state_logic
         next_state         = current_state;
         count_data_next    = count_data_reg;
         count_ticks_next   = count_ticks_reg;
         tx_done_tick_next  = 0;

         tx_done_tick_reg  = 0;
         
         tx_next            = tx_reg;
         din_next           = din_reg;
         read_tx_next       = 0;
         case (current_state)
            STATE_IDLE : begin
                tx_next = 1'b1;             // bit de conexion activa
                case(tx_start)
                    1'b1   :
                    begin
                        din_next            = din;
                        count_ticks_next    = 0;
                        read_tx_next        = 1;
                        // tx_done_tick_next   = 0;
                        tx_done_tick_reg   = 0;
                        next_state          = STATE_START;
                    end
                    default:
                    begin
                        next_state = STATE_IDLE;
                        // tx_done_tick_next = 1'b1;
                        tx_done_tick_reg = 1'b1;
                    end    
                endcase
            end
            // -------------------------------------------------------------------------- //
            STATE_START : begin
                tx_next = 1'b0;             // bit de start
                case(count_ticks_reg)
                    DATA_TICKS:   
                    begin
                        count_ticks_next    = 0;
                        count_data_next     = 0;
                        next_state          = STATE_DATA;                                                    
                    end
                    default: begin
                        next_state  = STATE_START;   
                        if (s_tick) begin
                            count_ticks_next = count_ticks_reg + 1;
                        end
                    end
                endcase
            end
            // -------------------------------------------------------------------------- // 
            STATE_DATA : begin
                tx_next = din_reg[count_data_reg];
                case(count_ticks_reg)
                    DATA_TICKS:     
                        begin
                            count_ticks_next     = 0;
                            count_data_next      = count_data_reg + 1;
                            if(count_data_reg == N_DATA-1) begin        //modificado aca, el -1
                                count_data_next  = 0;
                                next_state  = STATE_PAR;
                            end
                            else next_state  = STATE_DATA;                                                
                        end
                    default: begin
                        next_state  = STATE_DATA;
                        if (s_tick) begin
                            count_ticks_next = count_ticks_reg + 1;
                        end
                    end
                endcase
            end
            // ---------------CALCULO OPCIONAL DEL BIT DE PARIDAD----------------------- //
            STATE_PAR: begin
                tx_next = 0; // valor 0 por ahora, luego hay que hacer el calculo de paridad
                case(count_ticks_reg)
                    DATA_TICKS:     
                    begin
                        count_ticks_next     = 0;
                        next_state  = STATE_STOP;                                                
                    end
                    default:   begin
                        next_state  = STATE_PAR;   
                        if (s_tick) begin
                            count_ticks_next = count_ticks_reg + 1;
                        end
                    end
                endcase
            end
            // -------------------------------------------------------------------------- //
            STATE_STOP : begin
                tx_next = 1'b1;
                case(count_ticks_reg)
                    DATA_TICKS:     
                    begin
                        count_ticks_next     = 0;  
                        // tx_done_tick_next    = 1'b1;    
                        tx_done_tick_reg    = 1'b1;    
                        next_state = STATE_IDLE;
                    end
                    default: begin
                        next_state  = STATE_STOP;   
                        if (s_tick) begin
                            count_ticks_next = count_ticks_reg + 1;
                        end
                    end
                endcase
            end
        // -----------------------------------------------------------------------// 
         default: begin
            next_state = STATE_IDLE;
         end
         endcase
    end

   assign tx            = tx_reg;
   assign read_tx       = read_tx_reg;
   assign tx_done_tick  = tx_done_tick_reg;//cambie
   
endmodule