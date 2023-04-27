/*const app = require("./src/app");
const { DB_URI } = require("./src/config");
const mongoose = require("mongoose");

mongoose.connect(
  DB_URI
)
.then(()=>console.log('connected'))
.catch(e=>console.log(e));

app.listen(3000, () => {
  console.log("running on port 3000");
  console.log("--------------------------");
});

*/

const express = require("express");
const app = express();
const mongoose = require("mongoose");

// Database
const database = (module.exports = () => {
  const connectionParams = {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  };
  try {
    mongoose.connect(
      "mongodb+srv://2220656:y0bifNLreErh3Dk1@clustercc.q9zidlc.mongodb.net/?retryWrites=true&w=majority",
      connectionParams
    );
    console.log("Database connected succesfully");
  } catch (error) {
    console.log(error);
    console.log("Database connection failed");
  }
});

database();

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});

