import tkinter as tk
from tkinter import Listbox, Entry, Button, filedialog
import serial
import struct
import time

step = 0

# Configura el puerto serie
puerto_serial = serial.Serial('COM4', baudrate=9600, timeout=1)

# Crea la ventana principal
ventana = tk.Tk()
ventana.title("Visualizador y Enviador de Datos MIPS")

# Inicializa los registros de la CPU, la memoria de datos y el Program Counter (PC)
registros_cpu = [0x00] * 32
memoria_datos = [0x00] * 32
program_counter = 0x00

# Función para procesar los datos recibidos y actualizar la interfaz gráfica
def procesar_datos_recibidos():
    datos_binarios = [0x00] * (32*4)
    try:
        global step
        if step == 1:
            step = 0

            # Lee 72 bytes desde el puerto serie (32 para registros CPU, 128 para memoria de datos, 8 para PC)
            # datos_binarios = puerto_serial.read(648)  # Asegúrate de leer suficientes bytes
            j=0
            while True:
                datos_binarios = puerto_serial.read(1)
                # if len(datos_binarios) != 4:
                if datos_binarios == b'':
                    break
                print(datos_binarios)
                print("en hexa: ", datos_binarios.hex())
                # print(
                #     "", hex(int.from_bytes(datos_binarios, byteorder='big')), end=''
                #     # , hex(int.from_bytes(datos_binarios[2], byteorder='big'))
                #     # , hex(int.from_bytes(datos_binarios[1], byteorder='big'))
                #     # , hex(int.from_bytes(datos_binarios[0], byteorder='big'))
                # )
                # print(''.join(format(datos_binarios[3], '02X'))
                #                                .join(format(datos_binarios[2], '02X'))
                #                                .join(format(datos_binarios[1], '02X'))
                #                                .join(format(datos_binarios[0], '02X')))
                # # if j == 4:
                #     print(hex(int.from_bytes(datos_binarios, byteorder='big'))+' -- ', end='', flush=True)
                #     j=0
                # else:
                #     print(hex(int.from_bytes(datos_binarios, byteorder='big')), end=' ', flush=True)
                #     j=j+1

            # j = 0
            # print('-------------------------------REGISTROS----------------------------------------------------------------------')
            # while j != 32:
            #     datos_binarios = puerto_serial.read(4)  # Asegúrate de leer suficientes bytes
            #     # dword = int.from_bytes(datos_binarios, byteorder='little', signed=False)
            #     print('R' + str(j) + ': ' , datos_binarios, end='')
            #     # print('R' + str(j) + ': ' + ''.join(format(dword, '08X')), end='')

            #     datos_binarios = puerto_serial.read(4)  # Asegúrate de leer suficientes bytes
            #     # dword = int.from_bytes(datos_binarios, byteorder='little', signed=False)
            #     print(' R' + str(j+1) + ': ' , datos_binarios, end='')
            #     # print(' R' + str(j+1) + ': ' + ''.join(format(dword, '08X')), end='')

            #     datos_binarios = puerto_serial.read(4)  # Asegúrate de leer suficientes bytes
            #     # dword = int.from_bytes(datos_binarios, byteorder='little', signed=False)
            #     print(' R' + str(j+2) + ': ' , datos_binarios, end='')
            #     # print(' R' + str(j+2) + ': ' + ''.join(format(dword, '08X')), end='')

            #     datos_binarios = puerto_serial.read(4)  # Asegúrate de leer suficientes bytes
            #     # dword = int.from_bytes(datos_binarios, byteorder='little', signed=False)
            #     print(' R' + str(j+3) + ': ' , datos_binarios)
            #     # print(' R' + str(j+3) + ': ' + ''.join(format(dword, '08X')))
            #     j = j+4
            
            # j = 0

            # print('-------------------------------MEMORIA------------------------------------------------------------------------')
            # datos_binarios = puerto_serial.read(4)  # Asegúrate de leer suficientes bytes
            # # dword = int.from_bytes(datos_binarios, byteorder='little', signed=False)
            # print('M' + str(j) + ': ' , datos_binarios)
            # # print('M' + str(j) + ': ' + ''.join(format(dword, '08X')))


            # while j != 128:
            #     datos_binarios = puerto_serial.read(4)  # Asegúrate de leer suficientes bytes
            #     dword = int.from_bytes(datos_binarios, byteorder='big', signed=False)
            #     print('M' + str(j) + ': ' + ''.join(format(dword, '08X')), end='')

            #     datos_binarios = puerto_serial.read(4)  # Asegúrate de leer suficientes bytes
            #     dword = int.from_bytes(datos_binarios, byteorder='big', signed=False)
            #     print(' M' + str(j+1) + ': ' + ''.join(format(dword, '08X')), end='')

            #     datos_binarios = puerto_serial.read(4)  # Asegúrate de leer suficientes bytes
            #     dword = int.from_bytes(datos_binarios, byteorder='big', signed=False)
            #     print(' M' + str(j+2) + ': ' + ''.join(format(dword, '08X')), end='')

            #     datos_binarios = puerto_serial.read(4)  # Asegúrate de leer suficientes bytes
            #     dword = int.from_bytes(datos_binarios, byteorder='big', signed=False)
            #     print(' M' + str(j+3) + ': ' + ''.join(format(dword, '08X')))
            #     j = j+4
            
            print('\n--------------------------------------------------------------------------------------------------------------')
            # print(' '.join(format(byte, '02X') for byte in reversed(datos_binarios)))
            # print("\nByte Recibido:", datos_binarios)

        # Programa la próxima actualización después de un breve intervalo
        ventana.after(2000, procesar_datos_recibidos)
        
    except KeyboardInterrupt:
        ventana.destroy()

