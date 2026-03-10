require('dotenv').config();
const express = require("express");
const db = require("./db");
const app = express();
//const PORT = 3000;
const path = require("path");
const PORT = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname, "../Sprint2Alberto")));

app.use(express.json());
app.use(express.urlencoded({ extended: false }));

/* Root route */
app.get("/", (req, res) => {
  res.send("CMPSC390 Backend API is running (Charles - Backend).");
});
/* Test route */
app.get("/test", (req, res) => {
  res.send("Backend server is running successfully (charlesDev).");
});
/* GET all parts */
app.get("/parts", (req, res) => {
  const sql = "SELECT * FROM Parts";
  db.query(sql, (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Database error" });
    }
    res.json(results);
  });
});
/* User login */
app.post("/login", (req, res) => {
  const { EmployeeID, password } = req.body;
  /*const sql = "SELECT * FROM `Employees` WHERE EmployeeID = ?"; BEFORE MY SQL KEEP in case*/
  /* see if they are management and or employed */
  const sql =  "SELECT * FROM Employees JOIN EmployeePerformance ON Employees.EmployeeID = EmployeePerformance.EmployeeID WHERE Employees.EmployeeID = ? AND EmployeePerformance.ActivelyEmployed = TRUE";

  db.query(sql, [EmployeeID], (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Database error" });
    }

    if (results.length === 0) {
      return res.status(401).json({ message: "Login failed" });
    }

    const user = results[0];

    if (user.Password !== password) {
      return res.status(401).json({ message: "Login failed" });
    }

    //res.json({ message: "Login successful" });

    if (user.Management) {
      return res.redirect("/ManagerDashboardPage.html")
    } else{
      return res.redirect("/EmployeeDashboardPage.html")

    }
  });
});
/* Start server */
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});