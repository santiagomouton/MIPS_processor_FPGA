import tkinter as tk
from tkinter import Listbox
import serial
import struct

# Configura el puerto serie
puerto_serial = serial.Serial('COM7', baudrate=9600, timeout=1)

# Crea la ventana principal
ventana = tk.Tk()
ventana.title("Visualizador de Registros y Memoria de Datos MIPS")

# Inicializa los registros de la CPU, la memoria de datos y el Program Counter (PC)
registros_cpu = [0x00] * 32
memoria_datos = [0x00] * 32
program_counter = 0x00

# Función para procesar los datos y actualizar la interfaz gráfica
def procesar_datos():
    try:
        # Lee 72 bytes desde el puerto serie (32 para registros CPU, 32 para memoria de datos, 8 para PC)
        datos_binarios = puerto_serial.read(288)  # Asegúrate de leer suficientes bytes
        
        # Verifica si hay suficientes bytes antes de intentar desempaquetar
        if len(datos_binarios) == 288:
            # Convierte los datos a listas de enteros de 32 bits para registros CPU y memoria de datos
            nuevos_registros_cpu = struct.unpack('!32I', datos_binarios[:128])
            nueva_memoria_datos = struct.unpack('!32I', datos_binarios[128:256])
            nuevo_program_counter = struct.unpack('!Q', datos_binarios[256:])[0]
            
            # Actualiza las listas de registros, memoria de datos y el Program Counter (PC)
            registros_cpu.extend(nuevos_registros_cpu)
            registros_cpu = registros_cpu[-32:]  # Limita la lista a los últimos 32 registros
            
            memoria_datos.extend(nueva_memoria_datos)
            memoria_datos = memoria_datos[-32:]  # Limita la lista a los últimos 32 registros
            
            program_counter = nuevo_program_counter
            
            # Borra el contenido actual de las listas y la etiqueta
            lista_registros_cpu.delete(0, tk.END)
            lista_memoria_datos.delete(0, tk.END)
            
            # Muestra las listas de registros CPU y memoria de datos en la interfaz gráfica
            for i, (registro_cpu, registro_memoria) in enumerate(zip(registros_cpu, memoria_datos)):
                lista_registros_cpu.insert(tk.END, f"Registro CPU {i}: 0x{registro_cpu:08X}")
                lista_memoria_datos.insert(tk.END, f"Memoria de Datos {i}: 0x{registro_memoria:08X}")
            
            # Muestra el Program Counter (PC)
            label_pc.config(text=f"Program Counter (PC): 0x{program_counter:016X}")
        
        # Programa la próxima actualización después de un breve intervalo
        ventana.after(100, procesar_datos)
        
    except KeyboardInterrupt:
        ventana.destroy()

# Crea listas y una etiqueta en la interfaz gráfica para mostrar registros CPU, memoria de datos y PC
lista_registros_cpu = Listbox(ventana, width=40, height=10)
lista_registros_cpu.pack(padx=10, pady=5)

lista_memoria_datos = Listbox(ventana, width=40, height=10)
lista_memoria_datos.pack(padx=10, pady=5)

label_pc = tk.Label(ventana, text="Program Counter (PC): 0x00")
label_pc.pack(pady=5)

# Muestra las listas y la etiqueta inicializadas en 0x00
for i in range(32):
    lista_registros_cpu.insert(tk.END, f"Registro CPU {i}: 0x00")
    lista_memoria_datos.insert(tk.END, f"Memoria de Datos {i}: 0x00")

# Inicia la función de procesamiento en un hilo separado
procesar_datos()

# Función para cerrar el puerto serie al cerrar la ventana
def cerrar_ventana():
    puerto_serial.close()
    ventana.destroy()

ventana.protocol("WM_DELETE_WINDOW", cerrar_ventana)
ventana.mainloop()