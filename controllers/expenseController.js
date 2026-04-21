const { Expense } = require('../models');
const categorize = require('../services/categorizeService');

exports.addExpense = async (req, res) => {
  try {
    const { merchant } = req.body;
    const category = await categorize(merchant);
    const expense = await Expense.create({ ...req.body, category });
    res.status(201).json(expense);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getExpenses = async (req, res) => {
  try {
    const expenses = await Expense.findAll({ order: [['createdAt', 'DESC']] });
    res.json(expenses);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.deleteExpense = async (req, res) => {
  try {
    const { id } = req.params;
    const expense = await Expense.findByPk(id);
    if (!expense) return res.status(404).json({ error: 'Expense not found' });
    await expense.destroy();
    res.json({ message: 'Deleted successfully', id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};