const rules = [
  { keyword: 'zomato', category: 'Food' },
  { keyword: 'swiggy', category: 'Food' },
  { keyword: 'uber', category: 'Transport' },
  { keyword: 'ola', category: 'Transport' },
  { keyword: 'amazon', category: 'Shopping' },
  { keyword: 'flipkart', category: 'Shopping' },
];

function categorize(merchant) {
  if (!merchant) return 'Others';

  const lower = merchant.toLowerCase();

  for (let rule of rules) {
    if (lower.includes(rule.keyword)) {
      return rule.category;
    }
  }

  return 'Others';
}

module.exports = categorize;