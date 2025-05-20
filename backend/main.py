from flask import Flask, jsonify, request
from datetime import datetime
from flask_cors import CORS 
import mysql.connector
import uuid
import base64
import os
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'static/images'
CORS(app)

# Koneksi MySQL
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="db_koperasi"
)

# Fungsi untuk memeriksa dan menghubungkan ulang database jika koneksi terputus
def get_db_connection():
    if not db.is_connected():
        db.reconnect()
    return db

# ==================== PRODUK ====================

@app.route('/add_produk', methods=['POST'])
def add_produk():
    folder_path = 'static/images'
    data = request.form
    nama = request.form.get("nama")
    harga = request.form.get("harga")
    stock = request.form.get("stock")  
    gambar = request.files.get("gambar")
    id_kategori = request.form.get("id_kategori")

    if not gambar:
        return jsonify({'message': 'Gambar kosong'}), 400

    filename = secure_filename(gambar.filename)
    image_path = os.path.join(folder_path, filename)
    gambar.save(image_path)

    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute(
        "INSERT INTO produk (nama, stock, harga, gambar, id_kategori) VALUES (%s, %s, %s, %s, %s)",
        (nama, stock, harga, filename, id_kategori)
    )
    db_conn.commit()
    cursor.close()
    return jsonify({'message': 'produk ditambahkan'})

@app.route('/produk', methods=['GET'])
def get_produk_all():
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM produk")
    data = cursor.fetchall()
    cursor.close()
    return jsonify(data)

@app.route('/produk/<int:id>', methods=['GET'])
def get_produk_by_id(id):
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM produk WHERE id_produk = %s", (id,))
    produk = cursor.fetchone()
    cursor.close()

    if produk:
        return jsonify(produk)
    else:
        return jsonify({'message': 'Produk tidak ditemukan'}), 404

@app.route('/produk/<int:id>', methods=['PUT'])
def update_produk(id):
    data = request.get_json()

    if not data:
        return jsonify({'message': 'Request harus berupa JSON'}), 400

    nama = data.get("nama")
    stock = data.get("stock")
    harga = data.get("harga")
    id_kategori = data.get("id_kategori")
    gambar_base64 = data.get("gambar_base64")

    if not all([nama, stock, harga, id_kategori]):
        return jsonify({'message': 'Data tidak lengkap'}), 400

    try:
        stock = int(stock)
        harga = int(harga)
        id_kategori = int(id_kategori)
    except ValueError:
        return jsonify({'message': 'Stock, harga, dan id_kategori harus berupa angka'}), 400

    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)

    # ambil nama file gambar lama
    cursor.execute("SELECT gambar FROM produk WHERE id_produk = %s", (id,))
    result = cursor.fetchone()

    if not result:
        cursor.close()
        return jsonify({'message': 'Produk tidak ditemukan'}), 404

    filename = result['gambar']

    # jika ada gambar baru (dikirim base64), overwrite file lama
    if gambar_base64:
        try:
            # Validasi dan decoding gambar
            filename = secure_filename(f"{nama.replace(' ', '_')}.jpg")
            image_path = os.path.join('static', 'images', filename)

            # Create directory if not exists
            os.makedirs(os.path.dirname(image_path), exist_ok=True)

            # Write the image to the file system
            with open(image_path, "wb") as f:
                f.write(base64.b64decode(gambar_base64))
        except Exception as e:
            cursor.close()
            return jsonify({'message': f'Gagal mengupdate gambar: {str(e)}'}), 500

    # update data di database
    try:
        cursor.execute(
            "UPDATE produk SET nama=%s, stock=%s, harga=%s, gambar=%s, id_kategori=%s WHERE id_produk=%s",
            (nama, stock, harga, filename, id_kategori, id)
        )
        db_conn.commit()
    except Exception as e:
        db_conn.rollback()
        cursor.close()
        return jsonify({'message': f'Gagal mengupdate produk: {str(e)}'}), 500

    cursor.close()
    return jsonify({'message': 'Produk berhasil diupdate'}), 200

