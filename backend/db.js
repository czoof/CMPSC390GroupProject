const mysql = require('mysql2');

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'zoof',
  database: 'legautocustDB'
});

db.connect((err) => {
  if (err) {
    console.log('DB connection failed:', err);
    return;
  }
  console.log('Connected to MySQL database.');
});

module.exports = db;
