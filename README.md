# Proyecto DUOC – App de Denuncias (Flutter + Flask)
# Proyecto Movil 
## Estructura del repositorio

```
denuncias-duoc/
├── server-flask/ → Backend Flask + SQLite + Ngrok
└── app-flutter/ → Aplicación Flutter conectada al backend
```

## Objetivo general

Desarrollar una solución cliente-servidor funcional que permita:
- Registrar denuncias con fotografía y ubicación.
- Almacenar la información en una base de datos SQLite (Flask).
- Consumir los datos desde Flutter mediante API REST.
- Aplicar conceptos de subida de imágenes, peticiones HTTP y UI responsiva (Material 3).

## Pasos de instalación y ejecución

### Backend Flask

#### Instalación

```bash
cd server-flask
python -m venv venv
venv\Scripts\activate  # En Windows
# o en Linux/Mac:
# source venv/bin/activate
```
<p align="center"> <img src="https://raw.githubusercontent.com/CarlosNeiraDuoc/capturas/refs/heads/main/1.PNG" width="600"> </p>

```bash
pip install -r requirements.txt
```
<p align="center"> <img src="https://raw.githubusercontent.com/CarlosNeiraDuoc/capturas/refs/heads/main/2.PNG" width="1000"> </p>

Ejecución del servidor Flask

⚠️ IMPORTANTE:

Puedes crear el entorno virtual (python -m venv venv) y hacer la instalación de dependencias desde Visual Studio Code o cualquier editor.
PERO cuando vayas a ejecutar el servidor (python app.py) y Ngrok, debes hacerlo en ventanas CMD separadas, fuera de VS Code, ya que ambos procesos deben correr al mismo tiempo.



1. Abrir una primera ventana CMD
Navega hasta la carpeta del servidor y ejecuta:

```bash
python app.py
```
El servidor Flask se iniciará en:
```bash
http://127.0.0.1:5000
```
No cierres esta ventana.
<p align="center"> <img src="https://raw.githubusercontent.com/CarlosNeiraDuoc/capturas/refs/heads/main/3.PNG" width="600"> </p>


### Exposición pública con Ngrok

Ngrok se utiliza para exponer el servidor Flask a internet y permitir que la aplicación Flutter se conecte desde cualquier lugar.

⚠️ Importante:
Para usar Ngrok debes crear una cuenta gratuita en https://ngrok.com/
Una vez creada, descarga e instala Ngrok, y copia tu authtoken (clave de autenticación personal) desde tu panel de usuario.
Luego ejecútalo una sola vez con:
```bash
ngrok config add-authtoken TU_AUTHTOKEN_AQUI
```
Esto guardará tu token en la configuración local y podrás usar Ngrok sin restricciones.

## Abrir una segunda ventana CMD

Navega hasta la carpeta del servidor y ejecuta:
```bash
ngrok http 5000
```
Ngrok generará una URL pública como:
```bash
https://abcd1234.ngrok-free.app
```
<p align="center"> <img src="https://raw.githubusercontent.com/CarlosNeiraDuoc/capturas/refs/heads/main/4.PNG" width="600"> </p>

Copia esa dirección y reemplázala en el archivo:

app-flutter/lib/services/api_service.dart
```bash
static const String baseUrl = 'https://abcd1234.ngrok-free.app';
```
## Aplicación Flutter

#### Ejecución

```bash
cd app-flutter
flutter pub get
flutter run
```

La aplicación mostrará:
- Listado de denuncias
- Formulario para registrar nueva denuncia
- Detalle de denuncia con imagen completa

## Endpoints disponibles (API Flask)

| Método | Ruta | Descripción |
|---------|------|-------------|
| POST | /api/denuncias | Crea una denuncia con imagen Base64 |
| GET | /api/denuncias | Lista todas las denuncias |
| GET | /api/denuncias/<id> | Devuelve una denuncia específica |

## Pruebas con Postman

### Crear denuncia

```
POST https://<ngrok-url>/api/denuncias
Header: Content-Type: application/json
```

Ejemplo de cuerpo JSON:
```json
{
  "correo": "alumno@duoc.cl",
  "descripcion": "Basura acumulada en el pasillo del segundo piso",
  "ubicacion": "-36.82699, -73.04977",
  "foto": "iVBORw0KGgoAAAANSUhEUgAA..."
}
```

### Listar denuncias

```
GET https://<ngrok-url>/api/denuncias
```

Devuelve un arreglo JSON con todas las denuncias registradas.

## Estructura de archivos del backend
- `app.py` → Lógica principal del servidor y endpoints
- `denuncias.db` → Base de datos SQLite
- `uploads/` → Carpeta donde se guardan las imágenes subidas
- `requirements.txt` → Dependencias del proyecto Flask

## Backend – Funcionamiento

1. Flask recibe la solicitud `POST /api/denuncias` con una imagen codificada en Base64.  
2. Decodifica y guarda la imagen en la carpeta `/uploads`.  
3. Inserta el registro en SQLite con los campos: correo, descripción, ubicación, foto y fecha.  
4. Flutter puede acceder a las imágenes en línea vía `GET /uploads/<nombre>`.

## App Flutter – Funcionalidades

- Enviar denuncias con foto (Base64)
- Obtener ubicación automática
- Mostrar listado actualizado desde Flask
- Ver detalles con imagen completa y fecha
- Interfaz responsiva con Material 3

## Estructura del código Flutter

```
app-flutter/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── denuncia.dart
│   ├── services/
│   │   └── api_service.dart
│   └── screens/
│       ├── listado_screen.dart
│       ├── nueva_denuncia_screen.dart
│       └── detalle_screen.dart
└── pubspec.yaml
```

### Descripción

- `api_service.dart` → Comunicación HTTP con Flask  
- `nueva_denuncia_screen.dart` → Formulario para crear denuncias  
- `listado_screen.dart` → Muestra todas las denuncias  
- `detalle_screen.dart` → Vista con imagen completa y detalles  
- `denuncia.dart` → Modelo de datos  