@app.route('/produk/<int:id>', methods=['DELETE'])
def delete_produk(id):
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("DELETE FROM produk WHERE id_produk=%s", (id,))
    db_conn.commit()
    cursor.close()
    return jsonify({'message': 'produk dihapus'})

@app.route('/produk/best_seller', methods=['GET'])
def get_produk_best_seller():
    db_conn = get_db_connection()   
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM produk ORDER BY terjual DESC LIMIT 5")
    rows = cursor.fetchall()
    data = []
    for row in rows :
        data.append({
            'id_produk': row['id_produk'],
            'nama': row['nama'],
            'harga': row['harga'],
            'stock': row['stock'],
            'gambar': row['gambar'],
            'id_kategori' : row['id_kategori']
        })
    cursor.close()
    return jsonify(data)

@app.route('/produk/kategori/<int:kategori>', methods=['GET'])
def get_produk_by_kategori(kategori):
    db_conn = get_db_connection()   
    cursor = db_conn.cursor(dictionary=True)
    
    try:
        cursor.execute("""
            SELECT p.*, k.nama
            FROM produk p 
            JOIN kategori k ON p.id_kategori = k.id_kategori 
            WHERE p.id_kategori = %s
        """, [kategori])
        rows = cursor.fetchall()

        if not rows:
            return jsonify({"message": "Produk tidak ditemukan dalam kategori ini"}), 404

        data = []
        for row in rows:
            data.append({
                'id_produk': row['id_produk'],
                'nama': row['nama'],
                'harga': row['harga'],
                'stock': row['stock'],
                'gambar': row['gambar'],
                'id_kategori': row['id_kategori'],
            })

        return jsonify(data)
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()


@app.route('/produk/search/<string:searchQuery>', methods=['GET'])
def search_produk(searchQuery):
    db_conn = get_db_connection()   
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM produk WHERE nama LIKE %s", ['%' + searchQuery + '%'])
    rows = cursor.fetchall()
    data = []
    for row in rows :
        data.append({
            'id_produk': row['id_produk'],
            'nama': row['nama'],
            'harga': row['harga'],
            'stock': row['stock'],
            'gambar': row['gambar'],
            'id_kategori' : row['id_kategori']
        })
    cursor.close()
    return jsonify(data)

# ==================== PROFILE ====================

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get("username")
    password = data.get("password")

    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE username=%s AND password=%s", (username, password))
    user = cursor.fetchone()
    cursor.close()

    if user:
        return jsonify({
            "message": "Login berhasil",
            "role": user["role"],
            "name": user["name"],
            "id": user["id_users"]
        })
    else:
        return jsonify({"message": "Username atau password salah"}), 401

@app.route('/register', methods=['POST'])
def register():
    data = request.json
    name = data.get("name")
    username = data.get("username")
    password = data.get("password")
    role = int(data.get("role"))

    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE username=%s", (username,))
    if cursor.fetchone():
        cursor.close()
        return jsonify({"status": "error", "message": "username sudah terdaftar"})

    if not name or not username or not password or role is None:
        cursor.close()
        return jsonify({"message": "Semua field harus diisi"}), 400

    cursor.execute("INSERT INTO users (name, username, password, role) VALUES (%s, %s, %s, %s)",
                   (name, username, password, role))
    db_conn.commit()
    cursor.close()
    return jsonify({"status": "success", "message": "Register berhasil"})

@app.route('/users', methods=['GET'])
def get_user_all():
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users")
    data = cursor.fetchall()
    cursor.close()
    return jsonify(data)

@app.route('/profile/<int:user_id>', methods=['GET'])
def get_profile(user_id):
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE id_users = %s", (user_id,))
    user = cursor.fetchone()
    cursor.close()

    if user:
        return jsonify(user), 200
    else:
        return jsonify({'message': 'User not found'}), 404

