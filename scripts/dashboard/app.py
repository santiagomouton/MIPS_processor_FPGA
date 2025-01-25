from flask import Flask, render_template, jsonify, request
import serial
import threading
import serial
import random
import time


app = Flask(__name__)

# Configuración UART
puerto_serial = serial.Serial('COM4', baudrate=9600, timeout=1)

data = {
    "registers": [["0000"] for _ in range(32)],  # Stack de registros (32 filas de 32 bits)
    "memory": [["0000"] for _ in range(32)],    # Stack de memoria (32 filas de 32 bits)
    "pc": ["0000"]  # Program Counter (32 bits)
}


def read_uart():
    """Lee datos UART y actualiza las estructuras."""
    global data
    # buffer_size = 260  # 128 + 128 + 4 = tamaño fijo por ciclo
    buffer_size = 641  # (32*4) + (128*4) + 1 = tamaño fijo por ciclo
    # buffer_size = 129

    while True:
        # for i in range(32):
        #     data["registers"][i]= random.randbytes(4).hex()
        #     data["memory"][i]=random.randbytes(4).hex()
        # data["pc"]=random.randbytes(4).hex()

        # # print(data)

        # # Enviar el paquete completo
        # time.sleep(8)  # Pausa de 1 segundo entre paquetes

        try:
            # if puerto_serial.in_waiting >= buffer_size:
            #     # Leer un paquete completo
            #     raw_data = puerto_serial.read(buffer_size)

            #     # print(raw_data[0])
            #     print(raw_data)
                
            #     print("\n", raw_data.hex(), "\n\n")

            # if puerto_serial.in_waiting >= 128:
            time.sleep(0.5)
            # bytes_disponibles = puerto_serial.in_waiting

            # if bytes_disponibles > 1:
            #     print(f"Número de bytes disponibles para leer: {bytes_disponibles}")

            if puerto_serial.in_waiting >= buffer_size:
                # datos_binarios = puerto_serial.read(128)
                datos_binarios = puerto_serial.read(buffer_size)
                
                # if datos_binarios == b'':
                #     break
                # for i in range(32):  # 32 filas
                #     aux=i*4
                #     datos_binarios_fila = datos_binarios[aux:aux+4]
                #     print("reg:", i, datos_binarios_fila[::-1].hex(), flush=True)
                
                # for i in range(128):  # 32 filas
                #     aux=128+(i*4)
                #     datos_binarios_fila = datos_binarios[aux:aux+4]
                #     print("mem:", i, datos_binarios_fila[::-1].hex(), flush=True)

                # datos_binarios_fila = datos_binarios[buffer_size-1:]
                # # datos_binarios_fila = datos_binarios[buffer_size-4:]
                # print("pc:", datos_binarios_fila.hex(), flush=True)
                
                           
                # Procesar memoria de registros
                for i in range(32):  # 32 filas
                    start = i * 4
                    datos_binarios_fila = datos_binarios[start:start + 4]
                    # Convertir los 4 bytes en un entero de 32 bits
                    # data["registers"][i] = [int(b) for b in datos_binarios_fila]
                    data["registers"][i] = datos_binarios_fila[::-1].hex()

                # Procesar memoria de datos
                for i in range(32):  # 32 filas
                    start = 128 + (i * 4)
                    datos_binarios_fila = datos_binarios[start:start + 4]
                    # data["memory"][i] = [int(b) for b in datos_binarios_fila]
                    data["memory"][i] = datos_binarios_fila[::-1].hex()

                # Procesar el Program Counter
                pc_data = datos_binarios[-1:]
                data["pc"] = pc_data.hex()

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
            time.sleep(0.2)
            
            datos_binarios = puerto_serial.read(1)
            if datos_binarios == b'':
                break
            print("datos recividos de la etapa write_instruction: ", int.from_bytes(datos_binarios, byteorder='big'))


@app.route("/")
def index():
    return render_template("index.html")

@app.route("/data", methods=['GET'])
def get_data():
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
        print("linea:", linea)
        
        # Enviar los bytes en pares de caracteres hexadecimales
        for i in range(len(linea), 0, -2):
            hexaData = linea[i-2:i]
            byteData = bytes.fromhex(hexaData.decode('utf-8'))
            puerto_serial.write(byteData)
            print(i, int.from_bytes(byteData, byteorder='big', signed=False), "pasado_a_uart=", byteData, "En hexa=", hexaData)
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

    time.sleep(1.5)
    return jsonify({"response": datos_a_enviar})


if __name__ == "__main__":
    app.run(debug=False)
