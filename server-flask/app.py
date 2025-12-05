from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash 
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

# =============================
# CONFIGURACIÓN JWT
# =============================
app.config["JWT_SECRET_KEY"] = "carlos"  # CAMBIA ESTO EN PRODUCCIÓN
jwt = JWTManager(app) #esto enciende el jwt manager

db = SQLAlchemy(app)

# =============================
# Modelo usuario
# =============================
class Usuario(db.Model):
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    correo = db.Column(db.String(150), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)

    def to_dict(self):
        return {"id": self.id, "correo": self.correo}

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

# Crear usuario
@app.route('/api/crear_user', methods=['POST'])
def crear_usuario():
    data = request.get_json()

    correo = (data.get("correo") or "").strip()
    password = (data.get("password") or "").strip()

    if not correo or not password:
        return jsonify({"error": "correo y password son obligatorios"}), 400

    if Usuario.query.filter_by(correo=correo).first():
        return jsonify({"error": "El correo ya está registrado"}), 400

    hashed_pass = generate_password_hash(password)

    nuevo = Usuario(correo=correo, password=hashed_pass)
    db.session.add(nuevo)
    db.session.commit()

    return jsonify({"mensaje": "Usuario creado con éxito"}), 201

# Login usuario
@app.route('/api/login_user', methods=['POST'])
def login():
    data = request.get_json()

    correo = data.get("correo")
    password = data.get("password")

    if not correo or not password:
        return jsonify({"error": "Correo y contraseña son obligatorios"}), 400

    usuario = Usuario.query.filter_by(correo=correo).first()

    if not usuario:
        return jsonify({"error": "Credenciales inválidas"}), 401

    if not check_password_hash(usuario.password, password):
        return jsonify({"error": "Credenciales inválidas"}), 401

    access_token = create_access_token(identity=usuario.id)

    return jsonify({
        "msg": "Login exitoso",
        "token": access_token,
        "usuario": usuario.to_dict()
    }), 200

# Listar usuarios (solo personas autenticadas)
@app.route('/api/listar_users', methods=['GET'])
@jwt_required()
def listar_usuarios():
    # Obtener el ID del usuario autenticado (si quieres usarlo)
    usuario_id = get_jwt_identity()

    usuarios = Usuario.query.all()
    return jsonify([u.to_dict() for u in usuarios]), 200

# Crear denuncia
@app.route('/api/denuncias', methods=['POST'])
def crear_denuncia():

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

    try:
        raw = base64.b64decode(foto_b64, validate=True)
    except Exception:
        return jsonify({"error": "Formato Base64 inválido"}), 400

    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    nombre_foto = f"{uuid.uuid4().hex}.jpg"
    ruta_foto = os.path.join(app.config['UPLOAD_FOLDER'], nombre_foto)
    with open(ruta_foto, "wb") as f:
        f.write(raw)

    denuncia = Denuncia(
        correo=correo,
        descripcion=descripcion,
        ubicacion=ubicacion,
        foto=nombre_foto
    )
    db.session.add(denuncia)
    db.session.commit()

    return jsonify(denuncia.to_dict()), 201

# Listar denuncias
@app.route('/api/denuncias', methods=['GET'])
@jwt_required()
def listar_denuncias():
    denuncias = Denuncia.query.order_by(Denuncia.id.desc()).all()
    return jsonify([d.to_dict() for d in denuncias])

# Detalle denuncia
@app.route('/api/denuncias/<int:id>', methods=['GET'])
def detalle_denuncia(id):
    denuncia = Denuncia.query.get_or_404(id)
    return jsonify(denuncia.to_dict())

# Servir imágenes
@app.route('/uploads/<filename>')
def get_image(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# Eliminar denuncia
@app.route('/api/denuncias/<int:id>', methods=['DELETE'])
def borrar_denuncia(id):
    denuncia = Denuncia.query.get(id)
    if not denuncia:
        return jsonify({"error": "Denuncia no encontrada"}), 404

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