@app.route('/users/update/<int:user_id>', methods=['PUT'])
def update_user(user_id):

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    nama = request.form.get('nama')
    password = request.form.get('password')  # Optional
    photo = request.files.get('gambar_users')  # Optional

    fields = []
    values = []

    if nama:
        fields.append("name = %s")
        values.append(nama)

    if password:
        # Simple hashing, ganti dengan bcrypt di real project
        fields.append("password = %s")
        values.append(password)

    if photo:
        filename = secure_filename(f"{uuid.uuid4().hex}_{photo.filename}")
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        photo.save(filepath)
        photo_url = f"{request.host_url}static/images/{filename}"
        fields.append("gambar_users = %s")
        values.append(photo_url)

    if not fields:
        return jsonify({"message": "No data to update"}), 400

    values.append(user_id)
    update_query = f"UPDATE users SET {', '.join(fields)} WHERE id_users = %s"
    cursor.execute(update_query, values)
    db.commit()
    cursor.close()
    return jsonify({"message": "User updated successfully"})

# ==================== KERANJANG ====================

@app.route('/keranjang/<int:user_id>', methods=['GET'])
def get_keranjang(user_id):
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute('''
        SELECT c.id_checkout, c.jumlah, c.status, c.subtotal, c.tanggal,
               p.id_produk, p.nama, p.harga, p.gambar
        FROM checkout c
        JOIN produk p ON c.id_produk = p.id_produk
        WHERE c.id_user = %s AND c.status = 'pending'
    ''', (user_id,))
    data = cursor.fetchall()
    cursor.close()
    return jsonify(data)

@app.route('/keranjangwithstatus/<int:user_id>', methods=['GET'])
def get_keranjangs(user_id):
    try:
        db_conn = get_db_connection()
        cursor = db_conn.cursor(dictionary=True)
        cursor.execute('''
            SELECT c.id_checkout, c.jumlah, c.status, c.subtotal, c.tanggal,
                   p.id_produk, p.nama AS nama_produk, p.harga, p.gambar
            FROM checkout c
            JOIN produk p ON c.id_produk = p.id_produk
            WHERE c.id_user = %s AND c.status = 'menunggu pembayaran'
        ''', (user_id,))
        data = cursor.fetchall()
        cursor.close()
        return jsonify(data), 200
    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

@app.route('/keranjang/tambah', methods=['POST'])
def tambah_keranjang():
    data = request.json
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute('''
        INSERT INTO checkout (id_user, id_produk, jumlah, subtotal, status, tanggal)
        VALUES (%s, %s, %s, %s, %s, NOW())
    ''', (data['id_user'], data['id_produk'], data['jumlah'], data['subtotal'], 'pending'))
    db_conn.commit()
    cursor.close()
    return jsonify({'message': 'Produk ditambahkan ke keranjang'})

@app.route('/keranjang/hapus/<int:id_checkout>', methods=['DELETE'])
def hapus_dari_keranjang(id_checkout):
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("DELETE FROM checkout WHERE id_checkout = %s", (id_checkout,))
    db_conn.commit()
    cursor.close()
    return jsonify({'message': 'Item dihapus dari keranjang'})

@app.route('/keranjang/checkout/<int:user_id>', methods=['PUT'])
def proses_checkout(user_id):
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("UPDATE checkout SET status = 'menunggu pembayaran' WHERE id_user = %s AND status = 'pending'", (user_id,))
    db_conn.commit()
    cursor.close()
    return jsonify({'message': 'Checkout berhasil'})

# ==================== TRANSAKSI ====================

