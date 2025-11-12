from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import os
import base64
import uuid
from datetime import datetime

# =============================
# CONFIGURACIÓN INICIAL
# =============================
app = Flask(__name__)
CORS(app)

# Base de datos SQLite local
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///denuncias.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = 'uploads'

db = SQLAlchemy(app)

# =============================
# MODELO DE DENUNCIA
# =============================
class Denuncia(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    correo = db.Column(db.String(100), nullable=False)
    descripcion = db.Column(db.Text, nullable=False)
    ubicacion = db.Column(db.String(200))
    foto = db.Column(db.String(200))
    fecha = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "correo": self.correo,
            "descripcion": self.descripcion,
            "ubicacion": self.ubicacion,
            "foto": self.foto,
            "fecha": self.fecha.strftime("%Y-%m-%d %H:%M:%S")
        }

# =============================
# CREACIÓN DE BASE DE DATOS
# =============================
with app.app_context():
    db.create_all()

# =============================
# ENDPOINTS
# =============================

# 📩 Crear denuncia (con imagen Base64)
@app.route('/api/denuncias', methods=['POST'])
def crear_denuncia():
    # 👇 Estas líneas de depuración DEBEN estar indentadas dentro de la función
    print("👉 Headers:", request.headers)
    print("👉 Content-Type:", request.content_type)
    print("👉 Body:", request.data[:200])

    data = request.get_json(silent=True)
    if not data:
        return jsonify({"error": "Se esperaba un JSON"}), 400

    correo = (data.get("correo") or "").strip()
    descripcion = (data.get("descripcion") or "").strip()
    ubicacion = (data.get("ubicacion") or "").strip()
    foto_b64 = data.get("foto")

    if not correo or not descripcion or not foto_b64:
        return jsonify({"error": "correo, descripcion y foto son obligatorios"}), 400

    # Intentar decodificar la imagen Base64
    try:
        raw = base64.b64decode(foto_b64, validate=True)
    except Exception:
        return jsonify({"error": "Formato Base64 inválido"}), 400

    # Guardar la imagen
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    nombre_foto = f"{uuid.uuid4().hex}.jpg"
    ruta_foto = os.path.join(app.config['UPLOAD_FOLDER'], nombre_foto)
    with open(ruta_foto, "wb") as f:
        f.write(raw)

    # Crear registro en la base de datos
    denuncia = Denuncia(
        correo=correo,
        descripcion=descripcion,
        ubicacion=ubicacion,
        foto=nombre_foto
    )
    db.session.add(denuncia)
    db.session.commit()

    return jsonify(denuncia.to_dict()), 201


# 📋 Listar todas las denuncias
@app.route('/api/denuncias', methods=['GET'])
def listar_denuncias():
    denuncias = Denuncia.query.order_by(Denuncia.id.desc()).all()
    return jsonify([d.to_dict() for d in denuncias])


# 🔍 Ver una denuncia por ID
@app.route('/api/denuncias/<int:id>', methods=['GET'])
def detalle_denuncia(id):
    denuncia = Denuncia.query.get_or_404(id)
    return jsonify(denuncia.to_dict())


# 🖼️ Servir imágenes subidas
@app.route('/uploads/<filename>')
def get_image(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# ❌ Eliminar una denuncia específica
@app.route('/api/denuncias/<int:id>', methods=['DELETE'])
def borrar_denuncia(id):
    denuncia = Denuncia.query.get(id)
    if not denuncia:
        return jsonify({"error": "Denuncia no encontrada"}), 404

    # Borrar imagen asociada si existe
    if denuncia.foto:
        ruta_foto = os.path.join(app.config['UPLOAD_FOLDER'], denuncia.foto)
        if os.path.exists(ruta_foto):
            os.remove(ruta_foto)

    db.session.delete(denuncia)
    db.session.commit()
    return jsonify({"mensaje": f"Denuncia {id} eliminada correctamente"}), 200


# =============================
# MAIN
# =============================
@app.route('/')
def home():
    return "🚀 API de Denuncias con imágenes Base64 funcionando correctamente."

if __name__ == '__main__':
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    app.run(host="0.0.0.0", port=5000, debug=True)