# Función para enviar datos a través del puerto serie
def enviar_datos():
    try:
        # Obtiene el valor ingresado en el Entry
        datos_a_enviar = entry_datos.get()
        
        if datos_a_enviar == '01' or datos_a_enviar == '02' or datos_a_enviar == '04':
            global step 
            step = 1

        # Convierte la entrada hexadecimal a una secuencia de bytes
        datos_binarios = bytes.fromhex(datos_a_enviar)
        
        # Envía los datos a través del puerto serie
        puerto_serial.write(datos_binarios)
        
    except Exception as e:
        print("Error al enviar datos:", e)


# Función para cargar un archivo
def cargar_archivo():
    filename = filedialog.askopenfilename()
    if filename:
        print("Archivo seleccionado:", filename)
        try:
            with open(filename, 'r') as file:
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
                        
        except Exception as e:
            print("Error al leer el archivo:", e)

# Etiquetas para mostrar los registros CPU, memoria de datos y PC
label_registros_cpu = tk.Label(ventana, text="Registros CPU:")
label_registros_cpu.pack(padx=10, pady=5)

lista_registros_cpu = Listbox(ventana, width=40, height=10)
lista_registros_cpu.pack(padx=10, pady=5)

label_memoria_datos = tk.Label(ventana, text="Memoria de Datos:")
label_memoria_datos.pack(padx=10, pady=5)

lista_memoria_datos = Listbox(ventana, width=40, height=10)
lista_memoria_datos.pack(padx=10, pady=5)

label_pc = tk.Label(ventana, text="Program Counter (PC): 0x00")
label_pc.pack(pady=5)

# Entrada para ingresar datos a enviar
entry_datos = Entry(ventana, width=40)
entry_datos.pack(padx=10, pady=5)

# Botón para enviar datos
btn_enviar = Button(ventana, text="Enviar Datos", command=enviar_datos)
btn_enviar.pack(pady=5)

btn_cargar_archivo = Button(ventana, text="Cargar Archivo", command=cargar_archivo)
btn_cargar_archivo.pack(pady=5)

# Muestra las listas y la etiqueta inicializadas en 0x00
for i in range(32):
    lista_registros_cpu.insert(tk.END, f"Registro CPU {i}: 0x00")
    lista_memoria_datos.insert(tk.END, f"Memoria de Datos {i}: 0x00")

# Inicia la función de procesamiento de datos recibidos en un hilo separado
procesar_datos_recibidos()

# Función para cerrar el puerto serie al cerrar la ventana
def cerrar_ventana():
    puerto_serial.close()
    ventana.destroy()

ventana.protocol("WM_DELETE_WINDOW", cerrar_ventana)
ventana.mainloop()