@app.route('/transaksi/bayar', methods=['POST'])
def buat_transaksi():
    data = request.json
    id_user = data.get('id_user')
    metode_pembayaran = data.get('metode_pembayaran')
    total = data.get('total')

    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute(
        "INSERT INTO transaksi (id_user, metode_pembayaran,total, status_pembayaran, tanggal) VALUES (%s, %s, %s,%s, NOW())",
        (id_user, metode_pembayaran,total, 'Menunggu Konfirmasi')
    )
    id_transaksi = cursor.lastrowid

    cursor.execute("SELECT * FROM checkout WHERE id_user = %s AND status = 'menunggu pembayaran'", (id_user,))
    items = cursor.fetchall()

    for item in items:
        cursor.execute('''
            INSERT INTO transaksi_detail (id_transaksi, id_produk, jumlah, subtotal)
            VALUES (%s, %s, %s, %s)
        ''', (id_transaksi, item['id_produk'], item['jumlah'], item['subtotal']))

    cursor.execute("UPDATE checkout SET status = 'selesai' WHERE id_user = %s AND status = 'menunggu pembayaran'", (id_user,))
    db_conn.commit()
    cursor.close()
    return jsonify({'message': 'Transaksi berhasil dibuat', 'id_transaksi': id_transaksi})

@app.route('/transaksi/<int:user_id>', methods=['GET'])
def get_riwayat_transaksi(user_id):
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM transaksi WHERE id_user = %s ORDER BY tanggal DESC", (user_id,))
    data = cursor.fetchall()
    cursor.close()
    return jsonify(data)

@app.route('/transaksi', methods=['GET'])
def get_all_transaksi():
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute('''
        SELECT t.*, u.name 
        FROM transaksi t
        JOIN users u ON t.id_user = u.id_users
        ORDER BY t.tanggal DESC
    ''')
    data = cursor.fetchall()
    cursor.close()
    return jsonify(data)

@app.route('/transaksi/detail/<int:id_transaksi>', methods=['GET'])
def get_detail_transaksi(id_transaksi):
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)

    # Ambil detail produk dalam transaksi
    cursor.execute('''
        SELECT td.id, td.jumlah, td.subtotal,
               p.id_produk, p.nama, p.harga, p.gambar
        FROM transaksi_detail td
        JOIN produk p ON td.id_produk = p.id_produk
        WHERE td.id_transaksi = %s
    ''', (id_transaksi,))
    detail = cursor.fetchall()

    # Ambil data transaksi beserta nama user
    cursor.execute("""
        SELECT t.*, u.name
        FROM transaksi t
        JOIN users u ON t.id_user = u.id_users
        WHERE t.id_transaksi = %s
    """, (id_transaksi,))
    transaksi = cursor.fetchone()

    cursor.close()

    if transaksi:
        return jsonify({
            'transaksi': transaksi,
            'detail': detail
        })
    else:
        return jsonify({'message': 'Transaksi tidak ditemukan'}), 404
    
@app.route('/transaksi/<int:id_transaksi>/status', methods=['PUT'])
def update_status_transaksi(id_transaksi):
    
    data = request.json
    status = data.get('status')
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("UPDATE transaksi SET status_pembayaran = %s WHERE id_transaksi = %s", (status, id_transaksi))
    
    if status.lower() == 'selesai':
        cursor.execute('''
            SELECT td.id_produk, td.jumlah, p.stock
            FROM transaksi_detail td
            JOIN produk p ON td.id_produk = p.id_produk
            WHERE td.id_transaksi = %s
        ''', (id_transaksi,))
        produk_terjual = cursor.fetchall()

        for item in produk_terjual:
            if item['stock'] < item['jumlah']:
                cursor.execute("UPDATE transaksi SET status_pembayaran = %s WHERE id_transaksi = %s", ('Dibatalkan', id_transaksi))  
                cursor.close()
                return jsonify({'message': f"Stok produk ID {item['id_produk']} tidak cukup"}), 400

        for item in produk_terjual:
            cursor.execute('''
                UPDATE produk SET stock = stock - %s, terjual = terjual + %s WHERE id_produk = %s
            ''', (item['jumlah'],item['jumlah'], item['id_produk']))

    
    db_conn.commit()
    cursor.close()

    return jsonify({'message': 'Status transaksi berhasil diperbarui'})

