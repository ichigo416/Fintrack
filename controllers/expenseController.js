const { Expense } = require('../models');
const categorize = require('../services/categorizeService');

exports.addExpense = async (req, res) => {
  try {
    const { userId, amount, merchant, date } = req.body;

    const category = categorize(merchant);

    const expense = await Expense.create({
      userId,
      amount,
      merchant,
      date,
      category
    });

    res.status(201).json(expense);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};