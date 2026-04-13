const mysql = require("mysql2");
require("dotenv").config();

const db = mysql.createConnection({
  host: process.env.DB_HOST || process.env.HOST || "localhost",
  user: process.env.DB_USER || process.env.USER || "root",
  password: process.env.DB_PASSWORD || process.env.PASSWORD || "",
  database: process.env.DB_NAME || process.env.DATABASE || "legautocustDB",
  port: Number(process.env.DB_PORT || 3306)
});

db.connect((err) => {
  if (err) {
    console.log("DB connection failed:", err);
    return;
  }
  console.log("Connected to MySQL database.");
});

module.exports = db;