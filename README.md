#  Proyecto - Guía de Instalación

Este proyecto está dividido en dos partes:

- 🖥️ **Backend** (FastAPI)
- 🌐 **Frontend** (Web)

Sigue los pasos cuidadosamente para configurar todo correctamente.

---

#  Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- Python
- Node.js
- pnpm
- Docker (opcional pero recomendado)

## ⚠️ Redis es obligatorio

Este proyecto utiliza **Redis** para el servicio de envío de correos.

Debes instalar y ejecutar Redis antes de continuar.

Puedes hacerlo como prefieras:
- Instalación local
- Docker
- WSL (en Windows)

👉 Asegúrate de que Redis esté corriendo antes de iniciar el backend.

---

# ⚙️ Configuración del Backend (server)

## 1. Entrar a la carpeta

cd server

---

## 2. Crear entorno virtual

python -m venv venv

---

## 3. Activar entorno virtual

### 🪟 Windows
venv\Scripts\activate

### 🐧 Linux / 🍎 Mac
source venv/bin/activate

---

## 4. Instalar dependencias

pip install -r requirements.txt

---

## 5. Configurar variables de entorno

Existe un archivo de ejemplo:

.env.example

Debes crear un archivo `.env` basado en este.

### 🔐 API Keys

Para completar la configuración necesitas claves API.

👉 **Contáctame por privado para obtenerlas.**

---

## 6. Ejecutar el servidor

fastapi dev

---

# 🌐 Configuración del Frontend (web)

## 1. Entrar a la carpeta

cd web

---

## 2. Instalar dependencias

pnpm install

---

## 3. Configurar variables de entorno

Debes crear manualmente el archivo:

.env.local

Dentro debes colocar la URL del backend (API).

👉 **Contáctame por privado para obtener esta información.**

---

# ✅ Notas Finales

- Redis debe estar corriendo antes de iniciar el backend.
- El backend debe estar corriendo antes de usar el frontend.
- Las API keys son obligatorias para el funcionamiento correcto del sistema.

---

# 🧠 Recomendaciones

- Usa Docker para Redis si quieres evitar problemas de instalación.
- Verifica que el puerto del backend esté accesible desde el frontend.
- Si algo falla, revisa primero las variables de entorno.

---

# 📩 Soporte

Si tienes problemas en la instalación o configuración:

👉 Contáctame directamente.
