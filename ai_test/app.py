import os
import json
import mysql.connector
from flask import Flask, render_template, request, jsonify
from google.generativeai import GenerativeModel
import google.generativeai as genai
from dotenv import load_dotenv

# Load environment variables
load_dotenv('ai_apis.env')

app = Flask(__name__)

# Configure Gemini API
GOOGLE_API_KEY = os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=GOOGLE_API_KEY)
model = GenerativeModel('gemini-2.0-flash')


# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'adet_rentease'
}

def get_db_connection():
    """Create and return a database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except mysql.connector.Error as err:
        print(f"Database connection error: {err}")
        return None


def get_database_schema():
    """Get the complete database schema information"""
    connection = get_db_connection()
    if not connection:
        return "Database connection failed"
    
    try:
        cursor = connection.cursor()
        
        # Get all tables
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        
        schema_info = {
            "database": DB_CONFIG['database'],
            "tables": {}
        }
        
        for table in tables:
            table_name = table[0]
            
            # Get table structure
            cursor.execute(f"DESCRIBE {table_name}")
            columns = cursor.fetchall()
            
            # Get sample data (first 3 rows)
            cursor.execute(f"SELECT * FROM {table_name} LIMIT 3")
            sample_data = cursor.fetchall()
            
            # Get column names for sample data
            cursor.execute(f"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table_name}' AND TABLE_SCHEMA = '{DB_CONFIG['database']}'")
            column_names = [row[0] for row in cursor.fetchall()]
            
            schema_info["tables"][table_name] = {
                "columns": columns,
                "sample_data": sample_data,
                "column_names": column_names
            }
        
        return schema_info
        
    except mysql.connector.Error as err:
        return f"Error retrieving schema: {err}"
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

def execute_query(query):
    """Execute a SQL query and return results"""
    connection = get_db_connection()
    if not connection:
        return "Database connection failed"
    
    try:
        cursor = connection.cursor()
        cursor.execute(query)
        
        # Check if it's a SELECT query
        if query.strip().upper().startswith('SELECT'):
            results = cursor.fetchall()
            column_names = [desc[0] for desc in cursor.description]
            return {
                "columns": column_names,
                "data": results,
                "row_count": len(results)
            }
        else:
            connection.commit()
            return f"Query executed successfully. Rows affected: {cursor.rowcount}"
            
    except mysql.connector.Error as err:
        return f"Query error: {err}"
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

def get_lookup_data():
    """Get lookup data for ID to name mappings"""
    connection = get_db_connection()
    if not connection:
        return {}
    
    try:
        cursor = connection.cursor()
        lookup_data = {}
        
        # Get user names (user_id -> full_name)
        cursor.execute("SELECT user_id, full_name FROM users")
        users = cursor.fetchall()
        lookup_data['users'] = {str(user[0]): user[1] for user in users}
        
        # Get property names (property_id -> property_name)
        cursor.execute("SELECT property_id, property_name FROM properties")
        properties = cursor.fetchall()
        lookup_data['properties'] = {str(prop[0]): prop[1] for prop in properties}
        
        # Get room info (room_id -> property_name + room_type)
        cursor.execute("""
            SELECT r.room_id, p.property_name, r.room_type 
            FROM rooms r 
            JOIN properties p ON r.property_id = p.property_id
        """)
        rooms = cursor.fetchall()
        lookup_data['rooms'] = {str(room[0]): f"{room[1]} - {room[2]}" for room in rooms}
        
        return lookup_data
        
    except mysql.connector.Error as err:
        print(f"Error getting lookup data: {err}")
        return {}
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

def replace_ids_with_names(query_result, lookup_data):
    """Replace IDs with their corresponding names in query results"""
    if not isinstance(query_result, dict) or 'data' not in query_result:
        return query_result
    
    columns = query_result['columns']
    data = query_result['data']
    
    # Create mapping of column names to their indices
    col_indices = {col: i for i, col in enumerate(columns)}
    
    # Process each row
    processed_data = []
    for row in data:
        processed_row = list(row)
        
        # Replace user_id with full_name
        if 'user_id' in col_indices:
            user_id = str(row[col_indices['user_id']])
            if user_id in lookup_data.get('users', {}):
                processed_row[col_indices['user_id']] = lookup_data['users'][user_id]
        
        # Replace tenant_id with full_name
        if 'tenant_id' in col_indices:
            tenant_id = str(row[col_indices['tenant_id']])
            if tenant_id in lookup_data.get('users', {}):
                processed_row[col_indices['tenant_id']] = lookup_data['users'][tenant_id]
        
        # Replace owner_id with full_name
        if 'owner_id' in col_indices:
            owner_id = str(row[col_indices['owner_id']])
            if owner_id in lookup_data.get('users', {}):
                processed_row[col_indices['owner_id']] = lookup_data['users'][owner_id]
        
        # Replace sender_id with full_name
        if 'sender_id' in col_indices:
            sender_id = str(row[col_indices['sender_id']])
            if sender_id in lookup_data.get('users', {}):
                processed_row[col_indices['sender_id']] = lookup_data['users'][sender_id]
        
        # Replace receiver_id with full_name
        if 'receiver_id' in col_indices:
            receiver_id = str(row[col_indices['receiver_id']])
            if receiver_id in lookup_data.get('users', {}):
                processed_row[col_indices['receiver_id']] = lookup_data['users'][receiver_id]
        
        # Replace property_id with property_name
        if 'property_id' in col_indices:
            property_id = str(row[col_indices['property_id']])
            if property_id in lookup_data.get('properties', {}):
                processed_row[col_indices['property_id']] = lookup_data['properties'][property_id]
        
        # Replace room_id with property_name + room_type
        if 'room_id' in col_indices:
            room_id = str(row[col_indices['room_id']])
            if room_id in lookup_data.get('rooms', {}):
                processed_row[col_indices['room_id']] = lookup_data['rooms'][room_id]
        
        processed_data.append(tuple(processed_row))
    
    return {
        "columns": columns,
        "data": processed_data,
        "row_count": len(processed_data)
    }

@app.route('/')
def index():
    """Main page with chat interface"""
    return render_template('index.html')

@app.route('/api/chat', methods=['POST'])
def chat():
    """Handle chat messages with Gemini"""
    try:
        data = request.get_json()
        user_message = data.get('message', '')
        
        if not user_message:
            return jsonify({'error': 'No message provided'}), 400
        
        # Get database schema for context
        schema_info = get_database_schema()
        
        # Create context for Gemini to generate SQL queries
        sql_context = f"""
