let DB_URI // = "mongodb://localhost:27017/microservices";

if (process.env.MONGO_DB_URI) {
  DB_URI = process.env.MONGO_DB_URI;
  console.log(DB_URI);
}
else {
  DB_URI = "mongodb://localhost:27017/microservices";
}

module.exports = {
  DB_URI
};
