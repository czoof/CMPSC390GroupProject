const mysql = require("mysql2");
require("dotenv").config();

const db = mysql.createConnection({
  host: process.env.DB_HOST || process.env.MYSQLHOST || "localhost",
  user: process.env.DB_USER || process.env.MYSQLUSER || "root",
  password: process.env.DB_PASSWORD || process.env.MYSQLPASSWORD || "zoof", // put your MySQL root password here if you set one
  database: process.env.DB_NAME || process.env.MYSQLDATABASE || "legautocustDB",
  port: Number(process.env.DB_PORT || process.env.MYSQLPORT || 3306)
});

db.connect((err) => {
  if (err) {
    console.log("DB connection failed:", err);
    return;
  }
  console.log("Connected to MySQL database.");
});

module.exports = db;