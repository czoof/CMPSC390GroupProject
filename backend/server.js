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
  const sql =  "SELECT *FROM Employees JOIN EmployeePerformance ON Employees.EmployeeID = EmployeePerformance.EmployeeID WHERE Employees.EmployeeID = ? AND EmployeePerformance.ActivelyEmployed = TRUE";
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
      return res.redirect(`/ManagerDashboardPage.html?name=${user.FirstName}%20${user.LastName}&EmployeeID=${user.EmployeeID}&manager=${user.Management}`)
    } else{ 
      return res.redirect(`/EmployeeDashboardPage.html?name=${user.FirstName}%20${user.LastName}&EmployeeID=${user.EmployeeID}&manager=${user.Management}`)
    }
  });
});


                /*Routes for the manager and employee dashboard*/
/*Schedule*/
app.get("/getSchedule", (req, res) => {
    const employeeID = req.query.EmployeeID;
    const sql = `
    SELECT Employees.EmployeeID, Employees.FirstName, Employees.LastName, Schedule.MonthNum, Schedule.WeekNum, Schedule.Mon, Schedule.Tue, Schedule.Wed, Schedule.Thu, Schedule.Fri, Schedule.Sat, Schedule.Sun FROM Schedule JOIN Employees ON Schedule.EmployeeID = Employees.EmployeeID WHERE Schedule.EmployeeID = ?`;
    db.query(sql, [employeeID], (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).send("Database error");
        }
        res.json(results);
    });
});
/*Attendance*/

app.get("/getPoints", (req, res) => {
    const employeeID = req.query.EmployeeID;
    const sql = `SELECT Points FROM EmployeePerformance WHERE EmployeeID = ?`;
    db.query(sql, [employeeID], (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database error");
        }
        if (result.length === 0) {
            return res.json({ Points: 0 });
        }
        res.json(result[0]);
    });
});

app.post("/request-dayoff", (req, res) => {
    const { EmployeeID, MonthNum, WeekNum, DayOfWeek, Reason } = req.body;
    const sql = `INSERT INTO TimeOffRequests (EmployeeID, MonthNum, WeekNum, DayOfWeek, Reason) VALUES (?, ?, ?, ?, ?)`;
    db.query(sql, [EmployeeID, MonthNum, WeekNum, DayOfWeek, Reason], (err, result) => {
        if (err){
            console.error(err);
            return res.status(500).send("Request failed");
        }
        res.send("Request submitted!");
    });
});

/*Tax Info.*/
app.get("/getEmployeePay", (req,res)=>{
    const employeeID = req.query.EmployeeID;
    const sql = `SELECT HourlyPay FROM Employees WHERE EmployeeID = ?`;
    db.query(sql,[employeeID],(err,results)=>{
        if(err){
            console.log(err);
            return res.status(500).send("Database error");
        }
        res.json(results[0]);
    });
});

/*Employee Recognition*/

/*Employee Options*/

/*Disciplinary Action*/

/*Contact Info*/
app.get("/contactInfo", (req, res)=>{
  const employeeID = req.query.EmployeeID;
  const sql = `SELECT PhoneNumber, EmergencyPhoneNumber, Address, PersonalEmail, WorkEmail FROM EmployeeContactInfo WHERE EmployeeID = ?`;
  db.query(sql,[employeeID],(err,results)=>{
  if(err){
    console.log(err);
    return res.status(500).send("Database error");
  }
  res.json(results[0]);
  });
});

/* Start server */
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});