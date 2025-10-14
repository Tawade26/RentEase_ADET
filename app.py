from flask import Flask, request, jsonify, render_template, redirect, url_for, session
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
app.secret_key = 'your-secret-key-here'  # Change this to a random secret key

db_config = {
    'host': 'localhost',
    'user': 'root', 
    'password': '',
    'database': 'adet_rentease'
}

def get_db_connection():
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

@app.route('/')
def index():
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        
        conn = get_db_connection()
        if conn is None:
            return render_template('login.html', error='Database connection failed')
        
        try:
            cursor = conn.cursor(dictionary=True)
            query = "SELECT * FROM users WHERE email = %s AND password = %s"
            cursor.execute(query, (email, password))
            user = cursor.fetchone()
            
            if user:
                session['user_id'] = user['user_id']
                session['user_name'] = user['full_name']
                session['user_role'] = user['role']
                
                # Redirect based on role
                if user['role'] == 'tenant':
                    return redirect(url_for('browse'))
                elif user['role'] == 'owner':
                    return redirect(url_for('dashboard'))
                elif user['role'] == 'admin':
                    return redirect(url_for('admin'))
            else:
                return render_template('login.html', error='Email or password is incorrect')
                
        except Error as e:
            print(f"Database error: {e}")
            return render_template('login.html', error='Database error occurred')
        finally:
            if conn.is_connected():
                cursor.close()
                conn.close()
    
    return render_template('login.html')

@app.route('/browse')
def browse():
    if 'user_id' not in session or session['user_role'] != 'tenant':
        return redirect(url_for('login'))
    
    conn = get_db_connection()
    if conn is None:
        return "Database connection failed"
    
    try:
        cursor = conn.cursor(dictionary=True)
        query = "SELECT * FROM properties ORDER BY date_posted DESC"
        cursor.execute(query)
        properties = cursor.fetchall()
        
        user = {
            'full_name': session['user_name']
        }
        
        return render_template('browse.html', properties=properties, user=user)
        
    except Error as e:
        print(f"Database error: {e}")
        return "Database error occurred"
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session or session['user_role'] != 'owner':
        return redirect(url_for('login'))
    
    conn = get_db_connection()
    if conn is None:
        return "Database connection failed"
    
    try:
        cursor = conn.cursor(dictionary=True)
        query = "SELECT * FROM properties WHERE owner_id = %s ORDER BY date_posted DESC"
        cursor.execute(query, (session['user_id'],))
        properties = cursor.fetchall()
        
        user = {
            'full_name': session['user_name']
        }
        
        return render_template('dashboard.html', properties=properties, user=user)
        
    except Error as e:
        print(f"Database error: {e}")
        return "Database error occurred"
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

@app.route('/admin')
def admin():
    if 'user_id' not in session or session['user_role'] != 'admin':
        return redirect(url_for('login'))
    
    conn = get_db_connection()
    if conn is None:
        return "Database connection failed"
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Get statistics
        cursor.execute("SELECT COUNT(*) as count FROM users")
        total_users = cursor.fetchone()['count']
        
        cursor.execute("SELECT COUNT(*) as count FROM properties")
        total_properties = cursor.fetchone()['count']
        
        cursor.execute("SELECT COUNT(*) as count FROM bookings")
        total_bookings = cursor.fetchone()['count']
        
        cursor.execute("SELECT COUNT(*) as count FROM payments")
        total_payments = cursor.fetchone()['count']
        
        stats = {
            'total_users': total_users,
            'total_properties': total_properties,
            'total_bookings': total_bookings,
            'total_payments': total_payments
        }
        
        user = {
            'full_name': session['user_name']
        }
        
        return render_template('admin.html', stats=stats, user=user)
        
    except Error as e:
        print(f"Database error: {e}")
        return "Database error occurred"
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(debug=True)