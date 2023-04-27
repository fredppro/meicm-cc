let DB_URI // = "mongodb://localhost:27017/microservices";
if (process.env.MONGO_DB_URI) {
  DB_URI = process.env.MONGO_DB_URI;
  console.log(DB_URI);
  console.log("entrei if")
} else {
  console.log("entrei else")
}

module.exports = {
  DB_URI
};
