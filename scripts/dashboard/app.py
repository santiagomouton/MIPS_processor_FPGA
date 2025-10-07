from flask import Flask, render_template, jsonify, request
import serial
import threading
import serial
import random
import time


app = Flask(__name__)

# Configuración UART
puerto_serial = serial.Serial('COM4', baudrate=9600, timeout=1, bytesize=serial.EIGHTBITS, parity=serial.PARITY_NONE, 
                              stopbits=serial.STOPBITS_ONE, xonxoff=False, rtscts=False, dsrdtr=False)


data = {
    "registers": [["0000"] for _ in range(32)],  # Stack de registros (32 filas de 32 bits)
    "memory": [["0000"] for _ in range(32)],    # Stack de memoria (32 filas de 32 bits)
    "pc": ["0000"],  # Program Counter (32 bits)
    "decode_signals": [""],
    "execute_signals": [""],
    "memory_signals": [""],
    "writeback_signals": [""]
    # "decode_signals": {"shamt_signal": "0", "opcode": "0", "funct": "0", "pc_branch_or_jump": "0", 
    #                    "address_jump": "0", "address_branch": "0", "address_register": "0", "pc_src": "0",
    #                    "halt_signal": "0", "tipeI_signal": "0", "regDest_signal": "0", "mem_signals": "0",
    #                    "wb_signals": "0"},
    # "execute_signals": {"forward_signal_regA": "0", "forward_signal_regB": "0", "alu_result_o_mem": "0",
    #                     "data_write_to_reg": "0", "data_rb": "0", "writeReg_execute": "0", "alu_result_execute": "0"},
    # "memory_signals": {"data_read_interface": "0", "alu_result_o_mem": "0", "writeReg_o_mem": "0", 
    #                    "wb_signals_o_mem": "0", "halt_signal_o_mem": "0"},
    # "writeback_signals": {"data_write_to_reg": "0"}
}


def read_uart():
    """Lee datos UART y actualiza las estructuras."""
    global data
    # buffer_size = 260  # 128 + 128 + 4 = tamaño fijo por ciclo
    # buffer_size = 644  # (32*4) + (128*4) + 1 = tamaño fijo por ciclo
    buffer_size = 691  # (32*4) + (128*4) + 4(pc) + 47 = tamaño fijo por ciclo
    # buffer_size = 129
    offset_signals = 644

    while True:


        try:

            # if puerto_serial.in_waiting >= 128:
            bytes_disponibles = puerto_serial.in_waiting
            if bytes_disponibles > 1:
                time.sleep(0.4)
                print(f"Número de bytes disponibles para leer: {bytes_disponibles}")
            # print(puerto_serial.in_waiting)
            if puerto_serial.in_waiting == buffer_size:
                # datos_binarios = puerto_serial.read(128)
                datos_binarios = puerto_serial.read(buffer_size)
                
                           
                # Procesar memoria de registros
                for i in range(32):  # 32 filas
                    start = i * 4
                    datos_binarios_fila = datos_binarios[start:start + 4]
                    # Convertir los 4 bytes en un entero de 32 bits
                    # data["registers"][i] = [int(b) for b in datos_binarios_fila]
                    data["registers"][i] = datos_binarios_fila[::-1].hex()
                    print(datos_binarios_fila[::-1].hex())

                # Procesar memoria de datos
                for i in range(32):  # 32 filas
                    start = 128 + (i * 4)
                    datos_binarios_fila = datos_binarios[start:start + 4]
                    # print(datos_binarios[start:start + 1], datos_binarios[start:start + 2], 
                    #       datos_binarios[start:start + 3], datos_binarios[start:start + 4]
                    #       , datos_binarios_fila, datos_binarios_fila[::-1].hex())

                    # data["memory"][i] = [int(b) for b in datos_binarios_fila]
                    data["memory"][i] = datos_binarios_fila[::-1].hex()
                    print(datos_binarios_fila[::-1].hex())

                # Procesar el Program Counter
                pc_data = datos_binarios[640:644]
                data["pc"] = pc_data[::-1].hex()
                print(pc_data[::-1].hex())


                full_signals_data = datos_binarios[offset_signals:]
                full_signals_data = full_signals_data[::-1]
                bits = ''.join(f'{byte:08b}' for byte in full_signals_data)
                print(f"tamaño={len(full_signals_data)} \n full_signals_data: {bits}")

                # Procesar signals
                decode_data = bits[0:125] # 16 = 125 bits
                data["decode_signals"] = decode_data

                execute_data = bits[125:125+137] # 18 = 137 bits
                data["execute_signals"] = execute_data

                memory_data = bits[125+137:125+137+79] # 10 = 73 bits
                data["memory_signals"] = memory_data

                writeback_data = bits[125+137+79:]
                data["writeback_signals"] = writeback_data

        except Exception as e:
            print(f"Error leyendo UART: {e}")


