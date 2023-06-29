`timescale 1ns / 1ps

module rx_uart
#(
    parameter   NB_STATE        = 5,    // estados de la FSM
    parameter   N_DATA          = 8,    // cantidad de datos a recibir
    parameter   START_VALUE     = 0,    // Bit de start
    parameter   STOP_VALUE      = 1,     // Bit de stop
    parameter   STARTS_TICKS    = 8,    // cantidad de bit para colcarse al centro del bit de start
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
    output  wire [7:0]  dout,          
    output  wire        rx_done_tick,  //cambie     
    
    output  wire        [NB_STATE - 1:0]rx_state,  //provicional   

    input   wire        rx,s_tick,                   
    input   wire        clock,
    input   wire        reset
);
    // estados de la fsm
    localparam [ NB_STATE -1:0]
        STATE_IDLE  = 5'b00001,
        STATE_START = 5'b00010,
        STATE_DATA  = 5'b00100,
        STATE_PAR   = 5'b01000,
        STATE_STOP  = 5'b10000;
    /**
    No podemos inicializar los reg
    Es aceptable que comience con X o Z
    */
    /**
    El reset es el incializado donde todo comienza
    */
    reg  [7:0]     ptro;
    reg  [7:0]     ptro_next;
    reg     rx_done_tick_reg ; //cambie
    reg     rx_done_tick_next ;//cambie
    // contador de tick
    reg [3:0]           count_ticks_reg     ;
    reg [3:0]           count_ticks_next     ;
    // contador de datos leidos en rx
    reg [3:0]           count_data      ;
    reg [3:0]           count_data_next ;
    // alamcenamitno del estado
    reg [NB_STATE - 1:0] current_state;
    reg [NB_STATE - 1:0] next_state;
    

    //provicional
    assign rx_state = current_state;

    /**
        Logica de cambio de estado
    **/
    always @(posedge clock) 
        begin
            if (reset) begin
                rx_done_tick_reg    <= 0;//cambie
                current_state       <= STATE_IDLE;
                count_ticks_reg     <= 0;
                count_data          <= 0;      
                ptro                <= 8'b0; 
//                dout                <= 0;    
            end
            else begin
                rx_done_tick_reg    <= rx_done_tick_next;//cambie
                current_state       <= next_state;
                count_ticks_reg     <= count_ticks_next;
                count_data          <= count_data_next;
                ptro                <= ptro_next;
            end
           
        end
        
    always @(*) begin: state_logic
         rx_done_tick_next= rx_done_tick_reg;//cambie
         next_state       = current_state;
         count_ticks_next = count_ticks_reg;
         count_data_next  = count_data;
         ptro_next        = ptro;
         
        case (current_state)
            STATE_IDLE : begin
                rx_done_tick_next = 1'b0; //cambie
                case(rx)
                    1'b0   :   next_state = STATE_START;
                    default:   next_state = STATE_IDLE;
                endcase
            end
            // -------------------------------------------------------------------------- // leer entradas, cambair estado, fijar salidas
            STATE_START : begin
                case(count_ticks_reg)
                    STARTS_TICKS:   
                    begin 
                        count_ticks_next    = 0;
                        count_data_next     = 0;
                        ptro_next           = 0;
                        next_state          = STATE_DATA;                                                    
                    end
                    default:  begin
                        next_state  = STATE_START;   
                        if (s_tick) begin
                            count_ticks_next = count_ticks_reg + 1;
                        end
                    end
                endcase
            end
            // -------------------------------------------------------------------------- // 
            STATE_DATA : begin
                case(count_ticks_reg)
                    DATA_TICKS:     
                        begin
                            count_ticks_next     = 0;
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
                            count_data_next  = count_data + 1;
                            if(count_data == N_DATA - 1) begin   //modificado aca, el -1
                                count_data_next = 0;
                                next_state      = STATE_PAR;
                            end
                            else begin
                                next_state  = STATE_DATA;
                            end                                                
                        end
                    default: begin
                        if (s_tick)begin
                            count_ticks_next = count_ticks_reg + 1;
                        end
                        next_state  = STATE_DATA;   
                    end 
                endcase
            end
            // -------------------------------------------------------------------------- //
            STATE_PAR: begin
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
                case(count_ticks_reg)
                    DATA_TICKS:     
                    begin
                        count_ticks_next     = 0;
                        if(rx) begin
                            rx_done_tick_next = 1'b1;
                            next_state        = STATE_IDLE;  
                        end
                        else  next_state = STATE_IDLE;             
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

   assign dout          = ptro;
   assign rx_done_tick  = rx_done_tick_reg;//cambie
    
endmodule