You are a SQL query generator for a rental property management database called 'adet_rentease'. 

Database Schema Information:
{json.dumps(schema_info, indent=2, default=str)}

Based on the user's question, generate ONLY a SQL SELECT query that will answer their question. 
Return ONLY the SQL query, nothing else. No explanations, no markdown formatting, just the pure SQL.

User Question: {user_message}

SQL Query:"""
        
        # Generate SQL query using Gemini
        sql_response = model.generate_content(sql_context)
        sql_query = sql_response.text.strip()
        
        # Clean up the SQL query (remove any markdown formatting)
        sql_query = sql_query.replace('```sql', '').replace('```', '').strip()
        
        print(f"Generated SQL: {sql_query}")  # Debug line
        
        # Execute the SQL query
        query_result = execute_query(sql_query)
        
        if isinstance(query_result, str) and "error" in query_result.lower():
            # If query failed, return error message
            return jsonify({
                'response': f"I encountered an error while querying the database: {query_result}",
                'timestamp': None
            })
        
        # Get lookup data and replace IDs with names
        lookup_data = get_lookup_data()
        processed_result = replace_ids_with_names(query_result, lookup_data)
        
        # Create context for Gemini to interpret the results
        results_context = f"""
You are an AI assistant helping with a rental property management database called 'adet_rentease'. 

User Question: {user_message}
SQL Query Executed: {sql_query}
Query Results: {json.dumps(processed_result, indent=2, default=str)}

IMPORTANT: The query results have been processed to replace IDs with meaningful names:
- user_id, tenant_id, owner_id, sender_id, receiver_id → Full names of users
- property_id → Property names (e.g., "Santos Boarding House")
- room_id → Property name + room type (e.g., "Santos Boarding House - Single")

Based on the query results, provide a clear, helpful answer to the user's question. Format the data in a readable way. If there are multiple results, present them in a nice format. If there are no results, explain what that means.

Answer:"""
        
        # Generate final response using Gemini
        final_response = model.generate_content(results_context)
        
        return jsonify({
            'response': final_response.text,
            'timestamp': str(final_response.created_at) if hasattr(final_response, 'created_at') else None
        })
        
    except Exception as e:
        return jsonify({'error': f'Error processing request: {str(e)}'}), 500

@app.route('/api/query', methods=['POST'])
def execute_sql_query():
    """Execute SQL queries directly"""
    try:
        data = request.get_json()
        query = data.get('query', '')
        
        if not query:
            return jsonify({'error': 'No query provided'}), 400
        
        # Basic security check - only allow SELECT queries for safety
        if not query.strip().upper().startswith('SELECT'):
            return jsonify({'error': 'Only SELECT queries are allowed for security reasons'}), 400
        
        result = execute_query(query)
        
        return jsonify({
            'result': result,
            'query': query
        })
        
    except Exception as e:
        return jsonify({'error': f'Error executing query: {str(e)}'}), 500

@app.route('/api/schema')
def get_schema():
    """Get database schema information"""
    schema = get_database_schema()
    return jsonify(schema)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