# Inicia un hilo para leer datos UART
threading.Thread(target=read_uart, daemon=True).start()



# Función para cargar un archivo
def cargar_archivo():
    for linea in file:
        # Procesar cada línea como sea necesario
        linea = linea.strip()  # Eliminar caracteres de nueva línea u otros espacios en blanco
        
        # Enviar los bytes en pares de caracteres hexadecimales
        for i in range(len(linea), 0, -2):
            dato = linea[i-2:i]
            #bytes_linea = bytes.fromhex(dato)
            bytes_linea = int(dato).to_bytes(1, byteorder='big')
            puerto_serial.write(bytes_linea)
            print(i, dato, int.from_bytes(bytes_linea, byteorder='big'))
            # print("Enviado:", dato)
            time.sleep(0.5)
            
            datos_binarios = puerto_serial.read(1)
            if datos_binarios == b'':
                break
            print("datos recividos de la etapa write_instruction: ", int.from_bytes(datos_binarios, byteorder='big'))


@app.route("/")
def index():
    return render_template("index.html")

@app.route("/data", methods=['GET'])
def get_data():
    time.sleep(0.4)
    """API para enviar los datos actuales."""
    return jsonify(data)

# Ruta para subir el archivo .coe, .hex
@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return "No se envió ningún archivo", 400

    file = request.files['file']

    if file.filename == '':
        return "El archivo no tiene nombre", 400

    if not file.filename.endswith('.hex'):
        return "El archivo debe tener extensión .hex", 400

    # global content
    # Leer el contenido del archivo .hex
    # content = file.read().decode("ascii")
    # content = file.readline().decode("ascii")

    # print(content)

    for linea in file:
        linea = linea.strip()  # Eliminar caracteres de nueva línea u otros espacios en blanco
        #print("linea:", linea)
        
        # Enviar los bytes en pares de caracteres hexadecimales
        for i in range(len(linea), 0, -2):
            hexaData = linea[i-2:i]
            byteData = bytes.fromhex(hexaData.decode('utf-8'))
            puerto_serial.write(byteData)
            #print(i, int.from_bytes(byteData, byteorder='big', signed=False), "pasado_a_uart=", byteData, "En hexa=", hexaData)
            # print("Enviado:", dato)
            time.sleep(0.2)

    return f"Archivo cargado exitosamente."

# Ruta para enviar comandos a la debug unit
@app.route('/send_command', methods=['POST'])
def send_command():
    # Leer el comando enviado desde el frontend
    data = request.get_json()
    datos_a_enviar = data.get("command", "")

    try:
        # Convierte la entrada hexadecimal a una secuencia de bytes
        datos_binarios = bytes.fromhex(datos_a_enviar)
        
        # Envía los datos a través del puerto serie
        puerto_serial.write(datos_binarios)
        
    except Exception as e:
        print("Error al enviar datos:", e)

    print("datos_a_enviar=",datos_a_enviar, "datos_binarios=", datos_binarios)

    time.sleep(0.8)
    return jsonify({"response": datos_a_enviar})


if __name__ == "__main__":
    app.run(debug=False)
