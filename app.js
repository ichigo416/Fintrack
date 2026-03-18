const express = require('express');
const cors = require('cors');

const expenseRoutes = require('./routes/expenseRoutes');

const app = express(); // ✅ FIRST create app

app.use(cors());
app.use(express.json());

// ✅ THEN use routes
app.use('/api/expenses', expenseRoutes);

module.exports = app;