const app = require("./src/app");

app.get('/envs', (req, res) => {
  res.json({ booksUrl: process.env.BOOKS_URL ,  search_url: process.env.SEARCH_URL, videos_url: process.env.BOOKS_URL });
});

app.listen(3000, () => {
  console.log("running on port 3000");
  console.log("--------------------------");
});
