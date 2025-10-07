// Función para obtener los datos del backend
async function fetchData() {
    try {
        const response = await fetch('/data');
        const data = await response.json();

        // Actualizar las tablas con los datos obtenidos
        updateTables(data);
    } catch (error) {
        console.error("Error al obtener los datos:", error);
    }
}

// Función para actualizar las tablas dinámicamente
function updateTables(data) {
    // console.log(data)
    const registersTable = document.getElementById("registers").querySelector("tbody");
    const memoryTable = document.getElementById("memory").querySelector("tbody");
    const pcDisplay = document.getElementById("pc");
    const signals = document.getElementById("signals").querySelector("tbody");

    // Limpiar tablas existentes
    registersTable.innerHTML = "";
    memoryTable.innerHTML = "";
    signals.innerHTML = "";

    // Actualizar stack de registros
    data.registers.forEach((row, index) => {
        const tr = document.createElement("tr");
        const tdLabel = document.createElement("td");
        tdLabel.textContent = `R${index}`;
        const tdValue = document.createElement("td");
        tdValue.textContent = row; // Concatenar valores hexadecimales
        tr.appendChild(tdLabel);
        tr.appendChild(tdValue);
        registersTable.appendChild(tr);
    });

    // Actualizar stack de memoria
    data.memory.forEach((row, index) => {
        const tr = document.createElement("tr");
        const tdLabel = document.createElement("td");
        tdLabel.textContent = `M${index}`;
        const tdValue = document.createElement("td");
        tdValue.textContent = row
        tr.appendChild(tdLabel);
        tr.appendChild(tdValue);
        memoryTable.appendChild(tr);
    });

    // Actualizar el Program Counter
    pcDisplay.textContent = `PC: ${data.pc}`;

    // Actualizar los signals
    const tr_decode = document.createElement("tr");
    const tdLabel_decode = document.createElement("td");
    tdLabel_decode.textContent = "DECODE";
    const tdLabel_decode_value = document.createElement("td");
    tdLabel_decode_value.textContent = data.decode_signals;
    tdLabel_decode_value.style.textAlign = "left";
    tr_decode.appendChild(tdLabel_decode);
    tr_decode.appendChild(tdLabel_decode_value);
    signals.appendChild(tr_decode);

    const tr_execute = document.createElement("tr");
    const tdLabel_execute = document.createElement("td");
    tdLabel_execute.textContent = "EXECUTE";
    const tdLabel_execute_value = document.createElement("td");
    tdLabel_execute_value.textContent = data.execute_signals;
    tdLabel_execute_value.style.textAlign = "left";
    tr_execute.appendChild(tdLabel_execute);
    tr_execute.appendChild(tdLabel_execute_value);
    signals.appendChild(tr_execute);

    const tr_memory = document.createElement("tr");
    const tdLabel_memory = document.createElement("td");
    tdLabel_memory.textContent = "MEMORY";
    const tdLabel_memory_value = document.createElement("td");
    tdLabel_memory_value.textContent = data.memory_signals;
    tdLabel_memory_value.style.textAlign = "left";
    tr_memory.appendChild(tdLabel_memory);
    tr_memory.appendChild(tdLabel_memory_value);
    signals.appendChild(tr_memory);

    const tr_writeback = document.createElement("tr");
    const tdLabel_writeback = document.createElement("td");
    tdLabel_writeback.textContent = "WRITEBACK";
    const tdLabel_writeback_value = document.createElement("td");
    tdLabel_writeback_value.textContent = data.writeback_signals;
    tdLabel_writeback_value.style.textAlign = "left";
    tr_writeback.appendChild(tdLabel_writeback);
    tr_writeback.appendChild(tdLabel_writeback_value);
    signals.appendChild(tr_writeback);
}

// Configurar un intervalo para obtener datos periódicamente
// setInterval(fetchData, 8000); // Actualizar cada 1 segundo


async function uploadFile() {
    const fileInput = document.getElementById('file-input');
    const file = fileInput.files[0];

    if (!file) {
        alert("Por favor selecciona un archivo .hex");
        return;
    }

    const formData = new FormData();
    formData.append("file", file);

    try {
        const response = await fetch('/upload', {
            method: 'POST',
            body: formData,
        });

        if (response.ok) {
            const result = await response.text();
            document.getElementById('file-content').textContent = result;
        } else {
            alert("Error al cargar el archivo");
        }
    } catch (error) {
        console.error("Error al enviar el archivo:", error);
    }
}

async function sendCommand() {
    const commandInput = document.getElementById("command-input");
    const responseContainer = document.getElementById("server-response");

    const command = commandInput.value;

    // Validar que el comando no esté vacío
    if (!command) {
        alert("Por favor, escribe un comando.");
        return;
    }

    try {
        // Enviar el comando al backend
        const response = await fetch("/send_command", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({ command: command }),
        });

        if (response.ok) {
            const data = await response.json();
            // Mostrar la respuesta en el frontend
            responseContainer.textContent = data.response;
            
            fetchData()
        } else {
            responseContainer.textContent = "Error en el servidor.";
        }
    } catch (error) {
        console.error("Error al enviar el comando:", error);
        responseContainer.textContent = "Error de conexión.";
    }
}