# ==================== KATEGORI ====================

@app.route('/kategori', methods=['GET'])
def get_kategori():
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("SELECT id_kategori, nama FROM kategori")
    rows = cursor.fetchall()
    categories = []
    for row in rows:
        categories.append({
            'id_kategori': row['id_kategori'],
            'nama': row['nama']
        })
    cursor.close()
    return jsonify(categories)

# ==================== LAPORAN ====================

@app.route('/laporan/penjualan_bulanan', methods=['GET'])
def laporan_penjualan_bulanan(): 
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT 
            DATE_FORMAT(tanggal, '%Y-%m') AS bulan,
            SUM(total) AS total_penjualan
        FROM transaksi
        WHERE status_pembayaran = 'Selesai'
        GROUP BY DATE_FORMAT(tanggal, '%Y-%m')
        ORDER BY bulan
    """)
    rows = cursor.fetchall()
    data = [{"bulan": row["bulan"], "total": row["total_penjualan"]} for row in rows]
    cursor.close()
    return jsonify(data)

@app.route('/laporan/penjualan_mingguan', methods=['GET'])
def laporan_penjualan_mingguan(): 
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT 
            YEAR(tanggal) AS tahun,
            WEEK(tanggal, 1) AS minggu_ke,  -- mode 1: minggu mulai Senin
            CONCAT(YEAR(tanggal), '-W', LPAD(WEEK(tanggal, 1), 2, '0')) AS minggu,
            SUM(total) AS total_penjualan
        FROM transaksi
        WHERE status_pembayaran = 'Selesai'
        GROUP BY tahun, minggu_ke
        ORDER BY tahun, minggu_ke
    """)
    rows = cursor.fetchall()
    data = [{"minggu": row["minggu"], "total": row["total_penjualan"]} for row in rows]
    cursor.close()
    return jsonify(data)

@app.route('/laporan/penjualan_harian', methods=['GET'])
def laporan_penjualan_harian(): 
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT 
            DATE(tanggal) AS tanggal,
            SUM(total) AS total_penjualan
        FROM transaksi
        WHERE status_pembayaran = 'Selesai'
        GROUP BY DATE(tanggal)
        ORDER BY tanggal
    """)
    rows = cursor.fetchall()
    data = [{"tanggal": row["tanggal"], "total": row["total_penjualan"]} for row in rows]
    cursor.close()
    return jsonify(data)

@app.route('/laporan/penjualan_tahunan', methods=['GET'])
def laporan_penjualan_tahunan(): 
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT 
            YEAR(tanggal) AS tahun,
            SUM(total) AS total_penjualan
        FROM transaksi
        WHERE status_pembayaran = 'Selesai'
        GROUP BY YEAR(tanggal)
        ORDER BY tahun
    """)
    rows = cursor.fetchall()
    data = [{"tahun": str(row["tahun"]), "total": row["total_penjualan"]} for row in rows]
    cursor.close()
    return jsonify(data)


@app.route('/laporan/produk_terlaris', methods=['GET'])
def produk_terlaris():
    db_conn = get_db_connection()
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT 
            p.nama AS nama,
            SUM(td.jumlah) AS total_terjual
        FROM transaksi_detail td
        JOIN produk p ON td.id_produk = p.id_produk
        JOIN transaksi t ON td.id_transaksi = t.id_transaksi
        WHERE t.status_pembayaran = 'Selesai'
        GROUP BY td.id_produk
        ORDER BY total_terjual DESC
        LIMIT 5
    """)
    rows = cursor.fetchall()
    data = [{"produk": row["nama"], "jumlah": row["total_terjual"]} for row in rows]
    cursor.close()
    return jsonify(data)


if __name__ == '__main__':
    app.run(debug=True)
