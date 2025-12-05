from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity, verify_jwt_in_request
from flask_jwt_extended.exceptions import NoAuthorizationError
from jwt.exceptions import ExpiredSignatureError, InvalidTokenError
from dotenv import load_dotenv
import os
import base64
import uuid
from datetime import datetime

# =============================
# CONFIGURACIÓN INICIAL
# =============================
app = Flask(__name__)
CORS(app)

load_dotenv()
print("JWT cargada:", os.getenv("JWT_SECRET_KEY"))

app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY")
jwt = JWTManager(app)


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
# CREAR BASE DE DATOS
# =============================
with app.app_context():
    db.create_all()


# =============================
# LOGIN
# =============================
@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    user = data.get("user")
    password = data.get("password")

    if user != "admin" or password != "1234":
        return jsonify({"msg": "Credenciales incorrectas"}), 401

    token = create_access_token(identity=user)
    return jsonify({"token": token}), 200


# =============================
# VALIDAR TOKEN
# =============================
@app.route('/validate-token', methods=['POST'])
def validate_token():
    """
    Valida si el token JWT es válido y no ha expirado.
    El token debe venir en el header Authorization como 'Bearer <token>'
    """
    try:
        # Verifica el JWT en el request actual
        verify_jwt_in_request()
        
        # Si llegamos aquí, el token es válido
        current_user = get_jwt_identity()
        
        return jsonify({
            "valid": True, 
            "user": current_user
        }), 200
        
    except NoAuthorizationError:
        return jsonify({"error": "Token no proporcionado"}), 401
    
    except ExpiredSignatureError:
        return jsonify({"error": "Token expirado"}), 401
    
    except Exception as e:
        return jsonify({"error": "Token inválido"}), 401


# =============================
# ENDPOINTS PROTEGIDOS
# =============================

# 📩 Crear denuncia
@app.route('/api/denuncias', methods=['POST'])
@jwt_required()
def crear_denuncia():
    print("👉 Headers:", request.headers)
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

    # Procesar imagen
    try:
        raw = base64.b64decode(foto_b64, validate=True)
    except:
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


# 📋 Listar denuncias
@app.route('/api/denuncias', methods=['GET'])
@jwt_required()
def listar_denuncias():
    denuncias = Denuncia.query.order_by(Denuncia.id.desc()).all()
    return jsonify([d.to_dict() for d in denuncias])


# 🔍 Ver detalle
@app.route('/api/denuncias/<int:id>', methods=['GET'])
@jwt_required()
def detalle_denuncia(id):
    denuncia = Denuncia.query.get_or_404(id)
    return jsonify(denuncia.to_dict())


# ❌ Eliminar una denuncia
@app.route('/api/denuncias/<int:id>', methods=['DELETE'])
@jwt_required()
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
    return "🚀 API de Denuncias con JWT funcionando correctamente."

if __name__ == '__main__':
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    app.run(host="0.0.0.0", port=5000, debug=True)