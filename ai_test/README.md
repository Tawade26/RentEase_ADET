# RentEase AI Chat Assistant

A Flask web application that integrates Google's Gemini AI with a MySQL database to provide intelligent chat assistance for rental property management.

## Features

- 🤖 **Gemini AI Integration**: Powered by Google's Gemini Pro model
- 🗄️ **MySQL Database Connectivity**: Direct access to your rental property database
- 💬 **Interactive Chat Interface**: Modern, responsive chat UI
- 📊 **Database Schema Awareness**: AI understands your database structure
- 🔍 **Query Assistance**: Get help with database queries and analysis
- 📱 **Mobile Responsive**: Works on desktop and mobile devices

## Database Schema

The application connects to the `adet_rentease` database with the following tables:
- **users**: Tenants, owners, and admins
- **properties**: Rental properties and boarding houses
- **rooms**: Individual rooms with pricing and availability
- **bookings**: Rental reservations and status tracking
- **payments**: Payment records and methods
- **reviews**: Tenant feedback and ratings
- **messages**: Communication system
- **room_images**: Property photos

## Setup Instructions

### Prerequisites

1. **Python 3.8+** installed on your system
2. **MySQL Server** running locally
3. **Google API Key** for Gemini AI

### Installation

1. **Clone or download** this project to your local machine

2. **Install Python dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up your MySQL database**:
   - Import the provided SQL file: `adet_rentease_v3.sql`
   - Ensure MySQL is running on `localhost:3306`
   - Default credentials: `root` user with no password
   - Database name: `adet_rentease`

4. **Configure API Key**:
   - Your Google API key is already configured in `ai_apis.env`
   - The key is: `AIzaSyAwtei4MWHgprlH7uXpr872sZiwnyOPne0`

### Running the Application

1. **Start the Flask server**:
   ```bash
   python app.py
   ```

2. **Open your browser** and navigate to:
   ```
   http://localhost:5000
   ```

3. **Start chatting** with the AI about your rental database!

## Usage Examples

### Sample Questions You Can Ask:

- "How many properties do we have in Manila?"
- "What's the average monthly rate for single rooms?"
- "Show me all tenants who registered this month"
- "Which properties have the highest ratings?"
- "How many bookings are currently pending?"
- "What payment methods are most popular?"
- "List all rooms that are currently available"

### Database Queries

The AI can help you with SQL queries and provide insights based on your data. It understands:
- Table relationships and foreign keys
- Data types and constraints
- Sample data patterns
- Business logic for rental management

## API Endpoints

- `GET /` - Main chat interface
- `POST /api/chat` - Send messages to Gemini AI
- `POST /api/query` - Execute SQL queries (SELECT only)
- `GET /api/schema` - Get database schema information

## Security Features

- Only SELECT queries are allowed for safety
- Input validation and error handling
- Secure database connection handling
- XSS protection in chat interface

## Troubleshooting

### Common Issues:

1. **Database Connection Error**:
   - Ensure MySQL is running
   - Check database credentials in `app.py`
   - Verify database `adet_rentease` exists

2. **Gemini API Error**:
   - Check your API key in `ai_apis.env`
   - Ensure internet connection
   - Verify API key permissions

3. **Port Already in Use**:
   - Change port in `app.py` (line: `app.run(debug=True, host='0.0.0.0', port=5000)`)
   - Or stop other services using port 5000

### Getting Help:

If you encounter issues:
1. Check the console output for error messages
2. Verify all dependencies are installed correctly
3. Ensure MySQL database is properly set up
4. Check your internet connection for API calls

## File Structure

```
AI_RentEase_Sample/
├── app.py                 # Main Flask application
├── templates/
│   └── index.html         # Chat interface HTML
├── requirements.txt       # Python dependencies
├── ai_apis.env           # API configuration
├── adet_rentease_v3.sql  # Database schema
└── README.md             # This file
```

## Technology Stack

- **Backend**: Flask (Python)
- **AI**: Google Gemini Pro
- **Database**: MySQL
- **Frontend**: HTML5, CSS3, JavaScript
- **Styling**: Modern CSS with gradients and animations

---

**Ready to explore your rental data with AI!** 🚀
