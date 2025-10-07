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

# Función para proc
# esar los datos recibidos y actualizar la interfaz gráfica
def procesar_datos_recibidos():
    datos_binarios = [0x00] * (32*4)
    try:
        global step
        if step == 1:
            step = 0

            # Lee 72 bytes desde el puerto serie (32 para registros CPU, 128 para memoria de datos, 8 para PC)
            # datos_binarios = puerto_serial.read(648)  # Asegúrate de leer suficientes bytes
            datos_binarios = puerto_serial.read(32*32)  # Asegúrate de leer suficientes bytes
            
            # Verifica si hay suficientes bytes antes de intentar desempaquetar
            # if len(datos_binarios) == 288:
            #     # Convierte los datos a listas de enteros de 32 bits para registros CPU y memoria de datos
            #     nuevos_registros_cpu = struct.unpack('!32I', datos_binarios[:128])
            #     nueva_memoria_datos = struct.unpack('!32I', datos_binarios[128:256])
            #     nuevo_program_counter = struct.unpack('!Q', datos_binarios[256:])[0]
                
            #     # Actualiza las listas de registros, memoria de datos y el Program Counter (PC)
            #     registros_cpu = list(nuevos_registros_cpu)
            #     memoria_datos = list(nueva_memoria_datos)
            #     program_counter = nuevo_program_counter
                
            #     # Borra el contenido actual de las listas
            #     lista_registros_cpu.delete(0, tk.END)
            #     lista_memoria_datos.delete(0, tk.END)
                
            #     # Muestra las listas de registros CPU y memoria de datos en la interfaz gráfica
            #     for i, (registro_cpu, registro_memoria) in enumerate(zip(registros_cpu, memoria_datos)):
            #         lista_registros_cpu.insert(tk.END, f"Registro CPU {i}: 0x{registro_cpu:08X}")
            #         lista_memoria_datos.insert(tk.END, f"Memoria de Datos {i}: 0x{registro_memoria:08X}")
                
            #     # Muestra el Program Counter (PC)
            #     label_pc.config(text=f"Program Counter (PC): 0x{program_counter:016X}")
            
            # Mostrar los datos recibidos en formato hexadecimal
            # datos_hexa.config(text="Datos Recibidos: " + ' '.join(format(byte, '02X') for byte in datos_binarios))
            print('-------------------------------REGISTROS----------------------------------------------------------------------')
            j = 0
            for i in range(4, len(datos_binarios), (4*4)):
                print( 
                    'R' + str(j) + ': ' + ''.join(format(datos_binarios[i+3], '02X'))
                                               .join(format(datos_binarios[i+2], '02X'))
                                               .join(format(datos_binarios[i+1], '02X'))
                                               .join(format(datos_binarios[i]  , '02X')) + ' '
                    'R' + str(j+1) + ': ' + ''.join(format(datos_binarios[i+7], '02X'))
                                               .join(format(datos_binarios[i+6], '02X'))
                                               .join(format(datos_binarios[i+5], '02X'))
                                               .join(format(datos_binarios[i+4]  , '02X')) + ' '
                    'R' + str(j+2) + ': ' + ''.join(format(datos_binarios[i+11], '02X'))
                                               .join(format(datos_binarios[i+10], '02X'))
                                               .join(format(datos_binarios[i+9], '02X'))
                                               .join(format(datos_binarios[i+8]  , '02X')) + ' '
                    'R' + str(j+3) + ': ' + ''.join(format(datos_binarios[i+15], '02X'))
                                               .join(format(datos_binarios[i+14], '02X'))
                                               .join(format(datos_binarios[i+13], '02X'))
                                               .join(format(datos_binarios[i+12]  , '02X'))
                                               )
                j = j+4
                if j == 32:
                    j = 0
                    break
            
            print('-------------------------------MEMORIA------------------------------------------------------------------------')
            for i in range((4*32), len(datos_binarios), (4)):
                print( 
                    'M' + str(j) + ': ' + ''.join(format(datos_binarios[i+3], '02X'))
                                               .join(format(datos_binarios[i+2], '02X'))
                                               .join(format(datos_binarios[i+1], '02X'))
                                               .join(format(datos_binarios[i]  , '02X')))
            # for i in range((4*32), len(datos_binarios), (4*8)):
            #     print( 
            #         'M' + str(j) + ': ' + ''.join(format(datos_binarios[i+3], '02X'))
            #                                    .join(format(datos_binarios[i+2], '02X'))
            #                                    .join(format(datos_binarios[i+1], '02X'))
            #                                    .join(format(datos_binarios[i]  , '02X')) + ' '
            #         'M' + str(j+1) + ': ' + ''.join(format(datos_binarios[i+7], '02X'))
            #                                    .join(format(datos_binarios[i+6], '02X'))
            #                                    .join(format(datos_binarios[i+5], '02X'))
            #                                    .join(format(datos_binarios[i+4]  , '02X')) + ' '
            #         'M' + str(j+2) + ': ' + ''.join(format(datos_binarios[i+11], '02X'))
            #                                    .join(format(datos_binarios[i+10], '02X'))
            #                                    .join(format(datos_binarios[i+9], '02X'))
            #                                    .join(format(datos_binarios[i+8]  , '02X')) + ' '
            #         'M' + str(j+3) + ': ' + ''.join(format(datos_binarios[i+15], '02X'))
            #                                    .join(format(datos_binarios[i+14], '02X'))
            #                                    .join(format(datos_binarios[i+13], '02X'))
            #                                    .join(format(datos_binarios[i+12]  , '02X')) + ' '
            #         'M' + str(j+4) + ': ' + ''.join(format(datos_binarios[i+19], '02X'))
            #                                    .join(format(datos_binarios[i+18], '02X'))
            #                                    .join(format(datos_binarios[i+17], '02X'))
            #                                    .join(format(datos_binarios[i+16]  , '02X')) + ' '
            #         'M' + str(j+5) + ': ' + ''.join(format(datos_binarios[i+23], '02X'))
            #                                    .join(format(datos_binarios[i+22], '02X'))
            #                                    .join(format(datos_binarios[i+21], '02X'))
            #                                    .join(format(datos_binarios[i+20]  , '02X')) + ' '
            #         'M' + str(j+6) + ': ' + ''.join(format(datos_binarios[i+27], '02X'))
            #                                    .join(format(datos_binarios[i+26], '02X'))
            #                                    .join(format(datos_binarios[i+25], '02X'))
            #                                    .join(format(datos_binarios[i+24]  , '02X')) + ' '
            #         'M' + str(j+7) + ': ' + ''.join(format(datos_binarios[i+31], '02X'))
            #                                    .join(format(datos_binarios[i+30], '02X'))
            #                                    .join(format(datos_binarios[i+29], '02X'))
            #                                    .join(format(datos_binarios[i+28]  , '02X'))
            #                                    )
            #     j = j+8
            
            print('--------------------------------------------------------------------------------------------------------------')
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
        
        if datos_a_enviar == '02' or datos_a_enviar == '04':
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
                        bytes_linea = bytes.fromhex(dato)
                        puerto_serial.write(bytes_linea)
                        print(i, dato, bytes_linea)
                        # print("Enviado:", dato)
                        time.sleep(0.1)
                        
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
