const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');


const app = express();
const port = 3000;


app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static(__dirname));

//database contains the parts:id, price,name,stock number,category, and image
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'Window142026', // use your MySQL password if needed
  database: 'legautocustDB'
});


//const express = require("express");
//const app = express();
const db = require("./db");

app.get("/api/parts", async (req, res) => {
  const { category, inStock } = req.query;
//no repeats 
  let query = "SELECT * FROM parts WHERE 1=1";
//category system
  if (category) {
    query += ` AND category='${category}'`;
  }
//instock system, it's still in stock if it's more than 0
  if (inStock === "true") {
    query += ` AND stock_quantity > 0`;
  }

  const results = await db.query(query);
  res.json(results);
});