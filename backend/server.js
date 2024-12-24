const express = require("express");
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// MongoDB Connection
mongoose.connect("mongodb://localhost:27017/flutter_crud", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const db = mongoose.connection;
db.on("error", console.error.bind(console, "MongoDB connection error:"));
db.once("open", () => console.log("MongoDB Connected"));

// User Schema
const userSchema = new mongoose.Schema({
  username: String,
  password: String,
});
const User = mongoose.model("User", userSchema);

// Login Endpoint
app.post("/login", async (req, res) => {
  const { username, password } = req.body;
  try {
    const user = await User.findOne({ username, password });
    if (user) {
      res.status(200).json({ message: "Login successful", user });
    } else {
      res.status(401).json({ message: "Invalid credentials" });
    }
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// Patient Schema
const patientSchema = new mongoose.Schema({
  name: String,
  dob: String,
  diagnosis: String,
  phone: String,
  address: String,
});
const Patient = mongoose.model("Patient", patientSchema);

// Get All Patients Endpoint
app.get("/patients", async (req, res) => {
  try {
    const patients = await Patient.find();
    res.status(200).json(patients);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// Add New Patient Endpoint
app.post("/patients", async (req, res) => {
  const { name, dob, diagnosis, phone, address } = req.body;
  try {
    const newPatient = new Patient({
      name,
      dob,
      diagnosis,
      phone,
      address,
    });
    await newPatient.save();
    res
      .status(201)
      .json({ message: "Patient added successfully", patient: newPatient });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// Delete Patient Endpoint
app.delete("/patients/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await Patient.findByIdAndDelete(id);
    res.status(200).json({ message: "Patient deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// Update Patient Endpoint
app.put("/patients/:id", async (req, res) => {
  try {
    console.log("ID pasien:", req.params.id); // Debug ID
    console.log("Data yang diterima:", req.body); // Debug data
    const { id } = req.params;
    const updatedData = req.body;
    const updatedPatient = await Patient.findByIdAndUpdate(id, updatedData, {
      new: true,
    });
    res
      .status(200)
      .json({ message: "Patient updated successfully", updatedPatient });
  } catch (error) {
    console.error("Error:", error); // Debug error
    res.status(500).json({ message: "Server error" });
  }
});

// Start Server
const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
